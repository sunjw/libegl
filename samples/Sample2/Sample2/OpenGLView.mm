//
//  OpenGLView.m
//  Sample2
//
//  Created by Wayne Sun on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#import "OpenGLView.h"

#include <stdlib.h>

#include <map>

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#include "Comm.h"
#include "Lock.h"
#include "RenderThread.h"
#include "RenderController.h"

struct RenderContext
{
    CAEAGLLayer *eaglLayer;
    
    EAGLContext *eaglContext;
    
    GLint glWidth;
    GLint glHeight;
    
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    GLfloat angle;
};

static GLint s_vertices[][3] = {
    { -0x10000, -0x10000, -0x10000 },
    {  0x10000, -0x10000, -0x10000 },
    {  0x10000,  0x10000, -0x10000 },
    { -0x10000,  0x10000, -0x10000 },
    { -0x10000, -0x10000,  0x10000 },
    {  0x10000, -0x10000,  0x10000 },
    {  0x10000,  0x10000,  0x10000 },
    { -0x10000,  0x10000,  0x10000 }
};

static GLint s_colors[][4] = {
    { 0x00000, 0x00000, 0x00000, 0x10000 },
    { 0x10000, 0x00000, 0x00000, 0x10000 },
    { 0x10000, 0x10000, 0x00000, 0x10000 },
    { 0x00000, 0x10000, 0x00000, 0x10000 },
    { 0x00000, 0x00000, 0x10000, 0x10000 },
    { 0x10000, 0x00000, 0x10000, 0x10000 },
    { 0x10000, 0x10000, 0x10000, 0x10000 },
    { 0x00000, 0x10000, 0x10000, 0x10000 }
};

static GLubyte s_indices[] = {
    0, 4, 5,    0, 5, 1,
    1, 5, 6,    1, 6, 2,
    2, 6, 7,    2, 7, 3,
    3, 7, 4,    3, 4, 0,
    4, 7, 6,    4, 6, 5,
    3, 0, 1,    3, 1, 2
};

typedef std::map<RenderThread *, RenderContext *> ThreadRenderCtx_t;

void *renderThreadFunc(void *arg);

extern RenderController g_renderController;

@implementation OpenGLView {
    CAEAGLLayer *_mainLayer;
    
    ThreadRenderCtx_t _thRenderCtxs;
}

+ (Class) layerClass {
    return [CAEAGLLayer class];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mainLayer = (CAEAGLLayer *)self.layer;
        _mainLayer.opaque = YES;
        
        int threadMax = 5;
        
        for(int i = 0; i < threadMax; ++i) {
            RenderThread *renderThread = new RenderThread(renderThreadFunc, (__bridge void *)self);
        
            g_renderController.addRenderThread(renderThread);
        }
        
    }
    
    return self;
}

- (void) dealloc {
    ThreadRenderCtx_t::iterator itr = _thRenderCtxs.begin();
    for(; itr != _thRenderCtxs.end(); ++itr) {
        delete itr->second;
    }
}

- (RenderContext *)getRenderContext:(RenderThread *)pThread {
    ThreadRenderCtx_t::iterator itr = _thRenderCtxs.find(pThread);
    if (itr == _thRenderCtxs.end()) {
        RenderContext *renderContext = new RenderContext();
        
        _thRenderCtxs[pThread] = renderContext;
        
        itr = _thRenderCtxs.find(pThread); // again to get the pointer inside map
    
        size_t threadCount = _thRenderCtxs.size();
        
        renderContext = itr->second;
        
        CGFloat viewWidth = self.bounds.size.width;
        CGFloat viewHeight = self.bounds.size.height;
        
        renderContext->glWidth = (GLint) viewWidth;
        renderContext->glHeight = (GLint) viewHeight;
        
        renderContext->eaglLayer = [[CAEAGLLayer alloc] init];
        renderContext->eaglLayer.opaque = NO;
        
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        const CGFloat myColor[] = {0.0, 0.0, 0.0, 0.0};
        renderContext->eaglLayer.backgroundColor = CGColorCreate(rgb, myColor);
        CGColorSpaceRelease(rgb);
        
        renderContext->eaglLayer.frame = CGRectMake(-20 + threadCount * 20,
                                                    -20 + threadCount * 20,
                                                    renderContext->glWidth,
                                                    renderContext->glHeight);
        renderContext->eaglLayer.contentsScale = 1.0;
        renderContext->eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [NSNumber numberWithBool:NO],
                                                       kEAGLDrawablePropertyRetainedBacking,
                                                       kEAGLColorFormatRGBA8,
                                                       kEAGLDrawablePropertyColorFormat,
                                                       nil];
        
        
        [_mainLayer addSublayer:renderContext->eaglLayer];
        
        renderContext->framebuffer = 0;
        renderContext->colorRenderbuffer = 0;
        renderContext->depthRenderbuffer = 0;
        
        renderContext->angle = threadCount * 30;
    }
    
    return itr->second;
}

- (void) setupGL:(RenderContext *)renderCtx {
    renderCtx->eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!renderCtx->eaglContext ||
        ![EAGLContext setCurrentContext:renderCtx->eaglContext]) {
        NSLog(@"failed to setup EAGLContext");
        return;
    }
    
    glGenFramebuffersOES(1, &renderCtx->framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, renderCtx->framebuffer);
    
    glGenRenderbuffersOES(1, &renderCtx->colorRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderCtx->colorRenderbuffer);
    
    // This for CAEAGLLayer rendering
    [renderCtx->eaglContext renderbufferStorage:GL_RENDERBUFFER_OES
                                   fromDrawable:renderCtx->eaglLayer];
    
    
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                 GL_COLOR_ATTACHMENT0_OES,
                                 GL_RENDERBUFFER_OES,
                                 renderCtx->colorRenderbuffer);
    
    
    glGenRenderbuffersOES(1, &renderCtx->depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderCtx->depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES,
                             renderCtx->glWidth, renderCtx->glHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                 GL_DEPTH_ATTACHMENT_OES,
                                 GL_RENDERBUFFER_OES,
                                 renderCtx->depthRenderbuffer);
    
    
    GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) ;
    if(status != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        //return;
    }
    
}

- (void) cleanupGL:(RenderContext *)renderCtx {
    if (renderCtx->framebuffer) {
        glDeleteFramebuffersOES(1, &renderCtx->framebuffer);
        renderCtx->framebuffer = 0;
    }
    
    if (renderCtx->colorRenderbuffer) {
        glDeleteRenderbuffersOES(1, &renderCtx->colorRenderbuffer);
        renderCtx->colorRenderbuffer = 0;
    }
    
    if (renderCtx->depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &renderCtx->depthRenderbuffer);
        renderCtx->depthRenderbuffer = 0;
    }
    
    if ([EAGLContext currentContext] == renderCtx->eaglContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
    renderCtx->eaglContext = nil;
}

// Post OpenGL rendering image on screen though CAEAGLLayer
- (void) postOnScreen:(RenderContext *)renderCtx {
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderCtx->colorRenderbuffer);
    
    [renderCtx->eaglContext presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}

- (void) prepareDrawing:(RenderContext *)renderCtx {
    GLfloat ratio;
    
    glDisable(GL_DITHER);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    glClearColor(0, 0, 0, 0);
    glEnable(GL_CULL_FACE);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, renderCtx->glWidth, renderCtx->glHeight);
    
    ratio = (GLfloat) renderCtx->glWidth / renderCtx->glHeight;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-ratio, ratio, -1, 1, 1, 10);
}

- (void) drawFrame:(RenderContext *)renderCtx {
    //NSLog(@"drawFrame");
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, renderCtx->framebuffer);
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0, 0, -3.0f);
    glRotatef(renderCtx->angle, 0, 1, 0);
    glRotatef(renderCtx->angle*0.25f, 1, 0, 0);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glFrontFace(GL_CW);
    glVertexPointer(3, GL_FIXED, 0, s_vertices);
    glColorPointer(4, GL_FIXED, 0, s_colors);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, s_indices);
    
    renderCtx->angle += 1.2f;
}

@end

void *renderThreadFunc(void *arg) {
    NSLog(@"renderThreadFunc start");
    
    RenderThread *thisThread = (RenderThread *)arg;
    
    OpenGLView *openGLView = (__bridge OpenGLView *)thisThread->getArg();
    
    RenderContext *renderCtx = [openGLView getRenderContext:thisThread];
    
    [openGLView setupGL:renderCtx];
    
    [openGLView prepareDrawing:renderCtx];
    
    while (1) {
        RenderThread::THREAD_STATE thState = thisThread->getState();
        
        if (thState == RenderThread::THREAD_WAIT) {
            NSLog(@"renderThreadFunc waitOn");
            thisThread->waitOnSignal();
            NSLog(@"renderThreadFunc alive");
        }
        
        // retrieve state again
        thState = thisThread->getState();
        if (thState == RenderThread::THREAD_STOP) {
            break;
        }
        
        g_renderController.lockRenderMutex();
        
        [openGLView drawFrame:renderCtx];
        
        [openGLView postOnScreen:renderCtx];
        
        g_renderController.unlockRenderMutex();
        
    }
    
    [openGLView cleanupGL:renderCtx];
    
    thisThread->exited();
    
    NSLog(@"renderThreadFunc exited");
    
    return 0;
}


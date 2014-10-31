//
//  OpenGLView.m
//  Sample2
//
//  Created by Wayne Sun on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#import "OpenGLView.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#include "Comm.h"
#include "Thread.h"

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

extern int g_appState;

void *renderThreadFunc(void *arg);

@implementation OpenGLView {
    CAEAGLLayer *_mainLayer;
    CAEAGLLayer *_newLayer;
    
    Thread *_renderThread;
    
    BOOL _gotoTerminate;
    
    EAGLContext *_eaglContext;
    
    GLint _glWidth;
    GLint _glHeight;
    
    GLuint _framebuffer;
    GLuint _colorRenderbuffer;
    GLuint _depthRenderbuffer;
    
    GLfloat _angle;
}

+ (Class) layerClass {
    return [CAEAGLLayer class];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat viewWidth = self.bounds.size.width;
        CGFloat viewHeight = self.bounds.size.height;
        
        _mainLayer = (CAEAGLLayer *)self.layer;
        _mainLayer.opaque = YES;
        
        _glWidth = (GLint) viewWidth;
        _glHeight = (GLint) viewHeight;
        
        _newLayer = [[CAEAGLLayer alloc] init];
        _newLayer.opaque = YES;
        _newLayer.frame = CGRectMake(50.0, 20.0, _glWidth, _glHeight);
        _newLayer.contentsScale = 1.0;
        _newLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO],
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        [_mainLayer addSublayer:_newLayer];
        
        _gotoTerminate = FALSE;
        
        _framebuffer = 0;
        _colorRenderbuffer = 0;
        _depthRenderbuffer = 0;
        
        _angle = 0.0f;
        
        _renderThread = new Thread(renderThreadFunc, (__bridge void *)self);
        
    }
    
    return self;
}

- (void) dealloc {
    _gotoTerminate = TRUE;
    
    if(_renderThread) {
        _renderThread->join();
        delete _renderThread;
    }
}

- (BOOL) isGotoTerminate {
    return _gotoTerminate;
}

- (void) startDraw {
    if (_renderThread)
        _renderThread->run();
}

- (void) setupGL {
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!_eaglContext ||
        ![EAGLContext setCurrentContext:_eaglContext]) {
        NSLog(@"failed to setup EAGLContext");
        return;
    }
    
    glGenFramebuffersOES(1, &_framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
    
    glGenRenderbuffersOES(1, &_colorRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    
    // This for CAEAGLLayer rendering
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER_OES
                         fromDrawable:_newLayer];
    
    
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                 GL_COLOR_ATTACHMENT0_OES,
                                 GL_RENDERBUFFER_OES,
                                 _colorRenderbuffer);
    
    
    glGenRenderbuffersOES(1, &_depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES,
                             _glWidth, _glHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                 GL_DEPTH_ATTACHMENT_OES,
                                 GL_RENDERBUFFER_OES,
                                 _depthRenderbuffer);
    
    
    GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) ;
    if(status != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        //return;
    }
    
}

- (void) cleanupGL {
    if (_framebuffer) {
        glDeleteFramebuffersOES(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_colorRenderbuffer) {
        glDeleteRenderbuffersOES(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }
    
    if (_depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &_depthRenderbuffer);
        _depthRenderbuffer = 0;
    }
    
    if ([EAGLContext currentContext] == _eaglContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
    _eaglContext = nil;
}

// Post OpenGL rendering image on screen though CAEAGLLayer
- (void) postOnScreen {
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}

- (void) prepareDrawing {
    GLfloat ratio;
    
    glDisable(GL_DITHER);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    glClearColor(0, 0, 0, 0);
    glEnable(GL_CULL_FACE);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, _glWidth, _glHeight);
    
    ratio = (GLfloat) _glWidth / _glHeight;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-ratio, ratio, -1, 1, 1, 10);
}

- (void) drawFrame {
    //NSLog(@"drawFrame");
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0, 0, -3.0f);
    glRotatef(_angle, 0, 1, 0);
    glRotatef(_angle*0.25f, 1, 0, 0);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glFrontFace(GL_CW);
    glVertexPointer(3, GL_FIXED, 0, s_vertices);
    glColorPointer(4, GL_FIXED, 0, s_colors);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, s_indices);
    
    _angle += 1.2f;
}

@end

void *renderThreadFunc(void *arg) {
    OpenGLView *openGLView = (__bridge OpenGLView *)arg;
    
    [openGLView setupGL];
    
    [openGLView prepareDrawing];
    
    while (1) {
        if (g_appState == APP_TERMINATE ||
            [openGLView isGotoTerminate])
            break;
        
        if (g_appState == APP_RUNNING) {
            [openGLView drawFrame];
    
            [openGLView postOnScreen];
        }
        
        //usleep(10000); // 10ms
    }
    
    [openGLView cleanupGL];
    
    return 0;
}


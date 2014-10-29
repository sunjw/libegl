//
//  OpenGLView.m
//  Sample2
//
//  Created by TM Test on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#import "OpenGLView.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

static GLint g_vertices[][3] = {
    { -0x10000, -0x10000, -0x10000 },
    {  0x10000, -0x10000, -0x10000 },
    {  0x10000,  0x10000, -0x10000 },
    { -0x10000,  0x10000, -0x10000 },
    { -0x10000, -0x10000,  0x10000 },
    {  0x10000, -0x10000,  0x10000 },
    {  0x10000,  0x10000,  0x10000 },
    { -0x10000,  0x10000,  0x10000 }
};

static GLint g_colors[][4] = {
    { 0x00000, 0x00000, 0x00000, 0x10000 },
    { 0x10000, 0x00000, 0x00000, 0x10000 },
    { 0x10000, 0x10000, 0x00000, 0x10000 },
    { 0x00000, 0x10000, 0x00000, 0x10000 },
    { 0x00000, 0x00000, 0x10000, 0x10000 },
    { 0x10000, 0x00000, 0x10000, 0x10000 },
    { 0x10000, 0x10000, 0x10000, 0x10000 },
    { 0x00000, 0x10000, 0x10000, 0x10000 }
};

static GLubyte g_indices[] = {
    0, 4, 5,    0, 5, 1,
    1, 5, 6,    1, 6, 2,
    2, 6, 7,    2, 7, 3,
    3, 7, 4,    3, 4, 0,
    4, 7, 6,    4, 6, 5,
    3, 0, 1,    3, 1, 2
};

@implementation OpenGLView {
    EAGLContext *_eaglContext;
    
    GLuint _framebuffer;
    GLuint _colorRenderbuffer;
    GLuint _depthRenderbuffer;
    
    GLfloat _angle;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!_eaglContext ||
            ![EAGLContext setCurrentContext:_eaglContext])
        {
            NSLog(@"failed to setup EAGLContext");
            self = nil;
            return nil;
        }
        
        _angle = 0.0f;
        
        [self setupGL];
    }
    
    return self;
}

- (void)dealloc {
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

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupGL {
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    GLint width = (GLint) viewWidth;
    GLint height = (GLint) viewHeight;
    
    glGenFramebuffersOES(1, &_framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
    
    glGenRenderbuffersOES(1, &_colorRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_RGBA8_OES, width, height);
    glFramebufferRenderbufferOES(GL_RENDERBUFFER_OES,
                                 GL_COLOR_ATTACHMENT0_OES,
                                 GL_RENDERBUFFER_OES,
                                 _colorRenderbuffer);
    
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER_OES
                         fromDrawable:(CAEAGLLayer*)self.layer];
    
    glGenRenderbuffersOES(1, &_depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES,
                             width, height);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                 GL_DEPTH_ATTACHMENT_OES,
                                 GL_RENDERBUFFER_OES,
                                 _depthRenderbuffer);
    
    GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) ;
    if(status != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        return;
    }
    
    GLfloat ratio;
    
    glDisable(GL_DITHER);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    glClearColor(0, 0, 0, 0);
    glEnable(GL_CULL_FACE);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, width, height);
    
    ratio = (GLfloat) width / height;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-ratio, ratio, -1, 1, 1, 10);
}

- (void)layoutSubviews {
    NSLog(@"- (void)layoutSubviews");
}

@end

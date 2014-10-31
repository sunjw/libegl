//
//  OpenGLView.h
//  Sample2
//
//  Created by Wayne Sun on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _OPENGL_View_H_
#define _OPENGL_View_H_

#include <pthread.h>

#import <UIKit/UIKit.h>

class RenderThread;
struct RenderContext;

@interface OpenGLView : UIView

- (RenderContext *)getRenderContext:(RenderThread *)pThread;

- (void) setupGL:(RenderContext *)renderCtx;

- (void) cleanupGL:(RenderContext *)renderCtx;

- (void) postOnScreen:(RenderContext *)renderCtx;

- (void) prepareDrawing:(RenderContext *)renderCtx;

- (void) drawFrame:(RenderContext *)renderCtx;

@end

#endif // _OPENGL_View_H_

//
//  OpenGLView.h
//  Sample2
//
//  Created by Wayne Sun on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _OPENGL_View_H_
#define _OPENGL_View_H_

#import <UIKit/UIKit.h>

@interface OpenGLView : UIView

- (void) setupGL;

- (void) cleanupGL;

- (void) postOnScreen;

- (void) prepareDrawing;

- (void) drawFrame;

@end

#endif // _OPENGL_View_H_

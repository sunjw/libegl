//
//  OpenGLViewController.m
//  Sample2
//
//  Created by TM Test on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#import "OpenGLViewController.h"

#include "OpenGLView.h"

@interface OpenGLViewController () {
    
}
@property (strong, nonatomic) EAGLContext *context;

@end

@implementation OpenGLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat appWidth = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat appHeight = [UIScreen mainScreen].applicationFrame.size.height;
    
    OpenGLView *_openGLView = [[OpenGLView alloc]
                               initWithFrame:CGRectMake(0, 0,
                                                        appWidth, appHeight)];

    [self.view addSubview:_openGLView];
    
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


/*- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
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
    glVertexPointer(3, GL_FIXED, 0, g_vertices);
    glColorPointer(4, GL_FIXED, 0, g_colors);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, g_indices);
    
    _angle += 1.2f;
    
}*/

@end

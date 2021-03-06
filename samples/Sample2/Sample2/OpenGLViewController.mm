//
//  OpenGLViewController.m
//  Sample2
//
//  Created by Wayne Sun on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#import "OpenGLViewController.h"

#include "OpenGLView.h"

#include "RenderController.h"

extern RenderController g_renderController;

@interface OpenGLViewController () {
    
}

@end

@implementation OpenGLViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    CGFloat appWidth = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat appHeight = [UIScreen mainScreen].applicationFrame.size.height;
    
    OpenGLView *openGLView = [[OpenGLView alloc]
                               initWithFrame:CGRectMake(0, 0,
                                                        appWidth, appHeight)];

    [self.view addSubview:openGLView];
    
    g_renderController.threadsStart();
}

- (void) dealloc {

}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}


@end

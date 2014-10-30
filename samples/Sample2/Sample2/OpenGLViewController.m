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

- (void) viewDidLoad {
    [super viewDidLoad];
    
    CGFloat appWidth = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat appHeight = [UIScreen mainScreen].applicationFrame.size.height;
    
    OpenGLView *_openGLView = [[OpenGLView alloc]
                               initWithFrame:CGRectMake(0, 0,
                                                        appWidth, appHeight)];

    [self.view addSubview:_openGLView];
    
    [_openGLView startLoop];
}

- (void) dealloc {

}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}


@end

//
//  Comm.h
//  Sample2
//
//  Created by Wayne Sun on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _COMM_H_
#define _COMM_H_

#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>

enum APP_STATE {
    APP_RUNNING = 0,
    APP_BACKGROUND,
    APP_TERMINATE,
};

enum OPENGL_RENDER_TARGET {
    FRAMEBUFFER_OBJ = 0,
    CAEAGL_LAYER,
};

#ifdef __cplusplus
extern "C" {
#endif

static inline size_t CalcRGBAImgSize(int width, int height)
{ return 4 * width * height * sizeof(char); }

#ifdef __cplusplus
}
#endif

#endif // _COMM_H_

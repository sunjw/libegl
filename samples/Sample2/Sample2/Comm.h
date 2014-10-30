//
//  Comm.h
//  Sample2
//
//  Created by TM Test on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _COMM_H_
#define _COMM_H_

#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>

enum APP_STATE {
    APP_RUNNING = 0,
    APP_BACKGROUND = 1,
};

inline size_t CalcRGBAImgSize(int width, int height)
{ return 4 * width * height * sizeof(char); }

#endif // _COMM_H_

//
//  RenderThread.h
//  Sample2
//
//  Created by Wayne Sun on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _RENDER_THREAD_H_
#define _RENDER_THREAD_H_

#include "Lock.h"
#include "Thread.h"

class RenderThread: public Thread
{
public:
    enum THREAD_STATE {
        THREAD_ACTIVE = 0,
        THREAD_WAIT,
        THREAD_STOP,
        THREAD_EXITED,
    };
    
    RenderThread(ThreadFunc_t func, void* arg = NULL)
    :Thread(func, arg),
    _thStateCond(_thStateMtx), _thState(THREAD_STOP)
    {}
    
    void run();
    
    void active();
    
    void wait();
    
    void waitOnSignal();
    
    void stop();
    
    void exited();
    
    THREAD_STATE getState();
    
private:
    Mutex _thStateMtx;
    Condition _thStateCond;
    
    THREAD_STATE _thState;
    
    
};

#endif // _RENDER_THREAD_H_

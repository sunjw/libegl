//
//  RenderThread.cpp
//  Sample2
//
//  Created by TM Test on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#include "RenderThread.h"


void RenderThread::run()
{
    active();
    
    Thread::run();
}

void RenderThread::active()
{
    _thStateMtx.lock();
    _thState = THREAD_ACTIVE;
    _thStateMtx.unlock();
    
    _thStateCond.signal();
}

void RenderThread::wait()
{
    if (_thState == THREAD_EXITED)
        return;
    
    _thStateMtx.lock();
    _thState = THREAD_WAIT;
    _thStateMtx.unlock();
}

void RenderThread::waitOnSignal()
{
    _thStateMtx.lock();
    _thStateCond.wait();
    _thStateMtx.unlock();
}

void RenderThread::stop()
{
    if (_thState == THREAD_EXITED)
        return;
    
    _thStateMtx.lock();
    _thState = THREAD_STOP;
    _thStateMtx.unlock();
    
    _thStateCond.signal();
}

void RenderThread::exited()
{
    _thStateMtx.lock();
    _thState = THREAD_EXITED;
    _thStateMtx.unlock();
}

RenderThread::THREAD_STATE RenderThread::getState()
{
    return _thState;
}


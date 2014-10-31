//
//  Thread.cpp
//  Sample2
//
//  Created by Wayne Sun on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#include "Thread.h"

#include <pthread.h>

Thread::Thread(ThreadFunc_t func, void* arg)
:_pthId(0), _pthFunc(func), _pArg(arg)
{
    
}

void* Thread::threadStubFunc(void* pThread)
{
    Thread *th = (Thread *)pThread;
    return th->_pthFunc(th);
}

void Thread::run()
{
    pthread_create(&_pthId, NULL, Thread::threadStubFunc, this);
}

void Thread::join() const
{
    if (_pthId)
        pthread_join(_pthId, NULL);
}


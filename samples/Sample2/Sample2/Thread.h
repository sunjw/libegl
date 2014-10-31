//
//  Thread.h
//  Sample2
//
//  Created by Wayne Sun on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _THREAD_H_
#define _THREAD_H_

#include <pthread.h>

typedef void* (*ThreadFunc_t)(void* arg);

class Thread
{
public:
    Thread(ThreadFunc_t func, void* arg = NULL);
    
    inline pthread_t getPthId() const
    { return _pthId; }
    
    void run();
    
    void join() const;
    
private:
    static void* threadStubFunc(void* pThread);
    
    pthread_t _pthId;
    ThreadFunc_t _pthFunc;
    void *_pArg;
};

#endif // _THREAD_H_

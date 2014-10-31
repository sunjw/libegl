//
//  Lock.h
//  Sample2
//
//  Created by Wayne Sun on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _LOCK_H_
#define _LOCK_H_

#include <pthread.h>

class Mutex
{
public:
    Mutex();
    ~Mutex();
    
    void lock();
    void unlock();
    
    pthread_mutex_t *get();
    
private:
    Mutex(const Mutex& rhs);
    Mutex& operator = (const Mutex& rhs);
    
    pthread_mutex_t _mutex;
};

inline Mutex::Mutex()
{ pthread_mutex_init(&_mutex, NULL); }

inline Mutex::~Mutex()
{ pthread_mutex_destroy(&_mutex); }

inline void Mutex::lock()
{ pthread_mutex_lock(&_mutex); }

inline void Mutex::unlock()
{ pthread_mutex_unlock(&_mutex); }

inline pthread_mutex_t *Mutex::get()
{ return &_mutex; }

class Condition
{
public:
    Condition(Mutex& mutex);
    ~Condition();
    
    int wait();
    int signal();
    int broadcast();
    
private:
    Condition(const Condition& rhs);
    Condition& operator = (const Condition& rhs);
    
    pthread_cond_t _cond;
    Mutex& _mutex;
};

inline Condition::Condition(Mutex& mutex)
:_mutex(mutex)
{ pthread_cond_init(&_cond, NULL); }

inline Condition::~Condition()
{ pthread_cond_destroy(&_cond); }

inline int Condition::wait()
{ return pthread_cond_wait(&_cond, _mutex.get()); }

inline int Condition::signal()
{ return pthread_cond_signal(&_cond); }

inline int Condition::broadcast()
{ return pthread_cond_broadcast(&_cond); }

#endif // _LOCK_H_

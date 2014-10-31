//
//  RenderController.cpp
//  Sample2
//
//  Created by Wayne Sun on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#include "RenderController.h"

#include "RenderThread.h"

RenderController::RenderController()
{ }

RenderController::~RenderController()
{
    RenderThreadVector_t::iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        delete *itr;
    }
}

void RenderController::threadsStart() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->run();
    }
}

void RenderController::threadsActive() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->active();
    }
}

void RenderController::threadsWait() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->wait();
    }
}

void RenderController::threadsStop() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->stop();
    }
}

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

void RenderController::threadStart() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->run();
    }
}

void RenderController::threadActive() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->active();
    }
}

void RenderController::threadWait() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->wait();
    }
}

void RenderController::threadStop() const
{
    RenderThreadVector_t::const_iterator itr = _renderThreads.begin();
    for(; itr != _renderThreads.end(); ++itr)
    {
        (*itr)->stop();
    }
}

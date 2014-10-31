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
:_renderThread(NULL)
{
    
}

RenderController::~RenderController()
{
    if (_renderThread) {
        delete _renderThread;
        _renderThread = NULL;
    }
}

void RenderController::threadStart() const
{
    if (_renderThread == NULL)
        return;
    
    _renderThread->run();
}

void RenderController::threadActive() const
{
    if (_renderThread == NULL)
        return;
    
    _renderThread->active();
}

void RenderController::threadWait() const
{
    if (_renderThread == NULL)
        return;
    
    _renderThread->wait();
}

void RenderController::threadStop() const
{
    if (_renderThread == NULL)
        return;
    
    _renderThread->stop();
}

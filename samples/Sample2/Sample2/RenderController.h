//
//  RenderController.h
//  Sample2
//
//  Created by Wayne Sun on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _RENDER_CONTROLLER_H_
#define _RENDER_CONTROLLER_H_

#include <vector>

#include "RenderThread.h"

class RenderController
{
public:
    RenderController();
    ~RenderController();
    
    inline void addRenderThread(RenderThread *renderThread)
    { _renderThreads.push_back(renderThread); }
    
    void threadStart() const;
    
    void threadActive() const;
    
    void threadWait() const;
    
    void threadStop() const;
    
private:
    typedef std::vector<RenderThread *> RenderThreadVector_t;
    
    RenderThreadVector_t _renderThreads;
};

#endif // _RENDER_CONTROLLER_H_

//
//  RenderController.h
//  Sample2
//
//  Created by Wayne Sun on 10/31/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

#ifndef _RENDER_CONTROLLER_H_
#define _RENDER_CONTROLLER_H_

#include "RenderThread.h"

class RenderController
{
public:
    RenderController();
    ~RenderController();
    
    inline void setRenderThread(RenderThread *renderThread)
    { _renderThread = renderThread; }
    
    inline RenderThread *getRenderThread() const
    { return _renderThread; }
    
    void threadStart() const;
    
    void threadActive() const;
    
    void threadWait() const;
    
    void threadStop() const;
    
private:
    RenderThread *_renderThread;
};

#endif // _RENDER_CONTROLLER_H_

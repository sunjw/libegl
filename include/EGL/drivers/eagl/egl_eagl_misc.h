/**************************************************************************
 * MIT LICENSE
 *
 * Copyright (c) 2013-2014, David Andreoletti <http://davidandreoletti.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **************************************************************************/

#ifndef INCLUDE_EGL_DRIVERS_EAGL_EGL_EAGL_MISC_H_
#define INCLUDE_EGL_DRIVERS_EAGL_EGL_EAGL_MISC_H_

#include "EGL/egldriver.h"
#include "EGL/drivers/eagl/egl_eagl_globals.h"
#include "EGL/drivers/eagl/egl_eagl_context.h"
#include "EGL/drivers/eagl/egl_eagl_surface.h"
#include "EGL/drivers/eagl/egl_eagl_config.h"

/* standard typecasts */
_EGL_DRIVER_STANDARD_TYPECASTS(EAGL_egl)

typedef void (*ExecOnResource_t) ();

enum RequestType {
    SURFACE_NATIVEWINDOW,
    SET_CONTEXT_LOST_STATUS,
};

/** Find ressource query/result */
struct findresource {
    /** query criteria */
    enum RequestType RequestType;
    enum _egl_resource_type ResourceType;
    bool ResourceFound;
    _EGLDisplay* Display; // NULL = All displays
    /** query function */
    ExecOnResource_t Exec;
    /** query function static data */
    void* Data;
};

static void ExecFindNativeWindowAssociatedSurface (_EGLSurface* surface, EGLNativeWindowType window, bool* found) {
    struct EAGL_egl_surface* surf = EAGL_egl_surface(surface);
    if (surf->Surface.windowSurface == window) {
        *found = EGL_TRUE;
    }
}

static void ExecSetContextLostStatus (_EGLContext* context) {
    struct EAGL_egl_context* ctx = EAGL_egl_context(context);
    _eaglSetContextLost(ctx, EGL_TRUE);
    struct EAGL_egl_surface* surf = EAGL_egl_surface(context->DrawSurface);
    if(surf->Surface) {
        [surf->Surface cancelWaitUntilMinIntervalFrameUpdated];
    }
}


/**
 * Finds occurences satisfying the criterion and execute a function on it
 * \param head Display list
 * \param query
 */
static void findResource(_EGLDisplay* head, struct findresource* query) {
    
    _EGLDisplay* disp = head;
    bool searchSingleDisplay = (head == query->Display);
    while (disp && ((disp != query->Display) || searchSingleDisplay)) {
        if (0<_EGL_NUM_RESOURCES) {
            _EGLResource* res = disp->ResourceLists[query->ResourceType];
            while (res && !query->ResourceFound) {
                switch (query->RequestType) {
                    case SURFACE_NATIVEWINDOW:
                    {
                        query->Exec((_EGLSurface*)res, query->Data, &query->ResourceFound);
                        break;
                    }
                    case SET_CONTEXT_LOST_STATUS:
                    {
                        query->Exec((_EGLContext*)res);
                        break;
                    }
                    default:
                        break;
                }
                res = res->Next;
            }
        }
        disp = disp->Next;
        if (searchSingleDisplay) {
            searchSingleDisplay = false;
        }
    }
}

#endif  // INCLUDE_EGL_DRIVERS_EAGL_EGL_EAGL_MISC_H_

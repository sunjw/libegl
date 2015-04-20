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
//  Inspired from: https://github.com/rustle/ARCLogic

#ifndef INCLUDE_EGL_DRIVERS_EAGL_IOS_OBJCMEMORYMANAGEMENT_H_
#define INCLUDE_EGL_DRIVERS_EAGL_IOS_OBJCMEMORYMANAGEMENT_H_

#ifdef __OBJC__

#import <Foundation/NSObject.h> // CFBridgingRetain, CFBridgingRelease, CFRetain, CFRelease
#import <objc/runtime.h> // __bridge, __bridge_retained, __bridge_transfer
#import <CoreFoundation/CoreFoundation.h> // CFTypeRef

#ifdef HAS_FEATURE_ARC
#undef HAS_FEATURE_ARC
#endif
#ifdef HAS_FEATURE_ARC_WEAK
#undef HAS_FEATURE_ARC_WEAK
#endif
#ifdef OWNERSHIP_QUALIFIER_STRONG
#undef OWNERSHIP_QUALIFIER_STRONG
#endif
#ifdef __OWNERSHIP_QUALIFIER_STRONG
#undef __OWNERSHIP_QUALIFIER_STRONG
#endif
#ifdef OWNERSHIP_QUALIFIER_WEAK
#undef OWNERSHIP_QUALIFIER_WEAK
#endif
#ifdef __OWNERSHIP_QUALIFIER_WEAK
#undef __OWNERSHIP_QUALIFIER_WEAK
#endif
#ifdef es_dispatch_release
#undef es_dispatch_release
#endif
#ifdef es_dispatch_retain
#undef es_dispatch_retain
#endif
#ifdef OWNERSHIP_BRIDGE_NONE
#undef OWNERSHIP_BRIDGE_NONE
#endif
#ifdef OWNERSHIP_BRIDGE_RETAINED
#undef OWNERSHIP_BRIDGE_RETAINED
#endif
#ifdef OWNERSHIP_BRIDGE_TRANSFER
#undef OWNERSHIP_BRIDGE_TRANSFER
#endif
#ifdef OWNERSHIP_RETAIN
#undef OWNERSHIP_RELEASE
#endif
#ifdef OWNERSHIP_CFRETAIN
#undef OWNERSHIP_CFRELEASE
#endif
#ifdef OWNERSHIP_RELEASE
#undef OWNERSHIP_RELEASE
#endif
#ifdef OWNERSHIP_AUTORELEASE
#undef OWNERSHIP_AUTORELEASE
#endif
#ifdef METHOD_DEALLOC
#undef METHOD_DEALLOC
#endif
#ifdef CFTYPEREF_TO_ID
#undef CFTYPEREF_TO_ID
#endif
#ifdef ID_TO_CFTYPEREF
#undef ID_TO_CFTYPEREF
#endif

#define HAS_FEATURE_ARC __has_feature(objc_arc)

#define HAS_FEATURE_ARC_WEAK __has_feature(objc_arc_weak)

#if HAS_FEATURE_ARC
	#define IF_ARC(ARCBlock, NoARCBlock) ARCBlock
	#define NO_ARC(NoARCBlock) 
	#define OWNERSHIP_QUALIFIER_STRONG strong
	#define __OWNERSHIP_QUALIFIER_STRONG __strong
	#if HAS_FEATURE_ARC_WEAK
		#define __OWNERSHIP_QUALIFIER_WEAK __weak
		#define OWNERSHIP_QUALIFIER_WEAK weak
		#define NO_WEAK(NoWeakBlock) 
	#else
		#define OWNERSHIP_QUALIFIER_WEAK assign
		#define __OWNERSHIP_QUALIFIER_WEAK __unsafe_unretained
		#define NO_WEAK(NoWeakBlock) NoWeakBlock
	#endif
	#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 || MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
		#define es_dispatch_release(dispatch_object)
		#define es_dispatch_retain(dispatch_object)
	#else
		#define es_dispatch_release(dispatch_object) dispatch_release(dispatch_object)
		#define es_dispatch_retain(dispatch_object) dispatch_retain(dispatch_object)
	#endif
    #define OWNERSHIP_BRIDGE_NONE(type, typeRef) (__bridge type) typeRef
    #define OWNERSHIP_BRIDGE_RETAINED(cfType, nsTypeRef) (__bridge_retained cfType) nsTypeRef // i.e CFBridgingRetain(nsTypeRef)
    #define OWNERSHIP_BRIDGE_TRANSFER(nsType, cfTypeRef) (__bridge_transfer nsType) cfTypeRef // i.e i.e CFBridgingRelease(cfTypeRef)
    #define METHOD_DEALLOC(obj) // Usage: [self METHOD_DEALLOC];
    #define OWNERSHIP_RETAIN(obj) (id)obj
    #define OWNERSHIP_RELEASE(obj) (id)obj
    #define OWNERSHIP_AUTORELEASE(obj) (id)obj
    #define CFTYPEREF_TO_ID(cfTypeRef) (__bridge id) cfTypeRef
    #define ID_TO_CFTYPEREF(id) (__bridge CFTypeRef) id
#else
	#define IF_ARC(ARCBlock, NoARCBlock) NoARCBlock
	#define NO_ARC(NoARCBlock) NoARCBlock
	#define OWNERSHIP_QUALIFIER_STRONG retain
	#define __OWNERSHIP_QUALIFIER_STRONG 
	#define OWNERSHIP_QUALIFIER_WEAK assign
	#define __OWNERSHIP_QUALIFIER_WEAK 
	#define NO_WEAK(NoWeakBlock) NoWeakBlock
	#define es_dispatch_release(dispatch_object) dispatch_release(dispatch_object)
	#define es_dispatch_retain(dispatch_object) dispatch_retain(dispatch_object)
    #define OWNERSHIP_BRIDGE_NONE(type, typeRef) typeRef
    #define OWNERSHIP_BRIDGE_RETAINED(cfType, nsTypeRef) (cfType)[nsTypeRef retain]
    #define OWNERSHIP_BRIDGE_TRANSFER(nsType, cfTypeRef) [((nsType)cfTypeRef) release]
    #define METHOD_DEALLOC(obj) [obj dealloc]
    #define OWNERSHIP_RETAIN(obj) [obj retain]
    #define OWNERSHIP_RELEASE(obj) [obj release]
    #define OWNERSHIP_AUTORELEASE(obj) [obj autorelease]
    #define CFTYPEREF_TO_ID(cfTypeRef) (id) cfTypeRef
    #define ID_TO_CFTYPEREF(id) (CFTypeRef) id
#endif

#define OWNERSHIP_CFRETAIN(cfTypeRef) CFRetain(cfTypeRef)
#define OWNERSHIP_CFRELEASE(cfTypeRef) CFRelease(cfTypeRef)

#endif

#endif  // INCLUDE_EGL_DRIVERS_EAGL_IOS_OBJCMEMORYMANAGEMENT_H_


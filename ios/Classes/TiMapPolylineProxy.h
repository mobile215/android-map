/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-Present by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#ifndef map_TiMapPolylineProxy_h
#define map_TiMapPolylineProxy_h

#import "TiMapOverlayPattern.h"
#import <TitaniumKit/TiBase.h>
#import <TitaniumKit/TiViewProxy.h>

#import <MapKit/MapKit.h>

@class TiMapViewProxy;

@interface TiMapPolylineProxy : TiProxy {
  MKPolyline *polyline;
  MKPolylineRenderer *polylineRenderer;

  float strokeWidth;
  TiColor *strokeColor;
  TiMapOverlayPattern *pattern;
}

@property (nonatomic, readonly) MKPolyline *polyline;
@property (nonatomic, readonly) MKPolylineRenderer *polylineRenderer;

@end

#endif

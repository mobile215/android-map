/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-Present by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiMapPolylineProxy.h"
#import "TiMapConstants.h"

@implementation TiMapPolylineProxy

@synthesize polyline, polylineRenderer;

- (void)dealloc
{
  RELEASE_TO_NIL(polyline);
  RELEASE_TO_NIL(polylineRenderer);
  RELEASE_TO_NIL(strokeColor);

  [super dealloc];
}

- (void)_initWithProperties:(NSDictionary *)properties
{
  if ([properties objectForKey:@"points"] == nil) {
    [self throwException:@"missing required points property" subreason:nil location:CODELOCATION];
  }

  [super _initWithProperties:properties];
  [self setupPolyline];
}

#pragma mark Internal

- (NSString *)apiName
{
  return @"Ti.Map.Polyline";
}

- (void)setupPolyline
{
  id points = [self valueForKey:@"points"];
  CLLocationCoordinate2D *coordArray = malloc(sizeof(CLLocationCoordinate2D) * [points count]);

  for (int i = 0; i < [points count]; i++) {
    id locObj = [points objectAtIndex:i];
    CLLocationCoordinate2D coord = [self processLocation:locObj];
    coordArray[i] = coord;
  }

  polyline = [[MKPolyline polylineWithCoordinates:coordArray count:[points count]] retain];
  free(coordArray);
  polylineRenderer = [[[MKPolylineRenderer alloc] initWithPolyline:polyline] retain];

  [self applyStrokeColor];
  [self applyStrokeWidth];
  [self applyStrokePattern];
}

// A location can either be a an array of longitude, latitude pairings or
// an array of longitude, latitude objects.
// e.g. [ [123.33, 34.44], [100.39, 78.23], etc. ]
// [ {longitude: 123.33, latitude, 34.44}, {longitude: 100.39, latitude: 78.23}, etc. ]
- (CLLocationCoordinate2D)processLocation:(id)locObj
{
  if ([locObj isKindOfClass:[NSDictionary class]]) {
    CLLocationDegrees lat = [TiUtils doubleValue:[locObj objectForKey:@"latitude"]];
    CLLocationDegrees lon = [TiUtils doubleValue:[locObj objectForKey:@"longitude"]];

    return CLLocationCoordinate2DMake(lat, lon);
  } else if ([locObj isKindOfClass:[NSArray class]]) {
    CLLocationDegrees lat = [TiUtils doubleValue:[locObj objectAtIndex:1]];
    CLLocationDegrees lon = [TiUtils doubleValue:[locObj objectAtIndex:0]];

    return CLLocationCoordinate2DMake(lat, lon);
  }

  return kCLLocationCoordinate2DInvalid;
}

- (void)applyStrokeColor
{
  if (polylineRenderer != nil) {
    [polylineRenderer setStrokeColor:(strokeColor == nil ? [UIColor blackColor] : [strokeColor color])];
  }
}

- (void)applyStrokeWidth
{
  if (polylineRenderer != nil) {
    [polylineRenderer setLineWidth:strokeWidth];
  }
}

- (void)applyStrokePattern
{
  if (polylineRenderer != nil && pattern != nil) {
    [polylineRenderer setLineDashPattern:@[ NUMINTEGER(pattern.dashLength), NUMINTEGER(pattern.gapLength) ]];

    switch (pattern.type) {
    case TiMapOverlyPatternTypeDashed:
      [polylineRenderer setLineCap:kCGLineCapSquare];
      break;
    case TiMapOverlyPatternTypeDotted:
      [polylineRenderer setLineCap:kCGLineCapRound];
      break;
    default:
      NSLog(@"[ERROR] Unknown overlay-pattern provided!");
      break;
    }
  }
}

#pragma mark Public APIs

- (void)setPoints:(id)value
{
  ENSURE_TYPE(value, NSArray);
  if (![value count]) {
    [self throwException:@"missing required points data" subreason:nil location:CODELOCATION];
  }
  [self replaceValue:value forKey:@"points" notification:NO];
}

- (void)setStrokeColor:(id)value
{
  if (strokeColor != nil) {
    RELEASE_TO_NIL(strokeColor);
  }
  strokeColor = [[TiColor colorNamed:value] retain];
  [self applyStrokeColor];
  [self replaceValue:value forKey:@"strokeColor" notification:NO];
}

- (void)setStrokeWidth:(id)value
{
  strokeWidth = [TiUtils floatValue:value];
  [self applyStrokeWidth];
}

- (void)setPattern:(id)args
{
  ENSURE_TYPE(args, NSDictionary);

  TiMapOverlyPatternType type = [TiUtils intValue:@"type" properties:args def:TiMapOverlyPatternTypeDashed];
  NSInteger gapLength = [TiUtils intValue:[args objectForKey:@"gapLength"] def:20];
  NSInteger dashLength = [TiUtils intValue:[args objectForKey:@"dashLength"] def:50];

  RELEASE_TO_NIL(pattern);

  pattern = [[[TiMapOverlayPattern alloc] initWithPatternType:type
                                                 andGapLength:gapLength
                                                   dashLength:dashLength] retain];

  [self applyStrokePattern];
}

@end

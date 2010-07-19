//
//  PXCel.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCel.h"
#import "PXCanvas.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXAnimation.h"

@implementation PXCel
- init
{
	if (![super init]) {
		return nil;
	}
	canvas = [[PXCanvas alloc] init];
	duration = 1;
	return self;
}

- initWithCanvas:(PXCanvas *)initCanvas duration:(NSTimeInterval)initDuration
{
	if (![super init]) {
		return nil;
	}
	canvas = [initCanvas retain];
	duration = initDuration;
	return self;
}

- initWithCoder:(NSCoder *)coder
{
	return [self initWithCanvas:[coder decodeObjectForKey:@"canvas"] duration:[coder decodeDoubleForKey:@"duration"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:canvas forKey:@"canvas"];
	[coder encodeDouble:duration forKey:@"duration"];
}

- copyWithZone:(NSZone *)zone
{
	PXCel *cel = [[PXCel alloc] initWithCanvas:[canvas copyWithZone:zone] duration:duration];
	[[cel canvas] setGrid:[canvas grid]];
	return cel;
}

- initWithImage:(NSImage *)image animation:(PXAnimation *)animation atIndex:(NSUInteger)index
{
	if (![super init]) {
		return nil;
	}
	canvas = [[PXCanvas alloc] init];
	[canvas setUndoManager:[animation undoManager]];
	[canvas replaceActiveLayerWithImage:image];
	duration = 1;
	[animation insertObject:self inCelsAtIndex:index];
	return self;
}

- initWithImage:(NSImage *)image animation:(PXAnimation *)animation
{
	return [self initWithImage:image animation:animation atIndex:[animation countOfCels]];
}

- (void)dealloc
{
	[canvas release];
	[super dealloc];
}

- (NSDictionary *)info
{
	return [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:duration] forKey:@"duration"];
}

- (void)setInfo:(NSDictionary *)info
{
	duration = [[info objectForKey:@"duration"] doubleValue];
}

- (PXCanvas *)canvas
{
	return canvas;
}
- (void)setCanvas:(PXCanvas *)canv
{
	[canv retain];
	[canvas release];
	canvas = canv;
}
- (void)setUndoManager:man
{
	[canvas setUndoManager:man];
}
- (void)setSize:(NSSize)size
{
	[canvas setSize:size];
}
- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor
{
	[canvas setSize:aSize withOrigin:origin backgroundColor:bgcolor];
}
- (NSTimeInterval) duration
{
	return duration;
}
- (void)setDuration:(NSTimeInterval)newDuration
{
	duration = newDuration;
}
- (NSSize)size
{
	return [canvas size];
}
- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac
{
	[canvas drawInRect:dst fromRect:src operation:op fraction:frac];
}
- (NSImage *)displayImage
{
	return [canvas displayImage];
}
@end

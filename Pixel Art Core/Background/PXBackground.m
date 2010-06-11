//
//  PXBackground.m
//  Pixen-XCode
//

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

//  Created by Joe Osborn on Mon Oct 27 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXBackground.h"
#import "PXCanvas.h"

#import "Constants.h"
#import "PXNotifications.h"

@implementation PXBackground

+ (void)initialize
{
	static BOOL ready = NO;
	if(!ready)
	{
		ready = YES;
		PXMainBackgroundType = NSLocalizedString(@"Main Background", @"Main Background");
		PXAlternateBackgroundType = NSLocalizedString(@"Alternate Background", @"Alternate Background");
	}
}

- (NSImage *)previewImageOfSize:(NSSize)size
{
	NSRect imageRect = NSInsetRect(NSMakeRect(0, 0, size.width, size.height), 5, 5);
	NSImage *previewImage = [[[NSImage alloc] initWithSize:imageRect.size] autorelease];
	[previewImage lockFocus];
	[self drawRect:NSInsetRect(imageRect, -5, -5) withinRect:NSInsetRect(imageRect, -5, -5)];
	[previewImage unlockFocus];	
	return previewImage;
}

- (void)dealloc
{
	[self setName:nil];
	[super dealloc];
}

-(id) init
{
	if (! ( self = [super init] ) ) 
		return nil;
	
	[self setName:[self defaultName]];
	[self configurator];
	
	return self;
}

-(NSString *) defaultName
{
	return [self className];
}

- (NSString *)name
{
	return name;   
}

- (void)setName:(NSString *) aName
{
	id old = name;
	name = [aName copy];
	[old release];
}

- (NSView *)configurator
{
	if([self isMemberOfClass:[PXBackground class]]) 
	{
		return nil; 
	}
	
	if( ! configurator ) 
	{
		[NSBundle loadNibNamed:[self nibName] owner:self]; 
		[configurator retain];
	}
	
	NSAssert1(configurator != nil, @"No configurator for %@!", self);
	return configurator;
}

- (NSString *)nibName
{
    return @"";
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
    
}

- (void)changed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PXBackgroundChangedNotificationName object:self];
}

- (NSImage *)cachedImageOfSize:(NSSize)size
{
	if (cachedImage == nil || !NSEqualSizes(size, cachedImageSize)) {
		cachedImageSize = size;
		[cachedImage release];
		cachedImage = [[NSImage alloc] initWithSize:size];
		[cachedImage lockFocus];
		
		NSRect rect = NSMakeRect(0, 0, size.width, size.height);
		[self drawRect:rect withinRect:rect];
		
		[cachedImage unlockFocus];
	}
	return cachedImage;
}

- (void)drawRect:(NSRect)rect 
      withinRect:(NSRect)wholeRect 
   withTransform:(NSAffineTransform *) aTransform 
		onCanvas:(PXCanvas *) aCanvas
{
    //default behavior is to draw outside of the current transform.
    [aTransform invert];
    [aTransform concat];
	[[self cachedImageOfSize:wholeRect.size] drawInRect:rect fromRect:NSOffsetRect(rect, -1*wholeRect.origin.x, -1*wholeRect.origin.y) operation:NSCompositeCopy fraction:1];
    [aTransform invert];
    [aTransform concat];
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[self doesNotRecognizeSelector:@selector(drawRect:withinRect:)];
}

-(id) copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	[super init];
	[self setName:[coder decodeObjectForKey:@"name"]];
	[self configurator];
	return self;
}

@end

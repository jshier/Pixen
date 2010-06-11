//
//  PXAnimationPreview.m
//  PXAnimationPreview
//
//  Created by Ian Henderson on 09.08.05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXAnimationPreview.h"


@implementation PXAnimationPreview

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)refreshCurrentCel
{
	[currentCel release];
	currentCel = [[dataSource celAtIndex:currentIndex] retain];
	[self setNeedsDisplay:YES];
}

- (void)incrementFrame
{
	currentIndex++;
	if (currentIndex >= [dataSource numberOfCels]) {
		currentIndex = 0;
	}
	[self refreshCurrentCel];
}

- (IBAction)stepForward:sender
{
	[self pause:nil];
	[self incrementFrame];
}

- (IBAction)stepBackward:sender
{
	[self pause:nil];
	currentIndex--;
	if (currentIndex < 0) {
		currentIndex = [dataSource numberOfCels]-1;
	}
	[self refreshCurrentCel];
}

- (void)incrementFromTimer:(NSTimer *)timer
{
	[self incrementFrame];
	[animationTimer invalidate];
	[animationTimer release];
	animationTimer = [[NSTimer scheduledTimerWithTimeInterval:[dataSource durationOfCelAtIndex:currentIndex] target:self selector:@selector(incrementFromTimer:) userInfo:nil repeats:NO] retain];
}

- (void)stop
{
	[currentCel release];
	currentCel = nil;
	[self pause:nil];
	currentIndex = -1;
}

- (void)dealloc
{
	[currentCel release];
	[animationTimer invalidate];
	[animationTimer release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	if (currentCel == nil && dataSource != nil && [dataSource numberOfCels] > 0) {
		currentIndex = 0;
		currentCel = [dataSource celAtIndex:0];
	}
	
	NSSize mySize = [self frame].size;
	NSSize theirSize = [currentCel size];
	float myAspectRatio = mySize.height/mySize.width;
	float theirAspectRatio = theirSize.height/theirSize.width;
	NSRect aspectLockedRect;
	
	if (myAspectRatio > theirAspectRatio) {
		aspectLockedRect.size.width = mySize.width;
		aspectLockedRect.size.height = mySize.width*theirAspectRatio;
		aspectLockedRect.origin.x = 0;
		aspectLockedRect.origin.y = (mySize.height - aspectLockedRect.size.height) / 2.0f;
	} else {
		aspectLockedRect.size.width = mySize.height/theirAspectRatio;
		aspectLockedRect.size.height = mySize.height;
		aspectLockedRect.origin.x = (mySize.width - aspectLockedRect.size.width) / 2.0f;
		aspectLockedRect.origin.y = 0;
	}
	aspectLockedRect = NSInsetRect(aspectLockedRect, 1, 1);
	
	NSEraseRect(NSIntersectionRect(aspectLockedRect, rect));
	[[NSColor grayColor] set];
	NSRect frameRect = NSInsetRect(aspectLockedRect, -0.5, -0.5);
	/*frameRect.origin.x = floorf(NSMinX(frameRect));
	frameRect.origin.y = floorf(NSMinY(frameRect));
	frameRect.size.width = ceilf(NSWidth(frameRect));
	frameRect.size.height = ceilf(NSHeight(frameRect));*/
	NSFrameRect(frameRect);
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	[currentCel drawInRect:aspectLockedRect fromRect:NSMakeRect(0, 0, [currentCel size].width, [currentCel size].height) operation:NSCompositeSourceOver fraction:1];
}

- (void)setDataSource:ds
{
	dataSource = ds;
	[self stop];
}

- (void)reloadData
{
	[self stop];
	[self setNeedsDisplay:YES];
}

- (IBAction)play:sender
{
	[self willChangeValueForKey:@"isPlaying"];
	[self incrementFromTimer:nil];
	[self didChangeValueForKey:@"isPlaying"];
}

- (BOOL)isPlaying
{
	return (animationTimer != nil);
}

- (IBAction)pause:sender
{
	[self willChangeValueForKey:@"isPlaying"];
	[animationTimer invalidate];
	[animationTimer release];
	animationTimer = nil;
	[self didChangeValueForKey:@"isPlaying"];
}

- (IBAction)playPause:sender
{
	if ([self isPlaying]) {
		[self pause:sender];
	} else {
		[self play:sender];
	}
}

@end

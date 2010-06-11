//
//  PXPatternCell.m
//  Pixen
//
// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Created by Ian Henderson on 04.07.05.
//  Copyright (c) 2005 Open Sword Group. All rights reserved.
//

#import "PXPatternCell.h"
#import "PXPattern.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"
#import "PXNamePrompter.h"

@implementation PXPatternCell

- (id)init
{
	self = [super init];
	if (self != nil) {
		[self setEnabled:NO];
		[self setButtonType:NSPushOnPushOffButton];
	}
	return self;
}

- (PXPattern *)pattern
{
	return pattern;
}


- (void)setPattern:(PXPattern *)pat
{
	pattern = pat;
	[self setEnabled:YES];
}

- (NSSize)properSize
{
	return [self autoFrame].size;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] init];
}

- (int)margin
{
	return 5;
}

- (int)padding
{
	return 6;
}

- (NSRect)autoFrame
{
	return NSMakeRect(0,0,[self margin]*2+[self padding]*2+30,[self margin]*2+[self padding]*2+30+12);
}

- (NSRect)drawingBoundsForCellBounds:(NSRect)bounds
{
	return NSInsetRect(bounds, [self margin], [self margin]);
}

- (NSColor *)backgroundColor
{
	return (([self isHighlighted] || [self state] == NSOnState) ? [NSColor alternateSelectedControlColor] : [NSColor whiteColor]);
}

- (NSColor *)foregroundColor
{
	return (([self isHighlighted] || [self state] == NSOnState) ? [NSColor whiteColor] : [NSColor blackColor]);
}

- (void)drawSelectionIndicatorWithCellBounds:(NSRect)bounds
{
	NSBezierPath *roundedPath = [NSBezierPath bezierPathWithRoundedRect:[self drawingBoundsForCellBounds:bounds] cornerRadius:5];
	[[self backgroundColor] set];
	[roundedPath fill];
}

- (void)drawPatternImageWithCellBounds:(NSRect)bounds
{
	NSSize patternSize = [pattern size];
	
	NSSize mySize = NSInsetRect([self drawingBoundsForCellBounds:bounds], [self padding], [self padding]).size;
	mySize.height -= 12;
	float scale;
	if (mySize.height / patternSize.height < mySize.width / patternSize.width) {
		scale = mySize.height / patternSize.height;
	} else {
		scale = mySize.width / patternSize.width;
	}
	NSSize transformedPatternSize = NSMakeSize(patternSize.width * scale, patternSize.height * scale);
	
	NSPoint centeredOrigin = NSMakePoint(floorf((mySize.width - transformedPatternSize.width)/2), floorf((mySize.height - transformedPatternSize.height)/2));
	centeredOrigin.y += 12+[self margin]+[self padding];
	centeredOrigin.x += [self margin]+[self padding];
	
	NSRect imageRect = { centeredOrigin, transformedPatternSize };
	[[self backgroundColor] set];
	NSRectFill(imageRect);
	[[self foregroundColor] set];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy:centeredOrigin.x yBy:centeredOrigin.y];
	[transform scaleBy:scale];
	[transform concat];
	[pattern drawRect:NSMakeRect(0,0,[pattern size].width,[pattern size].height)];
	[transform invert];
	[transform concat];	
}

- (void)drawSizeTextWithCellBounds:(NSRect)bounds flipAgain:(BOOL)flipAgain
{
	NSString *sizeString = [NSString stringWithFormat:@"%dx%d", (int)[pattern size].width, (int)[pattern size].height];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
		[self foregroundColor], NSForegroundColorAttributeName,
		[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]], NSFontAttributeName,
		nil];
	NSAttributedString *attributedSizeString = [[[NSAttributedString alloc] initWithString:sizeString attributes:attributes] autorelease];
	NSPoint stringPos = NSMakePoint(floorf((NSWidth(bounds) - [attributedSizeString size].width) / 2), [self margin]+[self padding]-2);
	if (flipAgain) {
		stringPos.y += [attributedSizeString size].height;
		stringPos.y *= -1;
	}
	
	// text wants to be flipped again for some reason
	NSAffineTransform *flipAgainTransform = [NSAffineTransform transform];
	if (flipAgain) {
		[flipAgainTransform scaleXBy:1 yBy:-1];
		[flipAgainTransform concat];
	}
	[attributedSizeString drawAtPoint:stringPos];
	if (flipAgain) {
		[flipAgainTransform invert];
		[flipAgainTransform concat];
	}
}


- (void)drawWithCellBounds:(NSRect)bounds flipText:(BOOL)flipText
{
	[self drawSelectionIndicatorWithCellBounds:bounds];
	[self drawPatternImageWithCellBounds:bounds];
	[self drawSizeTextWithCellBounds:bounds flipAgain:flipText];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
	NSEraseRect(frame);
	
	if (pattern == nil) { return; }
	NSAffineTransform *frameOffset = [NSAffineTransform transform];
	
	// clip views' coordinate systems are usually flipped. for some reason.
	// inconsistency, hurrah! so correct our system.

	[frameOffset translateXBy:NSMinX(frame) yBy:NSMaxY(frame)];
	if ([view isFlipped])
	{	
		[frameOffset scaleXBy:1 yBy:-1];
	}
	[frameOffset concat];
	
	NSRect bounds = frame;
	bounds.origin = NSZeroPoint;
	[self drawWithCellBounds:bounds flipText:YES];
	[frameOffset invert];
	[frameOffset concat];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	dragOrigin = startPoint;
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	if (NSEqualPoints(dragOrigin, NSZeroPoint))
		dragOrigin = currentPoint;
	
	float xOffset = currentPoint.x - dragOrigin.x, yOffset = currentPoint.y - dragOrigin.y;
	float distance = sqrt(xOffset*xOffset + yOffset*yOffset);
	
	if (distance <= 5)
		return YES;
	
	NSImage *image = [[NSImage alloc] initWithSize:lastFrame.size];
	[image lockFocus];
	NSRect bounds = lastFrame;
	bounds.origin = NSZeroPoint;
	[self drawWithCellBounds:bounds flipText:NO];
	[image unlockFocus];
	NSImage *translucentImage = [[NSImage alloc] initWithSize:lastFrame.size];
	[translucentImage lockFocus];
	[image compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:.66];
	[translucentImage unlockFocus];
	
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pasteboard declareTypes:[NSArray arrayWithObjects:PXPatternPboardType,
		NSFilenamesPboardType,
		nil] owner:nil];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:pattern] forType:PXPatternPboardType];
	
	NSString *tempFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"Pattern"] stringByAppendingPathExtension:PXPatternSuffix];
	[NSKeyedArchiver archiveRootObject:pattern toFile:tempFile];
	[pasteboard setPropertyList:[NSArray arrayWithObject:tempFile] forType:NSFilenamesPboardType];
	
	NSPoint origin = lastFrame.origin;
	origin.y += NSHeight(lastFrame);
	[controlView dragImage:translucentImage at:origin offset:NSMakeSize(xOffset, yOffset) event:dragEvent pasteboard:pasteboard source:delegate slideBack:NO];
	dragOrigin = NSZeroPoint;
	[self setState:NSOnState];
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	dragOrigin = NSZeroPoint;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	if (pattern == nil) {
		return YES;
	}
	lastFrame = cellFrame;
	dragEvent = theEvent;
	[super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];	
	return YES;
}

- (void)setDelegate:d
{
	delegate = d;
}

@end

//
//  PXFilmStripView.m
//  PXFilmstrip
//
//  Created by Andy Matuschak on 8/9/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXFilmStripView.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

static int PXFilmStripIntercelSpacing = 10;
static int PXFilmStripVerticalPadding = 20;
static NSSize PXFilmStripSpokeHoleSize;
static int PXFilmStripSpokeHoleSpacing = 8;
static int PXFilmStripSpokeHoleEdgeTendency = 1; // By how much the spoke holes move towards the edge from being centered in the vertical padding
static int PXFilmStripPropertiesOffset = 15; // how far the properties (index & duration) are up from the bottom of the strip
static int PXFilmStripPropertiesHeight = 22;
static int PXFilmStripMinimumScaledCelWidth = 16; // this is the lowest for it to be even displayed
static int PXFilmStripMinimumScaledCelHeight = 16; // this is the lowest for it to be even displayed
static int PXFilmStripMinimumCelWidth = 50; // lower than this and it gets extra padding
static int PXFilmStripMaximumCelWidth = 200; // higher than this and it's scaled down some more

NSString *PXFilmStripSelectionDidChangeNotificationName = @"PXFilmStripSelectionDidChangeNotificationName";

@implementation PXFilmStripView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
	{
		selectedIndices = [[NSMutableIndexSet alloc] init];
		celRectsCount = 0;
		updateTimer = [[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(shouldUpdateDirtyRects:) userInfo:nil repeats:YES] retain];
		fieldCell = [[NSTextFieldCell alloc] initTextCell:@" "];
		[fieldCell setControlSize:NSMiniControlSize];
		[fieldCell setTextColor:[NSColor whiteColor]];
		[fieldCell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]]];
		[fieldCell setEditable:YES];
		targetDraggingIndex = -1;
		activeCelForField = -1;
		gonnaBeDeleted = -1;
        PXFilmStripSpokeHoleSize = NSMakeSize(6.0, 9.0);
	}
    return self;
}

- (void)dealloc
{
	[self setDelegate:nil];
	[self setDataSource:nil];
	[spokeHoleCache release];
	[selectedIndices release];
	if (celRects) {
		free(celRects);
	}
	if (celTrackingTags) {
		free(celTrackingTags);
	}
	if (closeButtonTrackingTags) {
		free(closeButtonTrackingTags);
	}
	if (updateTimer) {
		[updateTimer invalidate];
		[updateTimer release];
	}
	[super dealloc];
}

- (NSRect)closeButtonRectForCelIndex:(NSUInteger)index
{
	if (index >= celRectsCount || index < 0) { return NSZeroRect; }
	NSRect celRect = celRects[index];
	float offset = 4;
	float minWidthHeight = MIN(NSWidth(celRect), NSHeight(celRect));
	if (minWidthHeight / 100.0f < offset) {
		offset = minWidthHeight / 100.0f;
	}
	if (offset < 2) {
		offset = 2;
	}
	NSRect closeButtonRect = NSMakeRect(offset,-offset,12,12);
	closeButtonRect.origin.x += NSMinX(celRect);
	closeButtonRect.origin.y += NSMaxY(celRect) - NSHeight(closeButtonRect);
	return closeButtonRect;
}

- (NSRect)fieldCellRectForCelIndex:(NSUInteger)index editing:(BOOL)editing
{
	NSAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:[fieldCell stringValue] attributes:[NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]] forKey:NSFontAttributeName]] autorelease];
	if (index >= celRectsCount) { return NSZeroRect; }
	return NSMakeRect(NSMidX(celRects[index]) - ((editing) ? 50/2 : (MIN([string size].width,50)/2)) + ((editing) ? 0 : 0), PXFilmStripPropertiesOffset + ((editing) ? 2 : 0), 50, 16);
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)setDataSource:newDataSource
{
	dataSource = newDataSource;
	[self reloadData];
	[self setNeedsDisplay:YES];
	if ([dataSource respondsToSelector:@selector(draggedTypesForFilmStripView:)]) {
		[self registerForDraggedTypes:[dataSource draggedTypesForFilmStripView:self]];
	}
}

- (void)awakeFromNib
{
	if ([dataSource respondsToSelector:@selector(draggedTypesForFilmStripView:)]) {
		[self registerForDraggedTypes:[dataSource draggedTypesForFilmStripView:self]];
	}
}

- (void)setDelegate:newDelegate
{
	if (delegate)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:delegate name:PXFilmStripSelectionDidChangeNotificationName object:self];
	}
	delegate = newDelegate;
	if([delegate respondsToSelector:@selector(filmStripSelectionDidChange:)])
	{
		[[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(filmStripSelectionDidChange:) name:PXFilmStripSelectionDidChangeNotificationName object:self];		
	}
}

- (void)reloadData
{
	NSUInteger numberOfCels = [dataSource numberOfCels];
	if (numberOfCels == 0)
	{
		[self setFrame:(NSRect){ NSZeroPoint, [[self enclosingScrollView] contentSize] }];
		return;
	}

	// Here we assume that all cels have the same size.
	NSSize celSize = [[dataSource celAtIndex:0] size];
	float newCelHeight = NSHeight([self bounds]) - PXFilmStripVerticalPadding - PXFilmStripPropertiesOffset - PXFilmStripPropertiesHeight;
	float scalingRatio = newCelHeight / celSize.height;
	celSize.height = newCelHeight;
	celSize.width *= scalingRatio;
	
	NSPoint celOffset = NSZeroPoint;
	float extraSpacing = 0;
	
	if (celSize.width > PXFilmStripMaximumCelWidth) {
		float newCelWidth = PXFilmStripMaximumCelWidth;
		newCelHeight = celSize.height * newCelWidth / celSize.width;
		celOffset.y -= (celSize.height - newCelHeight) / 2.0f;
		celSize.height = newCelHeight;
		celSize.width = newCelWidth;
	}
	
	if (celSize.width < PXFilmStripMinimumCelWidth) {
		celOffset.x += (PXFilmStripMinimumCelWidth - celSize.width) / 2.0f;
		extraSpacing += (PXFilmStripMinimumCelWidth - celSize.width);
	}
	
	float widthPerCel = celSize.width + PXFilmStripIntercelSpacing + extraSpacing;
	float width = PXFilmStripIntercelSpacing + widthPerCel * numberOfCels;
	//NSLog(@"%f", [[self enclosingScrollView] contentSize].height);
	[self setFrame:(NSRect){ NSZeroPoint, { MAX(width, [[self enclosingScrollView] contentSize].width), [[self enclosingScrollView] contentSize].height } }];
	
	free(celRects);
	celRects = malloc(sizeof(NSRect) * numberOfCels);
	free(celTrackingTags);
	free(closeButtonTrackingTags);
	celTrackingTags = malloc(sizeof(NSTrackingRectTag) * numberOfCels);
	closeButtonTrackingTags = malloc(sizeof(NSTrackingRectTag) * numberOfCels);
	
	int i;
	for (i = 0; i < celRectsCount; i++)
	{
		[self removeTrackingRect:celTrackingTags[i]];
		[self removeTrackingRect:closeButtonTrackingTags[i]];
	}
	for (i = 0; i < numberOfCels; i++)
	{
		celRects[i] = NSMakeRect(celOffset.x + PXFilmStripIntercelSpacing + widthPerCel * i, celOffset.y + NSHeight([self bounds]) - celSize.height - PXFilmStripVerticalPadding, celSize.width, celSize.height);
		celTrackingTags[i] = [self addTrackingRect:celRects[i] owner:self userData:NULL assumeInside:NO];
		closeButtonTrackingTags[i] = [self addTrackingRect:[self closeButtonRectForCelIndex:i] owner:self userData:NULL assumeInside:NO];
	}
	celRectsCount = numberOfCels;
	[self setNeedsDisplay:YES];
}

- (void)resetCursorRects
{
	int i;
	for (i = 0; i < celRectsCount; i++)
	{
		[self removeTrackingRect:celTrackingTags[i]];
		[self removeTrackingRect:closeButtonTrackingTags[i]];
		celTrackingTags[i] = [self addTrackingRect:celRects[i] owner:self userData:NULL assumeInside:NO];
		closeButtonTrackingTags[i] = [self addTrackingRect:[self closeButtonRectForCelIndex:i] owner:self userData:NULL assumeInside:NO];
	}
}

- (NSImage *)spokeHoleImage
{
	if (!spokeHoleCache) {
		NSRect spokeHoleRect = (NSRect){NSZeroPoint, PXFilmStripSpokeHoleSize};
		spokeHoleCache = [[NSImage alloc] initWithSize:spokeHoleRect.size];
		[spokeHoleCache lockFocus];
		
		NSBezierPath *spokeHole = [NSBezierPath bezierPathWithRoundedRect:spokeHoleRect cornerRadius:2];
		[[NSGraphicsContext currentContext] saveGraphicsState];
		[spokeHole setClip];
		[[NSColor whiteColor] set];
		[spokeHole fill];
		NSBezierPath *invertedHole = [NSBezierPath bezierPathWithRect:NSMakeRect(-PXFilmStripSpokeHoleSpacing/2, -PXFilmStripVerticalPadding/2, PXFilmStripSpokeHoleSpacing + PXFilmStripSpokeHoleSize.width, PXFilmStripVerticalPadding*2)];
		[invertedHole appendBezierPath:spokeHole];
		[invertedHole setWindingRule:NSEvenOddWindingRule];
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowColor:[NSColor darkGrayColor]];
		[shadow setShadowBlurRadius:3];
		[shadow setShadowOffset:NSMakeSize(2, -2)];
		[shadow set];
		[[NSColor blackColor] set];
		[invertedHole fill];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
		
		[spokeHoleCache unlockFocus];
	}
	return spokeHoleCache;
}

- (void)drawSpokeHoleAtPoint:(NSPoint)point
{
	[[self spokeHoleImage] drawAtPoint:point fromRect:(NSRect){NSZeroPoint, [spokeHoleCache size]} operation:NSCompositeSourceOver fraction:1];
}

- (void)drawSpokeHolesForRect:(NSRect)rect
{
	rect.origin.x -= PXFilmStripSpokeHoleSpacing;
	int firstSpokeIndex = floorf(NSMinX(rect) / (PXFilmStripSpokeHoleSize.width + PXFilmStripSpokeHoleSpacing));
	int lastSpokeIndex = ceilf(NSMaxX(rect) / (PXFilmStripSpokeHoleSize.width + PXFilmStripSpokeHoleSpacing));
	int i;
	float lowerHoleY = (PXFilmStripVerticalPadding - PXFilmStripSpokeHoleSize.height) / 2;
	float upperHoleY = NSHeight([self bounds]) - lowerHoleY - PXFilmStripSpokeHoleSize.height;
	for (i = firstSpokeIndex; i < lastSpokeIndex; i++)
	{
		[self drawSpokeHoleAtPoint:NSMakePoint(PXFilmStripSpokeHoleSpacing + (PXFilmStripSpokeHoleSize.width + PXFilmStripSpokeHoleSpacing) * i, lowerHoleY - PXFilmStripSpokeHoleEdgeTendency)];
		[self drawSpokeHoleAtPoint:NSMakePoint(PXFilmStripSpokeHoleSpacing + (PXFilmStripSpokeHoleSize.width + PXFilmStripSpokeHoleSpacing) * i, upperHoleY + PXFilmStripSpokeHoleEdgeTendency)];
	}
}

- (void)drawCloseButtonAtIndex:(NSUInteger)index highlighted:(BOOL)highlighted pressed:(BOOL)pressed
{
	NSRect bounds = [self closeButtonRectForCelIndex:index];
	NSColor *circleColor = [NSColor colorWithDeviceWhite:.86 alpha:1];
	NSColor *xColor = [NSColor colorWithDeviceWhite:.5 alpha:1];
	if (pressed) {
		circleColor = [NSColor colorWithDeviceWhite:.48 alpha:1];
		xColor = [NSColor colorWithDeviceWhite:.14 alpha:1];
	} else if (highlighted) {
		circleColor = [NSColor colorWithDeviceWhite:.86 alpha:1];
		xColor = [NSColor colorWithDeviceWhite:.24 alpha:1];
	}
	[circleColor set];
	[[NSBezierPath bezierPathWithOvalInRect:bounds] fill];
	NSRect xBounds = NSInsetRect(bounds, 3, 3);
	[xColor set];
	[NSBezierPath setDefaultLineWidth:2];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(xBounds), NSMinY(xBounds)) toPoint:NSMakePoint(NSMaxX(xBounds), NSMaxY(xBounds))];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(xBounds), NSMaxY(xBounds)) toPoint:NSMakePoint(NSMaxX(xBounds), NSMinY(xBounds))];
}

- (void)badgeCelAtIndex:(NSUInteger)index
{
	int fontSize = [NSFont systemFontSizeForControlSize:NSMiniControlSize];
	if (index > 9999)
		fontSize = floorf(fontSize * .85);
	
	NSMutableAttributedString *badgeString = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", index + 1]
																	   attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithDeviceWhite:0 alpha:0.75], NSForegroundColorAttributeName, [NSFont systemFontOfSize:fontSize], NSFontAttributeName, nil]] autorelease];
	
	// Exceuse me for my mdrfkr hardcoded numbers.
	NSSize badgeSize = [badgeString size];
	badgeSize.width += 6.5;
	badgeSize.height += 1;
	NSRect badgeRect = NSMakeRect(NSMaxX(celRects[index]) - floorf(badgeSize.width), NSMinY(celRects[index]), badgeSize.width, badgeSize.height);
	NSBezierPath *indexBadge = [NSBezierPath bezierPathWithRoundedRect:badgeRect cornerRadius:5 inCorners:OSTopLeftCorner];
	[[[NSColor grayColor] colorWithAlphaComponent:0.75] set];
	[indexBadge fill];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	NSRectClip(NSOffsetRect(badgeRect, -0.5, 0.5));
	[[[NSColor lightGrayColor] colorWithAlphaComponent:1] set];
	[indexBadge stroke];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	// Draw the shadow of the string first.
	[badgeString drawAtPoint:NSMakePoint(NSMaxX(celRects[index]) - badgeSize.width + 4.5, NSMinY(celRects[index]) + 
										 ((index > 9999) ? -1 : 0))];
	
	// Make it white and then draw the string itself.
	[badgeString setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:fontSize], NSFontAttributeName, nil] range:NSMakeRange(0, [badgeString length])];
	[badgeString drawAtPoint:NSMakePoint(NSMaxX(celRects[index]) - badgeSize.width + 4.5, NSMinY(celRects[index]) + 
										 ((index > 9999) ? 0 : 1))];	
	
}

- (CGFloat)minimumHeight
{
	if (!celRectsCount) { return 0; }
	float aspectRatio = NSHeight(celRects[0]) / NSWidth(celRects[0]);
	float minimumCelHeight = MAX(PXFilmStripMinimumScaledCelWidth * aspectRatio, PXFilmStripMinimumScaledCelHeight);
	float minimumHeight =  minimumCelHeight + PXFilmStripVerticalPadding + PXFilmStripPropertiesOffset + PXFilmStripPropertiesHeight;
	if ([self enclosingScrollView])
	{
		minimumHeight += NSHeight([[[self enclosingScrollView] horizontalScroller] frame]);
	}
	return minimumHeight;
}

- (void)drawRect:(NSRect)rect
{
	NSUInteger i;
	NSUInteger numberOfCels = [dataSource numberOfCels];

	for (i = 0; i < numberOfCels; i++)
	{
		[fieldCell setStringValue:[NSString stringWithFormat:@"%3.3f s", [[dataSource celAtIndex:i] duration]]];
		[fieldCell drawWithFrame:[self fieldCellRectForCelIndex:i editing:(activeCelForField != -1)] inView:self];
		
		if (!NSIntersectsRect(rect, celRects[i])) { continue; }
		
		id currentCel = [dataSource celAtIndex:i];
		NSSize celSize = [currentCel size];
		
		NSBezierPath *roundedPath = [NSBezierPath bezierPathWithRect:celRects[i]];
		[[NSColor whiteColor] set];
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowColor:[NSColor blackColor]];
		[shadow setShadowBlurRadius:6];
		[shadow setShadowOffset:NSMakeSize(0, -1)];
		[[NSGraphicsContext currentContext] saveGraphicsState];
		[shadow set];
		[roundedPath fill];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
		
		[currentCel drawInRect:celRects[i] fromRect:NSMakeRect(0,0,celSize.width,celSize.height) operation:NSCompositeSourceOver fraction:1];
		
		if ([selectedIndices containsIndex:i])
		{
			[[NSGraphicsContext currentContext] saveGraphicsState];
			NSSetFocusRingStyle(NSFocusRingOnly);
			NSRectFill(celRects[i]);
			[[NSGraphicsContext currentContext] restoreGraphicsState];
		}
		
		[self badgeCelAtIndex:i];
		
		if (NSPointInRect(mouseLocation, celRects[i])) {
			BOOL highlighted = NSPointInRect(mouseLocation, [self closeButtonRectForCelIndex:i]);
			[self drawCloseButtonAtIndex:i highlighted:highlighted pressed:(gonnaBeDeleted == i)];
		}
		
		//[shadowTitleString drawAtPoint:NSMakePoint((NSMaxX(titleBarRect) - [titleString size].width) / 2, NSMinY(titleBarRect) + 1)];
		//[titleString drawAtPoint:NSMakePoint((NSMaxX(titleBarRect) - [titleString size].width) / 2, NSMinY(titleBarRect) + 2)];
		
		NSRect insertionRect = NSZeroRect;
		
		if (i == targetDraggingIndex) {
			insertionRect = celRects[i];
			insertionRect.origin.x -= PXFilmStripIntercelSpacing / 2 + 0.5;
		}
		if (i + 1 == numberOfCels && i + 1 == targetDraggingIndex) {
			insertionRect = celRects[i];
			insertionRect.origin.x += PXFilmStripIntercelSpacing / 2 + 0.5 + NSWidth(celRects[i]);
		}
		if (!NSEqualRects(insertionRect, NSZeroRect)) {
			insertionRect.size.width = 2;
			insertionRect.origin.y -= 0.5;
			insertionRect.size.height += 1;
			NSRect frunkaFrunkaRect = insertionRect;
			frunkaFrunkaRect.size.width = frunkaFrunkaRect.size.height = 6;
			frunkaFrunkaRect.origin.x -= 2;
			frunkaFrunkaRect.origin.y -= 4;
			NSBezierPath *frunkaFrunka = [NSBezierPath bezierPathWithRect:insertionRect];
			[frunkaFrunka appendBezierPathWithOvalInRect:frunkaFrunkaRect];
			
			[[NSColor whiteColor] set];
			[frunkaFrunka fill];
		}
	}
	
	[self drawSpokeHolesForRect:rect];
}

- (void)shouldUpdateDirtyRects:timer
{
	if (NSIsEmptyRect(updateRect)) { return; }
	[self setNeedsDisplayInRect:updateRect];
	updateRect = NSZeroRect;
}

- (void)setNeedsDelayedDisplayInRect:(NSRect)rect
{
	if (NSIsEmptyRect(updateRect))
		updateRect = rect;
	else
		updateRect = NSUnionRect(updateRect, rect);	
}

- (void)textDidBeginEditing:note
{
	[[note object] selectAll:self];
	[[self window] makeFirstResponder:[note object]];
}

- (void)textDidEndEditing:note
{
	[fieldCell setDrawsBackground:NO];
	[fieldCell setBezeled:NO];
	[fieldCell setTextColor:[NSColor whiteColor]];
	[[dataSource celAtIndex:activeCelForField] setDuration:[[[note object] string] floatValue]];
	[fieldCell endEditing:[note object]];
	activeCelForField = -1;
	[self setNeedsDisplayInRect:NSInsetRect([self fieldCellRectForCelIndex:activeCelForField editing:YES], -6, -6)];
}

- (void)keyDown:(NSEvent *)event
{
	if ([[event characters] characterAtIndex:0] == NSLeftArrowFunctionKey)
	{
		NSUInteger numberOfCels = [dataSource numberOfCels];
		if (numberOfCels <= 1) { NSBeep(); return; }
		NSInteger newIndex = [self selectedIndex];
		if (newIndex == NSNotFound) { NSBeep(); return; }
		newIndex--;
		if (newIndex < 0)
			newIndex = numberOfCels - 1;
		[self selectCelAtIndex:newIndex byExtendingSelection:NO];
	}
	else if ([[event characters] characterAtIndex:0] == NSRightArrowFunctionKey)
	{
		NSUInteger numberOfCels = [dataSource numberOfCels];
		if (numberOfCels <= 1) { NSBeep(); return; }
		NSUInteger newIndex = [self selectedIndex];
		if (newIndex == NSNotFound) { NSBeep(); return; }
		newIndex++;
		if (newIndex >= numberOfCels)
			newIndex = 0;		
		[self selectCelAtIndex:newIndex byExtendingSelection:NO];
	}
	else if ([[event characters] isEqualToString: @"\177"] || ([[event characters] characterAtIndex:0] == NSDeleteFunctionKey))
	{
		[delegate deleteCelsAtIndices:[self selectedIndices]];
	}
	else
	{
		[[self nextResponder] keyDown:event];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if (gonnaBeDeleted != -1 && NSPointInRect([self convertPoint:[event locationInWindow] fromView:nil], [self closeButtonRectForCelIndex:gonnaBeDeleted])) {
		[dataSource deleteCelsAtIndices:[NSIndexSet indexSetWithIndex:gonnaBeDeleted]];
	}
	NSInteger index = gonnaBeDeleted;
	gonnaBeDeleted = -1;
	[self setNeedsDisplayInRect:[self closeButtonRectForCelIndex:index]];
}

- (void)mouseDown:(NSEvent *)event
{
	// This could be faster if it needs to be by actually finding out candidates for the hit using some fancy math.
	NSUInteger numberOfCels = [dataSource numberOfCels];
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	NSIndexSet *oldSet = [[selectedIndices copy] autorelease];
	int i;
	for (i = 0; i < numberOfCels; i++)
	{
		// For the duration editor thing
		if ([event clickCount] >= 2)
		{
			if (!NSPointInRect(location, [self fieldCellRectForCelIndex:i editing:NO])) { continue; }
			activeCelForField = i;
			[fieldCell setStringValue:[NSString stringWithFormat:@"%3.3f", [[dataSource celAtIndex:i] duration]]];
			[fieldCell setBezeled:YES];
			[fieldCell setDrawsBackground:YES];
			[fieldCell setTextColor:[NSColor blackColor]];
			[fieldCell editWithFrame:[self fieldCellRectForCelIndex:i editing:YES] inView:self editor:[[self window] fieldEditor:YES forObject:fieldCell] delegate:self event:event];
			break;
		}
		if (!NSPointInRect(location, celRects[i])) { continue; }
		if (NSPointInRect(location, [self closeButtonRectForCelIndex:i])) {
			gonnaBeDeleted = i;
			[self setNeedsDisplayInRect:[self closeButtonRectForCelIndex:i]];
			break;
		}
		NSRect redrawRect = NSInsetRect(celRects[i], -5, -5);
		NSUInteger modifierFlags = [event modifierFlags];
		if (modifierFlags & NSCommandKeyMask && allowsMultipleSelection)
		{
			if ([selectedIndices containsIndex:i])
				[selectedIndices removeIndex:i];
			else
				[selectedIndices addIndex:i];
		}
		else if (modifierFlags & NSShiftKeyMask && allowsMultipleSelection)
		{
			if (![selectedIndices count])
				[selectedIndices addIndex:i];
			else
			{
				if (i < [selectedIndices firstIndex])
					[selectedIndices addIndexesInRange:NSMakeRange(i, [selectedIndices firstIndex])];
				else if ([selectedIndices lastIndex] < i)
					[selectedIndices addIndexesInRange:NSMakeRange([selectedIndices firstIndex], i)];
				redrawRect = NSInsetRect(NSUnionRect(celRects[[selectedIndices firstIndex]], celRects[[selectedIndices lastIndex]]), -5, -5);
			}
		}
		else
		{
			if ([selectedIndices count])
			{
				NSUInteger currentIndex = [selectedIndices firstIndex];
				do
				{
					redrawRect = NSUnionRect(redrawRect, NSInsetRect(celRects[currentIndex], -5, -5));
				} while ((currentIndex = [selectedIndices indexGreaterThanIndex:currentIndex]) != NSNotFound);
			}
			[selectedIndices removeAllIndexes];
			[selectedIndices addIndex:i];
		}
		[self setNeedsDisplayInRect:redrawRect];
		break;
	}
	if (![oldSet isEqualTo:selectedIndices])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PXFilmStripSelectionDidChangeNotificationName object:self];
	}
	dragOrigin = location;
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
	// This could be faster if it needs to be by actually finding out candidates for the hit using some fancy math.
	NSUInteger numberOfCels = [dataSource numberOfCels];
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];	
	int i;
	for (i = 0; i < numberOfCels; i++)
	{
		if (!NSPointInRect(location, celRects[i])) { continue; }
		[self selectCelAtIndex:i byExtendingSelection:NO];
		NSMenu *menu = [[NSMenu alloc] init];
		[menu addItemWithTitle:NSLocalizedString(@"COPY_CEL", @"Copy") action:@selector(copyCel:) keyEquivalent:@""];
		[menu addItemWithTitle:NSLocalizedString(@"CUT_CEL", @"Cut") action:@selector(cutCel:) keyEquivalent:@""];
		[menu addItemWithTitle:NSLocalizedString(@"DELETE_CEL", @"Delete") action:@selector(deleteCel:) keyEquivalent:@""];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItemWithTitle:NSLocalizedString(@"DUPLICATE_CEL", @"Duplicate") action:@selector(duplicateCel:) keyEquivalent:@""];
		return menu;
	}
	return nil;
}

- (void)mouseEntered:(NSEvent *)event
{
	mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	int i;
	NSTrackingRectTag trackingNumber = [event trackingNumber];
	for (i=0; i<celRectsCount; i++) {
		if (trackingNumber == celTrackingTags[i] || trackingNumber == closeButtonTrackingTags[i]) {
			[self setNeedsDisplayInRect:[self closeButtonRectForCelIndex:i]];
			break;
		}
	}
}

- (void)mouseExited:(NSEvent *)event
{
	[self mouseEntered:event];
}

- (void)mouseDragged:(NSEvent *)event
{
	if (gonnaBeDeleted != -1) {
		return;
	}
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	float xOffset = location.x - dragOrigin.x, yOffset = location.y - dragOrigin.y;
	float distance = sqrt(xOffset*xOffset + yOffset*yOffset);
	if (distance <= 5)
		return;
	
	if ([selectedIndices count] > 1) {
		[[NSException exceptionWithName:@"PXIanIsLazyException" reason:@"Ian is too lazy to make dragging work with multiple selection!" userInfo:nil] raise];
		return;
	}
	if ([selectedIndices count] < 1) {
		return; // something should be selected
	}
	NSUInteger index = [selectedIndices firstIndex];
	id cel = [dataSource celAtIndex:index];
	NSSize realCelSize = [cel size];
	NSRect celRect = celRects[index];
	NSRect imageRect = NSMakeRect(5,5,NSWidth(celRect),NSHeight(celRect));
	NSImage *celImage = [[[NSImage alloc] initWithSize:NSMakeSize(NSWidth(celRect) + 10, NSHeight(celRect) + 10)] autorelease];
	NSImage *translucentCelImage = [[[NSImage alloc] initWithSize:NSMakeSize(NSWidth(celRect) + 10, NSHeight(celRect) + 10)] autorelease];
	
	[celImage lockFocus];
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor blackColor]];
	[shadow setShadowBlurRadius:6];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[shadow set];
	NSEraseRect(imageRect);
	[[NSGraphicsContext currentContext] restoreGraphicsState];

	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	[cel drawInRect:imageRect fromRect:NSMakeRect(0,0,realCelSize.width,realCelSize.height) operation:NSCompositeSourceOver fraction:1];
	[celImage unlockFocus];
	[translucentCelImage lockFocus];
	[celImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:0.66];
	[translucentCelImage unlockFocus];
	
    NSPasteboard *pboard;
    pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	if ([dataSource respondsToSelector:@selector(writeCelsAtIndices:toPasteboard:)]) {
		[dataSource writeCelsAtIndices:selectedIndices toPasteboard:pboard];
	}
	[self dragImage:translucentCelImage at:celRect.origin offset:NSMakeSize(xOffset, yOffset) event:event pasteboard:pboard source:self slideBack:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	BOOL success = NO;
	BOOL shouldReload = NO;
	NSIndexSet *oldSet = [[selectedIndices copy] autorelease];
	if ([selectedIndices count] > 1) {
		[[NSException exceptionWithName:@"PXIanIsLazyException" reason:@"Ian is too lazy to make dragging work with multiple selection!" userInfo:nil] raise];
	}
	if ([selectedIndices count] < 1) {
		targetDraggingIndex = -1;
	}
	if (targetDraggingIndex >= 0) {
		if ([sender draggingSource] == self) {
			if ([sender draggingSourceOperationMask] == NSDragOperationCopy) {
				shouldReload = YES;
				if ([dataSource respondsToSelector:@selector(copyCelInFilmStripView:atIndex:toIndex:)]) {
					success = [dataSource copyCelInFilmStripView:self atIndex:[selectedIndices firstIndex] toIndex:targetDraggingIndex];
				}
			} else {
				if ([dataSource respondsToSelector:@selector(moveCelInFilmStripView:fromIndex:toIndex:)]) {
					success = [dataSource moveCelInFilmStripView:self fromIndex:[selectedIndices firstIndex] toIndex:targetDraggingIndex];
				}
				if (success) {
					if (targetDraggingIndex > [selectedIndices firstIndex]) {
						targetDraggingIndex--;
					}
					[selectedIndices removeAllIndexes];
					[selectedIndices addIndex:targetDraggingIndex];
				}
			}
		} else {
			shouldReload = YES;
			if ([dataSource respondsToSelector:@selector(insertCelIntoFilmStripView:fromPasteboard:atIndex:)]) {
				success = [dataSource insertCelIntoFilmStripView:self fromPasteboard:[sender draggingPasteboard] atIndex:targetDraggingIndex];
			}
		}
		targetDraggingIndex = -1;
	}
	if (success && shouldReload) {
		[self reloadData];
		if (targetDraggingIndex < [selectedIndices firstIndex]) {
			NSUInteger newIndex = [selectedIndices firstIndex] + 1;
			[selectedIndices removeAllIndexes];
			[selectedIndices addIndex:newIndex];
		}
	}
	if (![oldSet isEqualTo:selectedIndices])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PXFilmStripSelectionDidChangeNotificationName object:self];
	}
	[self setNeedsDisplayInRect:[self visibleRect]];
	return success;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	NSPoint location = [self convertPoint:[sender draggingLocation] fromView:nil];
	NSUInteger lastTargetDraggingIndex = targetDraggingIndex;
	targetDraggingIndex = 0;
	int i;
	for (i=0; i<celRectsCount; i++) {
		if (location.x > NSMidX(celRects[i])) {
			targetDraggingIndex = i+1;
		}
	}
	if (lastTargetDraggingIndex != targetDraggingIndex) {
		[self setNeedsDisplayInRect:[self visibleRect]];
	}
	if ([sender draggingSource] == self) {
		if ([sender draggingSourceOperationMask] == NSDragOperationCopy) {
			return NSDragOperationCopy;
		} else {
			return NSDragOperationMove;
		}
	} else {
		return NSDragOperationCopy;
	}
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	targetDraggingIndex = -1;
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return [self draggingUpdated:sender];
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal) {
		return (NSDragOperationMove | NSDragOperationCopy);
	} else {
		return NSDragOperationCopy;
	}
}

- (NSUInteger)selectedIndex
{
	return [selectedIndices firstIndex];
}

- selectedCel
{
	NSUInteger index = [self selectedIndex];
	return (index == NSNotFound) ? nil : [dataSource celAtIndex:index];
}

- (NSIndexSet *)selectedIndices
{
	return [[[NSIndexSet alloc] initWithIndexSet:selectedIndices] autorelease];
}

- (NSArray *)selectedCels
{
	if (![selectedIndices count]) { return nil; }
	NSMutableArray *tempCels = [[[NSMutableArray alloc] init] autorelease];
	NSUInteger currentIndex = [selectedIndices firstIndex];
	do
	{
		[tempCels addObject:[dataSource celAtIndex:currentIndex]];
	} while ((currentIndex = [selectedIndices indexGreaterThanIndex:currentIndex]) != NSNotFound);
	return [NSArray arrayWithArray:tempCels];
}

- (void)selectCelAtIndex:(NSUInteger)index byExtendingSelection:(BOOL)extend
{
	BOOL same = [selectedIndices containsIndex:index] && ([selectedIndices count] == 1);
	if (index < celRectsCount)
	{
		NSRect redrawRect = NSInsetRect(celRects[index], -5, -5);
		if(!extend)
		{
			if ([selectedIndices count])
			{
				NSUInteger currentIndex = [selectedIndices firstIndex];
				do
				{
					redrawRect = NSUnionRect(redrawRect, NSInsetRect(celRects[currentIndex], -5, -5));
				} while ((currentIndex = [selectedIndices indexGreaterThanIndex:currentIndex]) != NSNotFound);
			}
		}
		[self setNeedsDisplayInRect:redrawRect];

	}
	
	if (!extend) { [selectedIndices removeAllIndexes]; }
	[selectedIndices addIndex:index];
	
	if(!same)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PXFilmStripSelectionDidChangeNotificationName object:self];
	}
}

- (void)setAllowsMultipleSelection:(BOOL)newAllows
{
	if (!newAllows)
	{
		NSUInteger firstIndex = [selectedIndices firstIndex];
		[selectedIndices removeAllIndexes];
		if (firstIndex != NSNotFound)
			[selectedIndices addIndex:firstIndex];
		[self setNeedsDisplayInRect:[self visibleRect]];
	}
	allowsMultipleSelection = newAllows;
}

- (NSRect)rectOfCelIndex:(NSUInteger)index
{
	if (index >= [dataSource numberOfCels] || index >= celRectsCount) { return NSZeroRect; }
	return celRects[index];
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[super resizeWithOldSuperviewSize:size];
	[self reloadData];
}

@end

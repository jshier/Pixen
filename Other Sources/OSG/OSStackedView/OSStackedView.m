//
//  OSStackedView.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.04.

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

#import "OSStackedView.h"
@class OSStackedViewElement;

@interface NSObject(OSStackedViewElementDelegate)
- (void)stackedViewElement:(OSStackedViewElement *)elem clickedBy:(NSEvent *)event;
- (void)stackedViewElement:(OSStackedViewElement *)elem doubleClickedBy:(NSEvent *)event;
- (void)stackedViewElement:(OSStackedViewElement *)elem draggedBy:(NSEvent *)event;
- (void)stackedViewElement:(OSStackedViewElement *)elem receivedKeyDown:(NSEvent *)event;
@end

@interface NSView(OSStackedViewElementView)
- (void)setHighlighted:(BOOL)highlighted;
@end

@implementation NSView(OSStackedViewElementView)
- (void)setHighlighted:(BOOL)highlighted {}
@end

@interface OSStackedViewElement : NSView
{
	NSView *view;
	OSStackedView *stackedView;
	BOOL isHighlighted;
	
	NSPoint dragOrigin;
}
+ containingView:(NSView *)aView;
- initWithView:(NSView *)aView;
- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)highlighted;
- (void)setFrameSize:(NSSize)size;
- (void)setFrame:(NSRect)frameRect;
- (void)removeFromSuperview;
- (NSView *)view;
- (void)setStackedView:(OSStackedView *)stack;
@end

@implementation OSStackedViewElement

+ containingView:(NSView *)aView
{
	return [[[self alloc] initWithView:aView] autorelease];
}

- initWithView:(NSView *)aView
{
	self = [self initWithFrame:[aView frame]];
	if(self)
	{
		view = aView;
		[self addSubview:view];
	}
	return self;
}

- (void)setFrameSize:(NSSize)size
{
	[super setFrameSize:size];
	[view setFrameSize:NSMakeSize(NSWidth([self frame]) + 2, NSHeight([view frame]))];
}

- (void)setFrame:(NSRect)frameRect
{
	[super setFrame:frameRect];
	[view setFrameSize:NSMakeSize(NSWidth([self frame]) + 2, NSHeight([view frame]))];
}

- (void)removeFromSuperview
{
	[view removeFromSuperview];
	[super removeFromSuperview];
}

- (NSView *)view
{
	return view;
}

- (void)setStackedView:(OSStackedView *)stack
{
	stackedView = stack;
	[self setFrameSize:NSMakeSize(NSWidth([stack bounds]), NSHeight([self frame]))];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	[self setNeedsDisplay:YES];
	return YES;
}

- (BOOL)resignFirstResponder
{
	[self setNeedsDisplay:YES];
	return YES;
}

- (void)mouseDown:event
{
	[stackedView stackedViewElement:self clickedBy:event];
	if([event clickCount] == 2)
	{
		[stackedView stackedViewElement:self doubleClickedBy:event];
	}
	dragOrigin = [event locationInWindow];
}

- (void)keyDown:event
{
	[stackedView stackedViewElement:self receivedKeyDown:event];
}

- (BOOL)isHighlighted
{
	return isHighlighted;
}

- (void)setHighlighted:(BOOL)highlighted
{
	isHighlighted = highlighted;
	[view setHighlighted:highlighted];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	if(isHighlighted)
	{
		[view setHighlighted:NO];
		NSColor *color = [NSColor secondarySelectedControlColor];
		if([[self window] firstResponder] == self &&
		   [[self window] isKeyWindow])
		{
			color = [NSColor alternateSelectedControlColor];
			[view setHighlighted:YES];
		}
		[color set];
		NSRectFill(rect);
	}
}

- (void)mouseDragged:(NSEvent *)event
{
	NSPoint location = [event locationInWindow];
	float xOffset = location.x - dragOrigin.x, yOffset = location.y - dragOrigin.y;
	float distance = sqrt(xOffset*xOffset + yOffset*yOffset);
	if (distance > 5)
		[stackedView stackedViewElement:self draggedBy:event];
}

@end


@implementation OSStackedView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		views = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return self;
}

- (void)dealloc
{
	[self clearStack];
	[views release];
	[super dealloc];
}

- (NSView *)selectedView
{
	return [selectedElement view];
}

- (int)selectedRow
{
	return [views indexOfObject:selectedElement];
}

- (NSImage *)dragImageForElement:(OSStackedViewElement *)element
{
	BOOL oldHighlight = [element isHighlighted];
	[element setHighlighted:YES];
	NSData *viewData = [element dataWithPDFInsideRect:[element bounds]];
	NSImage *viewImage = [[[NSImage alloc] initWithData:viewData] autorelease];
	NSImage *bgImage = [[[NSImage alloc] initWithSize:[element bounds].size] autorelease];
	[bgImage lockFocus];
	[[[NSColor whiteColor] colorWithAlphaComponent:0.66] set];
	NSRectFill([element bounds]);
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.66] set];
	[[NSBezierPath bezierPathWithRect:[element bounds]] stroke];
	[viewImage compositeToPoint:NSZeroPoint fromRect:[element bounds] operation:NSCompositeSourceOver fraction:0.66];
	[bgImage unlockFocus];
	[element setHighlighted:oldHighlight];
	return bgImage;
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)local
{
	return NSDragOperationEvery;
}

- (void)stackedViewElement:(OSStackedViewElement *)element draggedBy:(NSEvent *)event
{
	if(![delegate respondsToSelector:@selector(stackedView:writeRows:toPasteboard:)]) { return; }
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	dragOffset = [element convertPoint:[event locationInWindow] fromView:nil];
	if([delegate stackedView:self writeRows:[NSArray arrayWithObject:[NSNumber numberWithInt:[views indexOfObject:element]]] toPasteboard:pasteboard])
	{
		NSImage *image = [self dragImageForElement:element];
		[element dragImage:image at:NSZeroPoint offset:NSMakeSize(dragOffset.x, dragOffset.y) event:event pasteboard:pasteboard source:self slideBack:NO];
	}
}

- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
{
	if([delegate respondsToSelector:@selector(stackedView:dragMovedToScreenPoint:)])
	{
		screenPoint.x += dragOffset.x;
		screenPoint.y += dragOffset.y;
		[delegate stackedView:self dragMovedToScreenPoint:screenPoint];
	}
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	if(![delegate respondsToSelector:@selector(stackedView:updateDrag:)]) { return NSDragOperationNone; }
	return [delegate stackedView:self updateDrag:sender];	
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if(![delegate respondsToSelector:@selector(stackedView:validateDrop:)]) { return NSDragOperationNone; }
	return [delegate stackedView:self validateDrop:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	if(![delegate respondsToSelector:@selector(stackedView:draggingExited:)]) { return; }
	[delegate stackedView:self draggingExited:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	if(![delegate respondsToSelector:@selector(stackedView:acceptDrop:)]) { return NO; }
	return [delegate stackedView:self acceptDrop:sender];
}

- (void)stackedViewElement:(OSStackedViewElement *)elem clickedBy:(NSEvent *)event
{
	[selectedElement setHighlighted:NO];
	[[self window] makeFirstResponder:elem];
	selectedElement = elem;
	[selectedElement setHighlighted:YES];
	if(target && singleAction)
	{
		[target performSelector:singleAction withObject:self];
	}
}

- (void)stackedViewElement:(OSStackedViewElement *)elem doubleClickedBy:(NSEvent *)event
{
	if(target && doubleAction)
	{
		[target performSelector:doubleAction withObject:self];
	}
}

- (void)setTarget:tar
{
	target = tar;
}

- (void)setAction:(SEL)act
{
	singleAction = act;
}

- (void)setDoubleAction:(SEL)act
{
	doubleAction = act;
}

- (void)stackedViewElement:(OSStackedViewElement *)elem receivedKeyDown:(NSEvent *)event
{
	if ([[event characters] isEqualToString: @"\177"] || ([[event characters] characterAtIndex:0] == NSDeleteFunctionKey)) {
		[delegate deleteKeyPressedInStackedView:self];
	}
}

- (void)resizeSubviewsWithOldSize:(NSSize)size
{
	[self restackViews];
}

- (BOOL)isFlipped
{
	return YES;
}

- (int)tag
{
	return tag;
}

- (void)setTag:(int)newTag
{
	tag = newTag;
}

- (float)height
{
	float totalHeight = 0;
	for (id current in views)
	{
		totalHeight += NSHeight([current frame]);
	}
	return totalHeight;
}

- (void)restackViews
{
	float totalHeight = [self height];
	int i;
	for (i = [views count] - 1; i >= 0; i--)
	{
		OSStackedViewElement *current = [views objectAtIndex:i];
		totalHeight -= NSHeight([current frame]);
		[current setFrame:NSMakeRect(0, totalHeight, NSWidth([self bounds]), NSHeight([current frame]))];
	}
}

- (void)stackSubview:(NSView *)view
{
	id enclosingView = [OSStackedViewElement containingView:view];
	[enclosingView setStackedView:self];
	[self addSubview:enclosingView];
	[views addObject:enclosingView];
	if([[self superview] isKindOfClass:[NSClipView class]])
	{
		[self setFrame:NSMakeRect(0, 0, NSWidth([[self superview] bounds]), MAX([self height], NSHeight([[self superview] bounds])))];
	}
	else
	{
		[self setFrame:NSMakeRect(NSMinX([self frame]), NSMinY([self frame]) - NSHeight([view frame]), NSWidth([self frame]), NSHeight([self frame]) + NSHeight([view frame]))];
	}
	[self restackViews];
}

- (void)unstackSubview:(NSView *)view
{
	for (id current in views)
	{	
		if([current view] == view)
		{
			if(selectedElement == current)
			{
				selectedElement = nil;
			}
			[current removeFromSuperview];
			[views removeObject:current];
		}
	}
	if([[self superview] isKindOfClass:[NSClipView class]])
	{
		[self setFrame:NSMakeRect(0, 0, NSWidth([[self superview] bounds]), MAX([self height], NSHeight([[self superview] bounds])))];
	}
	else
	{
		[self setFrame:NSMakeRect(NSMinX([self frame]), NSMinY([self frame]) + NSHeight([view frame]), NSWidth([self frame]), NSHeight([self frame]) - NSHeight([view frame]))];
	}
	[self restackViews];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	if([delegate respondsToSelector:@selector(stackedView:concludeDrag:)])
	{
		[delegate stackedView:self concludeDrag:sender];
	}
}

- (void)clearStack
{
	[selectedElement setHighlighted:NO];
	selectedElement = nil;
	for (id current in [NSArray arrayWithArray:views])
	{
		[current removeFromSuperview];
		[views removeObject:current];
	}
	if([[self superview] isKindOfClass:[NSClipView class]])
	{
		[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), NSHeight([[self superview] bounds]))];
	}
	else
	{
		[self setFrame:NSMakeRect(NSMinX([self frame]), NSMaxY([self frame]), NSWidth([self frame]), 0)];
	}
	[self restackViews];
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)pt operation:(NSDragOperation)operation
{
	if(![delegate respondsToSelector:@selector(stackedView:dragOperationEnded:insideView:insideSuperview:)]) { return; }
	NSPoint winPoint = [[self window] mouseLocationOutsideOfEventStream];
	NSPoint viewPoint = [self convertPoint:winPoint fromView:nil];
	BOOL inside = NSPointInRect(viewPoint, [self bounds]);
	NSPoint superPoint = [[self enclosingScrollView] convertPoint:winPoint fromView:nil];
	BOOL inSuper = NSPointInRect(superPoint, [[self enclosingScrollView] bounds]);
	[delegate stackedView:self dragOperationEnded:operation insideView:inside insideSuperview:inSuper];
}

@end


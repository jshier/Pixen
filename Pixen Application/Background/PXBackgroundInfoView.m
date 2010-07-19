#import "PXBackgroundInfoView.h"
#import "PXBackgrounds.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

#import "Constants.h"
#import "PXNotifications.h"

@implementation PXBackgroundInfoView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self registerForDraggedTypes:[NSArray arrayWithObject:PXBackgroundTemplatePboardType]];
	}
	return self;
}

- (void)dealloc
{
	[cachedEmptyPath release];
	[super dealloc];
}

- (void)mouseDown:event
{
	dragOrigin = [event locationInWindow];
}

- (void)mouseDragged:event
{
	if(background == nil) { return; }
	
	NSPoint location = [event locationInWindow];
	float xOffset = location.x - dragOrigin.x, yOffset = location.y - dragOrigin.y;
	float distance = sqrt(xOffset*xOffset + yOffset*yOffset);
	if (distance <= 5)
		return;
	
	NSData *viewData = [self dataWithPDFInsideRect:[self bounds]];
	NSImage *viewImage = [[[NSImage alloc] initWithData:viewData] autorelease];
	NSImage *bgImage = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	[bgImage lockFocus];
	[[[NSColor whiteColor] colorWithAlphaComponent:0.66] set];
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.66] set];
	[viewImage compositeToPoint:NSZeroPoint fromRect:[self bounds] operation:NSCompositeCopy fraction:0.66];
	[bgImage unlockFocus];

	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pasteboard declareTypes:[NSArray arrayWithObject:PXBackgroundTemplatePboardType] owner:self];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:background] forType:PXBackgroundTemplatePboardType];
	NSPoint delta = [self convertPoint:[event locationInWindow] fromView:nil];
	[self dragImage:bgImage at:NSZeroPoint offset:NSMakeSize(delta.x, delta.y) event:event pasteboard:pasteboard source:self slideBack:NO];
}

- (NSBezierPath *)emptyPath
{
	if (!cachedEmptyPath)
	{
		cachedEmptyPath = [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 5, 5) cornerRadius:15] retain];
		[cachedEmptyPath setLineWidth:4];
		CGFloat pattern[2] = { 15.0, 5.0 };
		if (!isActiveDragTarget)
			[cachedEmptyPath setLineDash:pattern count:2 phase:0.0];
	}
	return cachedEmptyPath;
}

- (NSBezierPath *)backgroundPath
{
	if (!cachedBackgroundPath)
	{
		cachedBackgroundPath = [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 5, 5) cornerRadius:15] retain];
		[cachedBackgroundPath setLineWidth:(isActiveDragTarget ? 3 : 1)];
	}
	return cachedBackgroundPath;
}


- (void)drawRect:(NSRect)rect
{
	if (background == nil)
	{
		[[[NSColor lightGrayColor] colorWithAlphaComponent:(isActiveDragTarget ? 1 : 0.5)] set];
		[[self emptyPath] stroke];
		
		NSSize stringSize = NSMakeSize(300, 40);
		NSRect drawFrame;
		drawFrame.origin = NSMakePoint(NSWidth([self bounds]) / 2 - stringSize.width / 2, NSHeight([self bounds]) / 2 - stringSize.height / 2);
		drawFrame.size = stringSize;
		
		NSTextFieldCell *textCell = [[NSTextFieldCell alloc] init];
		[textCell setAlignment:NSCenterTextAlignment];
		[textCell setTextColor:[NSColor disabledControlTextColor]];
		[textCell setStringValue:NSLocalizedString(@"Drag a template here, and it will be displayed when the mouse is outside of the canvas.", @"ALTERNATE_BACKGROUND_INFO")];
		[textCell drawWithFrame:drawFrame inView:self];
	}
	else
	{
		NSBezierPath *path = [self backgroundPath];
		if (isActiveDragTarget)
		{
			[[NSColor blackColor] set];
			[path stroke];
		}
		[[NSColor whiteColor] set];
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(0, -2)];
		[shadow setShadowBlurRadius:4];
		[shadow setShadowColor:[NSColor blackColor]];
		[shadow set];
		[path fill];
	}
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return [self draggingUpdated:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	if ([[self backgroundPath] containsPoint:[self convertPoint:[sender draggingLocation] fromView:nil]])
	{
		isActiveDragTarget = YES;
		[cachedEmptyPath release];
		cachedEmptyPath = nil;
		[cachedBackgroundPath release];
		cachedBackgroundPath = nil;
		[self setNeedsDisplay:YES];
		return NSDragOperationCopy;
	}
	else
	{
		isActiveDragTarget = NO;
		[cachedEmptyPath release];
		cachedEmptyPath = nil;
		[cachedBackgroundPath release];
		cachedBackgroundPath = nil;
		[self setNeedsDisplay:YES];
		if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSPasteboard pasteboardWithName:NSDragPboard] stringForType:PXBackgroundNamePboardType]])
		{
			[[NSCursor disappearingItemCursor] set];
			return NSDragOperationNone;
		}
		else
			return NSDragOperationNone;
	}
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	isActiveDragTarget = NO;
	[cachedEmptyPath release];
	cachedEmptyPath = nil;
	[cachedBackgroundPath release];
	cachedBackgroundPath = nil;
	[self setNeedsDisplay:YES];
	if(operation == NSDragOperationNone)
	{
		[delegate dragFailedForInfoView:self];
	}
}

- (void)fixThumbnailImage
{
	if(!background) { return; }
	NSRect centeredRect = NSMakeRect(0, 0, NSWidth([imageView bounds]) - 10, NSHeight([imageView bounds]) - 10);
	float numerator = MAX([previewImage size].width, [previewImage size].height);
	float denominator = MIN([previewImage size].width, [previewImage size].height);
	float aspectRatio = numerator / denominator;
	if([previewImage size].width > [previewImage size].height)
	{
		centeredRect.size.height /= aspectRatio;
		centeredRect.origin.y += ((NSHeight([imageView bounds]) - 10) - NSHeight(centeredRect)) / 2.0;
	}
	else
	{
		centeredRect.size.width /= aspectRatio;
		centeredRect.origin.x += ((NSWidth([imageView bounds]) - 10) - NSWidth(centeredRect)) / 2.0;
	}
	id backgroundImage = [[[background previewImageOfSize:[imageView bounds].size] copy] autorelease];
	[backgroundImage lockFocus];
	[previewImage drawInRect:centeredRect fromRect:NSMakeRect(0, 0, [previewImage size].width, [previewImage size].height) operation:NSCompositeSourceOver fraction:1];
	[backgroundImage unlockFocus];
	[imageView setImage:backgroundImage];
	[self display];
}

- (void)setPreviewImage:(NSImage *)img
{
	[previewImage release];
	previewImage = [img retain];
	[self fixThumbnailImage];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	isActiveDragTarget = NO;
	[cachedEmptyPath release];
	cachedEmptyPath = nil;
	[cachedBackgroundPath release];
	cachedBackgroundPath = nil;
	[self setNeedsDisplay:YES];
	NSPasteboard *pasteboard = [sender draggingPasteboard];
	PXBackground *bg = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:PXBackgroundTemplatePboardType]];
	NSString *newName = [pasteboard stringForType:PXBackgroundNewTemplatePboardType];
	if (newName)
		[bg setName:newName];
	[self setBackground:bg];
	
	[delegate backgroundInfoView:self receivedBackground:bg];
	return YES;
}

- (IBAction)nameChanged:(id)sender
{
	[background setName:[nameField stringValue]];
}

- (void)backgroundChanged:(NSNotification *)note
{
	[self fixThumbnailImage];
}

- (void)centerConfigurator
{
	NSRect newFrame;
	newFrame.origin = NSMakePoint(floorf(NSWidth([configuratorContainer bounds]) / 2 - NSWidth([[background configurator] bounds]) / 2),
								  floorf(NSHeight([configuratorContainer bounds]) / 2 - NSHeight([[background configurator] bounds]) / 2));
	newFrame.size = [[background configurator] bounds].size;
	[[background configurator] setFrameOrigin:newFrame.origin];
}

- (void)setBackground:(PXBackground *)bg
{
	[[background configurator] removeFromSuperview];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	background = bg;
	if(bg)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundChanged:) name:PXBackgroundChangedNotificationName object:background];
		[nameField setStringValue:[bg name]];
		[nameField setHidden:NO];
		[configuratorContainer addSubview:[bg configurator]];
		[self centerConfigurator];
		[self fixThumbnailImage];
	}
	else
	{
		[nameField setHidden:YES];
		[imageView setImage:nil];
	}
	[self display];
}

- (NSTextField *)nameField
{
	return nameField;
}

@end

#import "PXPaletteView.h"
#import "PXColorPickerColorWellCell.h"

@implementation PXPaletteView

const int viewMargin = 1;

- (void)setDelegate:del
{
	delegate = del;
}

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		colorCell = [[PXColorPickerColorWellCell alloc] init];
		palette = NULL;
		[self setEnabled:YES];
		controlSize = NSRegularControlSize;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXPaletteChangedNotificationName object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[colorCell release];
	[super dealloc];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setEnabled:(BOOL)en
{
	enabled = en;
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * height + viewMargin*2, NSHeight([[self superview] bounds])))];
	[self retile];
}

- (void)retile
{
	width = (controlSize == NSRegularControlSize ? 32 : 16) + viewMargin;
	height = width;
	columns = NSWidth([self bounds]) / width;
	rows = palette ? ceilf((float)((PXPalette_colorCount(palette))) / columns) : 0;
	
	float difference = NSWidth([self bounds]) - columns * width - viewMargin*2;
	float additional = difference / (float)(columns);
	width = width+additional;
	
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * height + viewMargin*2, NSHeight([[self superview] bounds])))];
	[self setNeedsDisplay:YES];
}

- (PXPalette *)palette
{
	return palette;
}

- (BOOL)acceptsFirstMouse:event
{
	return YES;
}

- (void)paletteChanged:note
{
	[self retile];
	[self setNeedsDisplay:YES];
}

- (void)setPalette:(PXPalette *)pal
{
	if(!pal)
	{
		if(palette)
		{
			PXPalette_release(palette);
			palette = nil;
		}
		return;
	}
	PXPalette_retain(pal);
	PXPalette_release(palette);
	palette = pal;		
	[self retile];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	NSEraseRect(rect);
	
	if (!palette) { return; }
	// Okay, so with the rect we're given, we first determine the rows that are visible.
	// Make sure not to go past the bounds of our array.
	int firstRow = MAX(floorf(NSMinY(rect) / height), 0);
	int lastRow = MIN(ceilf(NSMaxY(rect) / height), rows-1);
	// We just go ahead and round them to the appropriate number; we're not particularly
	// worried about drawing all of the cells that are only partially showing: drawing
	// cells is cheap.
	
//FIXME: Hacky workaround.  But the real problem seems very hard to locate.
	@try {
		// Draw the appropriate cells.
		int i, j;
		PXPaletteColorPair *colors = palette->colors;
		[colorCell setControlSize:controlSize];
		for (j = firstRow; j <= lastRow; j++)
		{
			for (i = 0; i < columns; i++)
			{
				int index = j * columns + i;
				if (index >= (PXPalette_colorCount(palette))) { break; }
				int paletteIndex = index;
				[colorCell setIndex:paletteIndex];
				NSColor *color = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0];
				if(paletteIndex != -1)
				{
					color = colors[paletteIndex].color;
					[colorCell setHighlighted:NO];
				}
				[colorCell setColor:color];
				[colorCell drawWithFrame:NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2) inView:self];
			}
		}
	} @catch(NSException *e) {
		[self retile];
		[self setNeedsDisplay:YES];
	}
	if(!enabled)
	{
		[[NSColor colorWithDeviceWhite:1 alpha:.2] set];
		NSRectFillUsingOperation([self visibleRect], NSCompositeSourceOver);
	}
}

- (void)rightMouseDown:event
{
	[self mouseDown:event];
}

- (void)rightMouseDragged:event
{
	[self mouseDragged:event];
}

- (void)rightMouseUp:event
{
	[self mouseUp:event];
}

- (int)indexOfCelAtPoint:(NSPoint)point
{
	int firstRow = MAX(floorf(NSMinY([self visibleRect]) / height), 0);
	int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / height), rows-1);
	int i, j;
	for (j = firstRow; j <= lastRow; j++)
	{
		for (i = 0; i < columns; i++)
		{
			int index = j * columns + i;
			if (index >= (PXPalette_colorCount(palette))) { break; }
			NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
			if(NSPointInRect(point, frame))
			{
				return index;
			}			
		}
	}	
	return -1;
}

- (NSControlSize)controlSize
{
	return controlSize;
}

- (void)setControlSize:(NSControlSize)aSize
{
	controlSize = aSize;
	[self retile];
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (void)sizeSelector:selector selectedSize:(NSControlSize)aSize
{
	[self setControlSize:aSize];
	if ([delegate respondsToSelector:@selector(paletteViewSizeChangedTo:)])
	{
		[delegate paletteViewSizeChangedTo:aSize];
	}
}

- (void)activateIndexWithEvent:e
{
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];
	if(!palette || !enabled) { return; }
	int index = [self indexOfCelAtPoint:p];
	if(index == -1)
	{
		return;
	}
	int paletteIndex = index;
	if (paletteIndex == -1)
	{
		return;
	}
	[delegate useColorAtIndex:paletteIndex event:e];	
}

- (void)mouseDown:event
{
	[self activateIndexWithEvent:event];
}

- (void)mouseDragged:event
{
	[self activateIndexWithEvent:event];
	[self autoscroll:event];
}

- (void)setDocument:doc
{
	document = doc;
}

- (void)mouseUp:event
{
	[self activateIndexWithEvent:event];
}

@end

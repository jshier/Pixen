//
//  PXImageBackground.m
//  Pixen-XCode
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

//  Created by Joe Osborn on Tue Oct 28 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXImageBackground.h"
#import "PXCanvas.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Drawing.h"
#import "PathUtilities.h"

@implementation PXImageBackground

- (NSImage *)previewImageOfSize:(NSSize)size
{
	id result = [[[NSImage alloc] initWithSize:size] autorelease];
	[result lockFocus];
	[color set];
	NSRectFill(NSMakeRect(0, 0, size.width, size.height));
	[image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1];
	[result unlockFocus];
	return result;
}

- (void)dealloc
{
	[image release];
	image = nil;
	[super dealloc];
}

-(NSString *) defaultName
{
    return NSLocalizedString(@"IMAGE_BACKGROUND", @"Image Background");
}

- (NSString *) nibName
{
    return @"PXImageBackgroundConfigurator";
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
    [browseButton setEnabled:enabled];
    [super setConfiguratorEnabled:enabled];
}

- (id) init
{
	if ( ! ( self = [super init] ) ) 
		return nil;
    image = [[NSImage imageNamed:@"Pixen"] retain];
    [self setColor:[NSColor whiteColor]];
    return self;
}

- (IBAction)configuratorBrowseForImageButtonClicked:(id)sender
{
	id panel = [NSOpenPanel openPanel];
	// fixed!  I'm reading the document types directly from the Info.plist, though...
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSArray *documentTypes = [infoDictionary objectForKey:CFBundleDocumentTypesKey];
	NSMutableArray *fileExtensions = [NSMutableArray array];
	id enumerator = [documentTypes objectEnumerator], current;
	
	while  ( ( current = [enumerator nextObject] ) ) {
		[fileExtensions addObjectsFromArray:[current objectForKey:CFBundleTypeExtensionsKey]];
	}
	
	if([panel runModalForDirectory:GetBackgroundImagesDirectory() file:nil types:fileExtensions] == NSOKButton)
    {
		[self setImage:[[PXCanvas canvasWithContentsOfFile:[[panel filenames] objectAtIndex:0]] displayImage]];
		[imageNameField setStringValue:[[[panel filenames] objectAtIndex:0] lastPathComponent]];
    }
}

- (void)setColor:(NSColor *)aColor
{
	[super setColor:aColor];
	[image setBackgroundColor:color];
}

- (void)setImage:(NSImage *)anImage
{
	[anImage retain];
	[image release];
	image = anImage;
	[image setBackgroundColor:color];
	if(![[self name] isEqualToString:[self defaultName]]) 
    { 
		[imageNameField setStringValue:[self name]]; 
    }
	[self changed];
}

- (void)drawRect:(NSRect)rect 
      withinRect:(NSRect)wholeRect 
   withTransform:(NSAffineTransform *) aTransform 
		onCanvas:(PXCanvas *)aCanvas
{
	[aTransform invert];
	
	NSPoint origin = [aTransform transformPoint:rect.origin];
	NSSize size = [aTransform transformSize:rect.size];

	id newTransform = [NSAffineTransform transform];
	NSAffineTransformStruct s = [aTransform transformStruct];
	float dx = s.tX, dy = s.tY;
	while(dx < 0) { dx += [aCanvas size].width; }
	while(dy < 0) { dy += [aCanvas size].height; }
	[newTransform translateXBy:dx yBy:dy];
	[newTransform invert];
	origin = [newTransform transformPoint:origin];
	origin.x = floorf(origin.x);
	origin.y = floorf(origin.y);
	size.width = ceilf(size.width);
	size.height = ceilf(size.height);
	NSPoint imageLocation = origin;
	imageLocation = [newTransform transformPoint:imageLocation];
	NSSize imageSize = [aCanvas size];
	
	[newTransform invert];
	[newTransform concat];
	[color set];
	NSRectFill(NSMakeRect(origin.x, origin.y, size.width, size.height));
	if(![aCanvas wraps])
	{
		[image drawInRect:NSMakeRect(0, 0, [aCanvas size].width, [aCanvas size].height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1];
	}
	else
	{
		int xTiles = (size.width / imageSize.width) + 1;
		int yTiles = (size.height / imageSize.height) + 1;
		int i, j;
		NSRect imgRect = NSMakeRect(imageLocation.x, imageLocation.y, imageSize.width, imageSize.height);
		for (i = 0; i < xTiles; i++)
		{
			imgRect.origin.x = i * imageSize.width + imageLocation.x;
			for (j = 0; j < yTiles; j++)
			{
				imgRect.origin.y = j * imageSize.height + imageLocation.y;
				[image drawInRect:imgRect fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1];
			}
		}	
	}
	
	[newTransform invert];
	[newTransform concat];
	
	[aTransform invert];
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[color set];
	NSRectFill(rect);
	[image drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1];
}

-(id) copyWithZone:(NSZone *)zone
{
    PXImageBackground *copy = [super copyWithZone:zone];
    [copy setImage:image];
    return copy;
}

- (void)encodeWithCoder:(NSCoder *) coder
{
	[coder encodeObject:image forKey:@"image"];
	[super encodeWithCoder:coder];
}

-(id) initWithCoder:(NSCoder*)coder
{
	[super initWithCoder:coder];
	[self setImage:[coder decodeObjectForKey:@"image"]];
	return self;
}

@end

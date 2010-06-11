//
//  PXBackgroundConfig.m
//  Pixen
//
//  Created by Joe Osborn on 2007.11.12.
//  Copyright 2007 Open Sword Group. All rights reserved.
//

#import "PXBackgroundConfig.h"
#import "PXBackgrounds.h"

@implementation PXBackgroundConfig

- init
{
	[super init];
	[self setDefaultBackgrounds];
	[self setDefaultPreviewBackgrounds];
	return self;
}

- initWithMainBG:(PXBackground *)mbg altBG:(PXBackground *)abg prevMainBG:(PXBackground *)pmbg altBG:(PXBackground *)pabg
{
	[self init];
	if(mbg)
	{
		[self setMainBackground:mbg];
		[self setAlternateBackground:abg];
	}
	if(pmbg)
	{
		[self setMainPreviewBackground:pmbg];
		[self setAlternatePreviewBackground:pabg];
	}
	return self;
}

- (void)dealloc
{
	[mainBackground release];
	[mainPreviewBackground release];
	[alternateBackground release];
	[alternatePreviewBackground release];
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:mainBackground forKey:@"mainBackground"];
	[coder encodeObject:alternateBackground forKey:@"alternateBackground"];
	[coder encodeObject:mainPreviewBackground forKey:@"mainPreviewBackground"];
	[coder encodeObject:alternatePreviewBackground forKey:@"alternatePreviewBackground"];
}

- initWithCoder:(NSCoder *)coder
{
	return [self initWithMainBG:[coder decodeObjectForKey:@"mainBackground"] altBG:[coder decodeObjectForKey:@"alternateBackground"]
					 prevMainBG:[coder decodeObjectForKey:@"mainPreviewBackground"] altBG:[coder decodeObjectForKey:@"alternatePreviewBackground"]];
}

- (PXBackground *)mainBackground {
    return [[mainBackground retain] autorelease];
}

- (void)setMainBackground:(PXBackground *)value {
    if (mainBackground != value) {
        [mainBackground release];
        mainBackground = [value retain];
    }
}

- (PXBackground *)alternateBackground {
    return [[alternateBackground retain] autorelease];
}

- (void)setAlternateBackground:(PXBackground *)value {
    if (alternateBackground != value) {
        [alternateBackground release];
        alternateBackground = [value retain];
    }
}

- (PXBackground *)mainPreviewBackground {
    return [[mainPreviewBackground retain] autorelease];
}

- (void)setMainPreviewBackground:(PXBackground *)value {
    if (mainPreviewBackground != value) {
        [mainPreviewBackground release];
        mainPreviewBackground = [value retain];
    }
}

- (PXBackground *)alternatePreviewBackground {
    return [[alternatePreviewBackground retain] autorelease];
}

- (void)setAlternatePreviewBackground:(PXBackground *)value {
    if (alternatePreviewBackground != value) {
        [alternatePreviewBackground release];
        alternatePreviewBackground = [value retain];
    }
}

- (void)setDefaultBackgrounds
{
	id data = [[NSUserDefaults standardUserDefaults] dataForKey:PXCanvasDefaultMainBackgroundKey];
	if(data)
	{
		[self setMainBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
	else
	{
		id background = [[[PXSlashyBackground alloc] init] autorelease];
		[self setMainBackground:background];
		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:background] forKey:PXCanvasDefaultMainBackgroundKey];
	}
	data = [[NSUserDefaults standardUserDefaults] dataForKey:PXCanvasDefaultAlternateBackgroundKey];
	if(data)
	{
		[self setAlternateBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
}

- (void)setDefaultPreviewBackgrounds
{
	id data = [[NSUserDefaults standardUserDefaults] dataForKey:PXPreviewDefaultMainBackgroundKey];
	if(data)
	{
		[self setMainPreviewBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
	else
	{
		id background = [[[PXMonotoneBackground alloc] init] autorelease];
		[self setMainPreviewBackground:background];
		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:background] forKey:PXPreviewDefaultMainBackgroundKey];		
	}
	data = [[NSUserDefaults standardUserDefaults] dataForKey:PXPreviewDefaultAlternateBackgroundKey];
	if(data)
	{
		[self setAlternatePreviewBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
}

@end

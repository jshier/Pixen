  //
  //  PXToolSwitcher.m
  //  Pixen-XCode

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

  //  Created by Andy Matuschak on Sat Mar 13 2004.
  //  Copyright (c) 2004 Open Sword Group. All rights reserved.
  //

#import "PXToolSwitcher.h"
#import "PXPencilTool.h"
#import "PXEraserTool.h"
#import "PXEyedropperTool.h"
#import "PXZoomTool.h"
#import "PXFillTool.h"
#import "PXLineTool.h"
#import "PXRectangularSelectionTool.h"
#import "PXMoveTool.h"
#import "PXRectangleTool.h"
#import "PXEllipseTool.h"
#import "PXMagicWandTool.h"
#import "PXLassoTool.h"
#import "PXNotifications.h"

#import "PXColorPicker.h"

NSMutableArray * toolNames;

  // a protocol interface + bundle loader would be better

@implementation PXToolSwitcher


+(NSArray *) toolClasses
{
	return [NSArray arrayWithObjects:[PXPencilTool class], 
          [PXEraserTool class], [PXEyedropperTool class],
          [PXZoomTool class], [PXFillTool class], 
          [PXLineTool class], [PXRectangularSelectionTool class],
          [PXMoveTool class], [PXRectangleTool class],
          [PXEllipseTool class], [PXMagicWandTool class],
          [PXLassoTool class], nil];
}

+(id) toolNames
{
  return [[self toolClasses] valueForKey:@"description"];
}

- (void)lock
{
  _locked = YES;
}

- (void)unlock
{
  _locked = NO;
}

- (void)awakeFromNib
{
	[toolsMatrix setDoubleAction:@selector(toolDoubleClicked:)];
}

-(id) init
{
	if ( ! ( self = [super init] ) ) 
		return nil;
	
	tools = [[NSMutableArray alloc] initWithCapacity:[[[self class] toolClasses] count]];
	
	NSEnumerator *enumerator = [[[self class] toolClasses] objectEnumerator];
	id current;
	
	while (( current = [enumerator nextObject] ) )
  {
		[tools addObject:[[current alloc] init]];
  }
	
	[tools makeObjectsPerformSelector:@selector(setSwitcher:) withObject:self];
	[self setColor:[[NSColor blackColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]];
	[self useToolTagged:PXPencilToolTag];
  
	_locked = NO;
	[self checkUserDefaults];
  
	return self;
}

  //FIXME: private ? 
  //Not sure what this was warning about -- though we do in general mix private and 'public' methods a bit much, we should make use of categories.
- (void)checkUserDefaults
{
    //should find a way to factor this into the tools' classes.
    //Leaks ? ?
	NSArray *arrayObjects = [NSArray arrayWithObjects:@"p", @"e", @"d", @"z", 
                           @"f", @"l", @"s", @"m", @"r", @"o", @"w", 
                           @"a", nil];
	
	NSArray *arrayKeys = [NSArray arrayWithObjects:
                        [NSNumber numberWithInt:PXPencilToolTag],
                        [NSNumber numberWithInt:PXEraserToolTag],
                        [NSNumber numberWithInt:PXEyedropperToolTag],
                        [NSNumber numberWithInt:PXZoomToolTag],
                        [NSNumber numberWithInt:PXFillToolTag],
                        [NSNumber numberWithInt:PXLineToolTag],
                        [NSNumber numberWithInt:PXRectangularSelectionToolTag],
                        [NSNumber numberWithInt:PXMoveToolTag],
                        [NSNumber numberWithInt:PXRectangleToolTag],
                        [NSNumber numberWithInt:PXEllipseToolTag],
                        [NSNumber numberWithInt:PXMagicWandToolTag],
                        [NSNumber numberWithInt:PXLassoToolTag],
                        nil];
	
	NSDictionary *defaultShortcuts = [NSDictionary dictionaryWithObjects:arrayObjects
                                                               forKeys:arrayKeys];
	NSEnumerator *enumerator = [defaultShortcuts keyEnumerator];
	NSString *current;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *tmp; 
	
	while ( ( current = [enumerator nextObject] ) )
  {
		tmp =  [[[self class] toolNames] objectAtIndex:[current intValue]];
		if ( ! [userDefaults objectForKey:tmp ] )
		{
			[userDefaults setObject:[defaultShortcuts objectForKey:current] forKey:tmp];
		}
  }
}


- (void)dealloc
{
  [tools release];
  [super dealloc];
}

- (id) selectedTool
{
  return _tool;
}

-(id) toolWithTag:(PXToolTag)tag
{
  return [tools objectAtIndex:tag];
}

- (PXToolTag)tagForTool:(id) aTool
{
  return [tools indexOfObject:aTool];
}

- (void)setIcon:(NSImage *)anImage forTool:(id)aTool
{
  [[toolsMatrix cellWithTag:[self tagForTool:aTool]] setImage:anImage];
}

- (void)useTool:(id) aTool
{
  [self useToolTagged:[self tagForTool:aTool]];
}

- (void)useToolTagged:(PXToolTag)tag
{
	if ( _locked ) 
		return;
  
	_lastTool = _tool;
	_tool = [self toolWithTag:tag];
	[_tool clearBezier];
	[toolsMatrix selectCellWithTag:tag];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolDidChangeNotificationName 
                                                      object:self 
                                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_tool, PXNewToolKey,nil]];
}

- (void)requestToolChangeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolDidChangeNotificationName 
                                                      object:self 
                                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_tool, PXNewToolKey,nil]];
}

- (NSColor *) color
{
  return _color;
}

- (void)activateColorWell
{
	[colorWell activate:YES];
}

- (void)clearBeziers;
{
	[tools makeObjectsPerformSelector:@selector(clearBeziers)];
}

- (void)setColor:(NSColor *)col
{
    //FIXME: coupled
	NSColor *aColor = [col colorUsingColorSpaceName:NSDeviceRGBColorSpace];
  [aColor retain];
  [_color release];
  _color = aColor;
	
  id enumerator = [tools objectEnumerator];
  id current;
  while ( (current = [enumerator nextObject] )  )
	{
		if([current respondsToSelector:@selector(setColor:)]) 
		{
			[current setColor:_color]; 
		}
	}
  [colorWell setColor:_color];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolColorDidChangeNotificationName object:self];
}

- (IBAction)colorChanged:(id)sender
{
	[self setColor:[colorWell color]];
}

- (IBAction)toolClicked:(id)sender
{
	
  [self useToolTagged:[[toolsMatrix selectedCell] tag]];
}

- (IBAction)toolDoubleClicked:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolDoubleClickedNotificationName object:self];
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	NSString * chars = [[event charactersIgnoringModifiers] lowercaseString];
	id enumerator = [[PXToolSwitcher toolNames] objectEnumerator], current;
	while  ( ( current = [enumerator nextObject] ) )
  {
		if ([chars characterAtIndex:0] == [[[NSUserDefaults standardUserDefaults] objectForKey:current] characterAtIndex:0])
		{
			[self useToolTagged:[[PXToolSwitcher toolNames] indexOfObject:current]];
			break;
		}
  }
	[[self toolWithTag:PXMoveToolTag] keyDown:event fromCanvasController:cc];
}

- (void)optionKeyDown
{
  if( ! [_tool optionKeyDown] ) { 
		[self useToolTagged:PXEyedropperToolTag];
  }
}

- (void)optionKeyUp
{
  if( ! [_tool optionKeyUp] ) { 
		[self useTool:_lastTool];
  }
}
- (void)shiftKeyDown
{
  [_tool shiftKeyDown];
}

- (void)shiftKeyUp
{
  [_tool shiftKeyUp];
}

- (void)commandKeyDown
{
	[_tool commandKeyDown];
}

- (void)commandKeyUp
{
	[_tool commandKeyUp];
}

@end

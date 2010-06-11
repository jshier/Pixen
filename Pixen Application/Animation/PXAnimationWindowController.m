//
//  PXAnimationWindowController.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXAnimationWindowController.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Selection.h"
#import "RBSplitSubview.h"
#import "PXAnimation.h"
#import "PXCel.h"
#import "PXFilmStripView.h"
#import "PXAnimationPreview.h"
#import "PXSequenceExportPrompter.h"
#import "PXCanvasDocument.h"
#import "PXAnimationView.h"
#import "OSQTExporter.h"
#import "PXCanvasWindowController_IBActions.h"
#import "PXScaleController.h"
#import "RBSplitView.h"
#import "RBSplitSubview.h"
#import "Constants.h"

@implementation PXAnimationWindowController

- (void)dealloc
{
	[animationPreview removeObserver:self forKeyPath:@"isPlaying"];
	[animationPreview setDataSource:nil];
	[filmStrip setDataSource:nil];
	[filmStrip setDelegate:nil];
	[self setAnimation:nil];
	[super dealloc];
}

- (void)canvasDidChange:notification
{
	NSRect celRect = [filmStrip rectOfCelIndex:[filmStrip selectedIndex]];
	float scaledRatio = NSWidth(celRect) / [activeCel size].width;
	NSRect changedRect = [[[notification userInfo] objectForKey:PXChangedRectKey] rectValue];
	changedRect.origin.x *= scaledRatio;
	changedRect.origin.x += NSMinX(celRect);
	changedRect.origin.y *= scaledRatio;
	changedRect.origin.y += NSMinY(celRect);
	changedRect.size.width *= scaledRatio;
	changedRect.size.height *= scaledRatio;
	[filmStrip setNeedsDelayedDisplayInRect:changedRect];
	if([notification object] == [activeCel canvas]) { return; }
	int i;
	for (i = 0; i < [self numberOfCels]; i++)
	{
		PXCel *current = [self celAtIndex:i];
		if([current canvas] == [notification object])
		{
			[self activateCel:current];
		}
	}
}

- (void)canvasController:(PXCanvasController *)controller setSize:(NSSize)size backgroundColor:(NSColor*)bg
{
	[animation setSize:size withOrigin:NSZeroPoint backgroundColor:bg undo:NO];
	[self setAnimation:animation];
	[[[self document] undoManager] removeAllActions];
	[[self document] updateChangeCount:NSChangeCleared];
}

- (void)activateCel:(PXCel *)cel
{
	int newCelIndex = [animation indexOfObjectInCels:cel];
		
	if(cel == activeCel && activeIndex == newCelIndex) { return; }
	activeIndex = newCelIndex;
	activeCel = cel;
	[self setCanvas:[cel canvas]];
	int prevIndex = newCelIndex - 1;
	if (prevIndex < 0)
		prevIndex = [self numberOfCels] ? [self numberOfCels] - 1 : 0;
	if (newCelIndex != prevIndex)
	{
		[(PXAnimationView *)[self view] setPreviousCelImage:[[[self celAtIndex:prevIndex] canvas] displayImage]];
	}
	else
	{
		[(PXAnimationView *)[self view] setPreviousCelImage:nil];
	}
	[filmStrip selectCelAtIndex:newCelIndex byExtendingSelection:NO];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canvasDidChange:) name:PXCanvasChangedNotificationName object:nil];	[(NSClipView *)[filmStrip superview] setCopiesOnScroll:NO]; // prevent weird visual bugs
	[animationPreview addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:NULL];
	[super awakeFromNib];
}

- (void)updateDeleteButtonState
{
	[self willChangeValueForKey:@"canDeleteCel"];
	[self didChangeValueForKey:@"canDeleteCel"];	
}

- (void)setAnimation:anim
{
	[animation removeObserver:self forKeyPath:@"countOfCels"];
	[animation removeObserver:self forKeyPath:@"size"];
	animation = anim;
	if (!animation) {
		[self setCanvas:nil];
	} else {
		[animation addObserver:self forKeyPath:@"countOfCels" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
		[animation addObserver:self forKeyPath:@"size" options:NSKeyValueObservingOptionNew context:NULL];
		[self updateDeleteButtonState];
		//reload data
		[animation setUndoManager:[[self document] undoManager]];
		[self activateCel:[self celAtIndex:0]];
		if(!NSEqualSizes([anim size], NSZeroSize))
		{
			[filmStrip reloadData];
			[topSubview setMinDimension:[filmStrip minimumHeight] andMaxDimension:0];
			[animationPreview reloadData];
			[animationPreview play:self];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == animationPreview) {
		BOOL isPlaying = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		NSString *imageName = (isPlaying ? @"pausecel" : @"playcel");
		[playPauseButton setImage:[NSImage imageNamed:imageName]];
		return;
	}
	
	[filmStrip reloadData];
	[animationPreview reloadData];
	[animationPreview play:self];
	
	if ([keyPath isEqualToString:@"countOfCels"]) {
		// If the change involved the number of cels getting bigger, this means a new cel was added; we should activate it.
		if ([[change objectForKey:NSKeyValueChangeOldKey] intValue] < [animation countOfCels])
		{
			[self activateCel:[self celAtIndex:MIN([filmStrip selectedIndex]+1, [animation countOfCels]-1)]];
		}
		// It's gone down, so select the next one down.
		else if([[change objectForKey:NSKeyValueChangeOldKey] intValue] > [animation countOfCels])
		{
			[self activateCel:[self celAtIndex:MAX((int)([filmStrip selectedIndex])-1, 0)]];
		}
		else
		{
			[self activateCel:activeCel];
		}
		
		[self updateDeleteButtonState];
	} else if ([keyPath isEqualToString:@"size"]) {
		[canvasController updateCanvasSize];
	}
}

- (int)numberOfCels
{
	return NSEqualSizes([animation size], NSZeroSize) ? 0 : [animation countOfCels];
}

- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard
{
	if ([indices count] > 1) {
		[[NSException exceptionWithName:@"PXIanIsLazyException" reason:@"Ian is too lazy to make dragging work with multiple selection!" userInfo:nil] raise];
		return;
	}
	if ([indices count] < 1) {
		return;
	}
	int index = [indices firstIndex];
	
	PXCel *cel = [self celAtIndex:index];
	
	NSImage *image = [[cel canvas] exportImage];
	[image lockFocus];
	NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, [image size].width, [image size].height)] autorelease];
	[image unlockFocus];
	[pboard declareTypes:[NSArray arrayWithObjects:PXCelPboardType, NSTIFFPboardType, nil] owner:self];
	[pboard setData:[NSKeyedArchiver archivedDataWithRootObject:cel] forType:PXCelPboardType];
	[pboard setData:[bitmapRep TIFFRepresentation] forType:NSTIFFPboardType];
}

- (NSArray *)draggedTypesForFilmStripView:view
{
	return [[[NSArray arrayWithObject:PXCelPboardType] arrayByAddingObjectsFromArray:[NSImage imagePasteboardTypes]] arrayByAddingObject:NSFilenamesPboardType];
}

- (BOOL)insertCelIntoFilmStripView:view fromPasteboard:(NSPasteboard *)pboard atIndex:(int)targetDraggingIndex
{
	NSString *type = [pboard availableTypeFromArray:[self draggedTypesForFilmStripView:view]];
	if ([[NSImage imagePasteboardTypes] containsObject:type]) {
		NSImage *image = [[[NSImage alloc] initWithPasteboard:pboard] autorelease];
		NSImage *celImage;
		if (!NSEqualSizes([image size], [animation size])) {
			celImage = [[[NSImage alloc] initWithSize:[animation size]] autorelease];
			NSRect celImageRect = NSMakeRect(0, 0, [animation size].width, [animation size].height);
			NSRect destRect = celImageRect;
			if ([image size].width > [animation size].width || [image size].height > [animation size].height) {
				float imageAspectRatio = [image size].height / [image size].width;
				float celAspectRatio = [animation size].height / [animation size].width;
				if (imageAspectRatio > celAspectRatio) {
					destRect.size.width = NSHeight(destRect) / imageAspectRatio;
				} else {
					destRect.size.height = NSWidth(destRect) * imageAspectRatio;
				}
			} else {
				destRect.size = [image size];
			}
			destRect.origin.y = ([animation size].height - NSHeight(destRect)) / 2;
			destRect.origin.x = ([animation size].width - NSWidth(destRect)) / 2;
			[image setScalesWhenResized:YES];
			[image setSize:destRect.size];
			[celImage lockFocus];
			[[NSColor clearColor] set];
			NSRectFill(celImageRect);
			[image compositeToPoint:destRect.origin operation:NSCompositeCopy];
			NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:celImageRect];
			[celImage unlockFocus];
			[celImage removeRepresentation:[[celImage representations] objectAtIndex:0]];
			[celImage addRepresentation:bitmap];

		} else {
			celImage = image;
		}
		
		PXCel *cel = [[[PXCel alloc] initWithImage:celImage animation:animation atIndex:targetDraggingIndex] autorelease];
		return (cel != nil);
	} else if ([type isEqualToString:PXCelPboardType]) {
		[animation insertObject:[NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:PXCelPboardType]] inCelsAtIndex:targetDraggingIndex];
		return YES;
	} else if ([type isEqualToString:NSFilenamesPboardType]) {
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		BOOL loadedSomething = NO;
		for (NSString *filename in [filenames sortedArrayUsingSelector:@selector(compareNumeric:)])
    {
			NSImage *image = [[[NSImage alloc] initWithContentsOfFile:filename] autorelease];
			if (image != nil) {
				PXCel *cel = [[[PXCel alloc] initWithImage:image animation:animation atIndex:targetDraggingIndex] autorelease];
				if (!loadedSomething) 
        {
					loadedSomething = (cel != nil);
				}
        targetDraggingIndex++;
			}
		}
		return loadedSomething;
	}
	return NO;
}

- (BOOL)copyCelInFilmStripView:view atIndex:(int)currentIndex toIndex:(int)anotherIndex
{
	[animation copyCelFromIndex:currentIndex toIndex:anotherIndex];
	[filmStrip setNeedsDisplay:YES];
	return YES;
}

- (IBAction)duplicateCel:sender
{
	int selectedIndex = [filmStrip selectedIndex];
	[animation copyCelFromIndex:selectedIndex toIndex:selectedIndex+1];
}

- (BOOL)moveCelInFilmStripView:view fromIndex:(int)index1 toIndex:(int)index2
{
	if((index1 == index2) || (index2 == (index1+1))) { return NO; }
	[animation moveCelFromIndex:index1 toIndex:index2];
	return YES;
}

- (id)celAtIndex:(int)currentIndex
{
	return [animation objectInCelsAtIndex:currentIndex];
}
- (NSTimeInterval)durationOfCelAtIndex:(int)currentIndex
{
	return [[self celAtIndex:currentIndex] duration];	
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	[topSubview setMinDimension:oldMin andMaxDimension:oldMax];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	oldMin = [topSubview minDimension];
	oldMax = [topSubview maxDimension];
	[topSubview setMinDimension:[topSubview dimension] andMaxDimension:[topSubview dimension]];
	return proposedFrameSize;
}

- (IBAction)newCel:sender
{
	unsigned int newIndex = [filmStrip selectedIndex] + 1;
	if (newIndex == NSNotFound) {newIndex = [animation countOfCels];}
	[animation insertNewCelAtIndex:newIndex];
	[[animation objectInCelsAtIndex:newIndex] setDuration:[[animation objectInCelsAtIndex:newIndex - 1] duration]];
}

- (void)filmStripSelectionDidChange:note
{
	[self activateCel:[filmStrip selectedCel]];
}

- (BOOL)canDeleteCel
{
	return [self numberOfCels] > 1;
}

- (void)deleteCelsAtIndices:(NSIndexSet *)indices
{
	if([animation countOfCels] <= 1) { return; }
	int currentIndex = [indices firstIndex];
	do
	{
		[animation removeCel:[self celAtIndex:currentIndex]];
	} while ((currentIndex = [indices indexGreaterThanIndex:currentIndex]) != NSNotFound);	
}

- (IBAction)deleteCel:sender
{
	[self deleteCelsAtIndices:[filmStrip selectedIndices]];
}

- (IBAction)selectPreviousCel:sender
{
	int newIndex = [filmStrip selectedIndex];
	if (newIndex == NSNotFound)
	{
		NSBeep();
		return;
	}
	newIndex--;
	if (newIndex < 0)
		newIndex = [self numberOfCels] - 1;
	[self activateCel:[self celAtIndex:newIndex]];
}

- (IBAction)selectNextCel:sender
{
	unsigned int newIndex = [filmStrip selectedIndex];
	if (newIndex == NSNotFound)
	{
		NSBeep();
		return;
	}
	newIndex++;
	if (newIndex >= [self numberOfCels])
		newIndex = 0;
	[self activateCel:[self celAtIndex:newIndex]];
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(createAnimationFromImage:))
		return NO;
	else if ([menuItem action] == @selector(selectPreviousCel:))
	{
		return ([self numberOfCels] > 1);
	}
	else if ([menuItem action] == @selector(selectNextCel:))
	{
		return ([self numberOfCels] > 1);
	}
	else if ([menuItem action] == @selector(deleteCel:))
	{
		return [self canDeleteCel];
	}
	else if ([menuItem action] == @selector(copyCel:))
	{
		return activeCel != nil;
	}
	else if ([menuItem action] == @selector(cutCel:))
	{
		return (activeCel != nil) && ([self numberOfCels] > 1);
	}
	else if ([menuItem action] == @selector(pasteCel:))
	{
		return ([[[NSPasteboard generalPasteboard] types] containsObject:PXCelPboardType]);
	}
	else if ([menuItem action] == @selector(toggleAutomaticPalette:))
	{
		return NO; // no restriction for animations
	}
	return [super validateMenuItem:menuItem];
}

- (void)exportSequencePrompterDidEnd:prompter
{
	NSString *fileTemplate = [prompter fileTemplate];
	NSRange range = [fileTemplate rangeOfString:@"%f"];
	NSString *finalString = [fileTemplate substringToIndex:range.location];
	finalString = [finalString stringByAppendingString:@"%d"];
	finalString = [finalString stringByAppendingString:[fileTemplate substringFromIndex:range.location + 2]];
	int i;
	int numberOfCels = [animation countOfCels];
	NSString *directoryPath = [[[prompter savePanel] filenames] objectAtIndex:0];
	for (i = 0; i < numberOfCels; i++)
	{
		NSString *filePath = [[directoryPath copy] autorelease];
		if ([filePath characterAtIndex:[filePath length] - 1] != '/')
			filePath = [filePath stringByAppendingString:@"/"];
		filePath = [filePath stringByAppendingString:[NSString stringWithFormat:finalString, i + 1]];
		[[PXCanvasDocument dataRepresentationOfType:[prompter valueForKey:@"fileType"] withCanvas:[[animation objectInCelsAtIndex:i] canvas]] writeToFile:filePath atomically:YES];
	}
}

- (IBAction)exportToImageSequence:sender
{
	PXSequenceExportPrompter *prompter = [[PXSequenceExportPrompter alloc] initWithDocument:[self document]];
	[prompter beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(exportSequencePrompterDidEnd:)];
}

- (void)exportToQuicktimePrompterDidEnd:(NSSavePanel *)panel returnCode:(int)code contextInfo:(void *)info
{
	if (code == NSCancelButton) { return; }
	[panel orderOut:self];
	id sharedExporter = [[OSQTExporter alloc] init];
	int celCount = [animation countOfCels];
	int i;
	for (i = 0; i < celCount; i++)
	{
		[sharedExporter addImage:[[animation objectInCelsAtIndex:i] displayImage] forLength:[[animation objectInCelsAtIndex:i] duration]];
	}
	[sharedExporter exportToPath:[panel filename] parentWindow:[self window]];
}

- (IBAction)exportToQuicktime:sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setNameFieldLabel:@"Export to:"];
	[savePanel setPrompt:@"Export"];
	[savePanel beginSheetForDirectory:nil file:[[self document] displayName] modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(exportToQuicktimePrompterDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)scalePrompterFinished:prompter shouldScale:shouldScale
{
	if ([shouldScale boolValue])
	{
		id currentCanvas = [activeCel canvas];
		int celCount = [animation countOfCels];
		int i;
		for (i = 0; i < celCount; i++)
		{
			if ([[animation objectInCelsAtIndex:i] canvas] == currentCanvas) { continue; }
			[scaleController scaleCanvas:[[animation objectInCelsAtIndex:i] canvas]];
		}
	}
	[[[self document] undoManager] endUndoGrouping];
}

- (IBAction)scaleCanvas:(id) sender
{
	[scaleController setDelegate:self withCallback:@selector(scalePrompterFinished:shouldScale:)];
	[[[self document] undoManager] beginUndoGrouping];
	[super scaleCanvas:self];
}

- (void)prompter:aPrompter
didFinishWithSize:(NSSize)aSize
		position:(NSPoint)position
 backgroundColor:(NSColor *)color
{
	[animation setSize:aSize withOrigin:position backgroundColor:color];
}

- (IBAction)crop:sender
{
	NSRect selectedRect = [canvas selectedRect];
	[[[self document] undoManager] beginUndoGrouping];
	[animation setSize:selectedRect.size withOrigin:NSMakePoint(NSMinX(selectedRect) * -1, NSMinY(selectedRect) * -1) backgroundColor:[[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]];
	[canvas deselect];
	[[[self document] undoManager] endUndoGrouping];
}

- (IBAction)copyCel:sender
{
	[self writeCelsAtIndices:[filmStrip selectedIndices] toPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)cutCel:sender
{
	[self copyCel:sender];
	[self deleteCel:sender];
}

- (IBAction)pasteCel:sender
{
	int newIndex = [filmStrip selectedIndex];
	if (newIndex == NSNotFound)
		newIndex = [self numberOfCels];
	else
		newIndex++;
	if (![self insertCelIntoFilmStripView:filmStrip fromPasteboard:[NSPasteboard generalPasteboard] atIndex:newIndex]) { return; }
}

- (IBAction)toggleAutomaticPalette:sender
{
	// intentionall noop
}

@end

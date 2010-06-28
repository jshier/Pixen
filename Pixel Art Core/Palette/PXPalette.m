//
//  PXPalette.m
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
//

#import "PXPalette.h"
#import "PathUtilities.h"
#import "NSColor+PXPaletteAdditions.h"
#import "NSString+Comparison.h"

PXColorBucket *PXColorBucket_alloc()
{
	return (PXColorBucket *)calloc(1, sizeof(PXColorBucket));
}

PXColorBucket *PXColorBucket_init(PXColorBucket *self, NSColor *color, unsigned int index)
{
	self->next = NULL;
	self->color = [color retain];
	self->index = index;
	return self;
}

void PXColorBucket_dealloc(PXColorBucket *self)
{
	if(!self) {
		return;
	}
	if (self->next != NULL) {
		PXColorBucket_dealloc(self->next);
		self->next = NULL;
	}
	if(self->color) {
		[self->color release];
	}
	free(self);
}

/////////////////////// BUCKET METHODS ///////////////////////

void PXPalette_insertColorBucket(PXPalette *self, PXColorBucket *bucket)
{
	unsigned int hash = [bucket->color paletteHash];
	bucket->next = self->reverseHashTable[hash];
	self->reverseHashTable[hash] = bucket;
}

PXColorBucket *PXPalette_bucketForColor(PXPalette *self, NSColor *color)
{
	unsigned int hash = [color paletteHash];
	PXColorBucket *bucket = self->reverseHashTable[hash];
	while (bucket != NULL && ![color isEqual:bucket->color]) {
		bucket = bucket->next;
	}
	return bucket;
}

void PXPalette_removeBucketForColor(PXPalette *self, NSColor *color)
{
	unsigned int hash = [color paletteHash];
	PXColorBucket *bucket = self->reverseHashTable[hash];
	PXColorBucket *prevBucket = NULL;
	while (bucket != NULL && ![bucket->color isEqual:color]) {
		prevBucket = bucket;
		bucket = bucket->next;
	}
	if (bucket != NULL) {
		if (prevBucket == NULL) {
			self->reverseHashTable[hash] = bucket->next;
		} else {
			prevBucket->next = bucket->next;
		}
		bucket->next = NULL;
		PXColorBucket_dealloc(bucket);
	}
}

//////////////////////////////////////////////////////////////


NSColor *_PXPalette_correctColor(NSColor *color)
{
	NSColor *colorToCheck = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	if ([colorToCheck alphaComponent] == 0) {
		colorToCheck = [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]; // so we don't get lots of clear colors
	}
	return colorToCheck;
}

static PXPalette **systemPalettes = NULL;
static unsigned int systemPalettesCount = 0;

static PXPalette **userPalettes = NULL;
static unsigned int userPalettesCount = 0;

NSDictionary *PXPalette_dictForArchiving(PXPalette *self)
{
	NSMutableDictionary *paletteDict = [NSMutableDictionary dictionaryWithCapacity:4];
	[paletteDict setObject:[NSNumber numberWithInt:self->size] forKey:@"size"];
	// can't just copy bytes of the array of colors because they're pointers.
	int i;
	NSMutableArray *tempArray= [[[NSMutableArray alloc] init] autorelease];
	for (i = 0; i < self->colorCount; i++)
	{
		[tempArray addObject:self->colors[i].color];
	}
	[paletteDict setObject:self->name forKey:@"name"];
	[paletteDict setObject:tempArray forKey:@"colors"];
	return paletteDict;
}

void PXPalette_saveChanges(PXPalette *self)
{
	if(self->canSave)
	{
		NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:self->name] stringByAppendingPathExtension:PXPaletteSuffix];
		id dict = PXPalette_dictForArchiving(self);
		[NSKeyedArchiver archiveRootObject:dict toFile:path];
	}
}

PXPalette *PXPalette_initWithDictionary(PXPalette *self, NSDictionary *dict)
{
	PXPalette_initWithoutBackgroundColor(self);
	PXPalette_setName(self, [dict objectForKey:@"name"]);
	PXPalette_resize(self, [[dict objectForKey:@"size"] intValue]);
	for (id current in [dict objectForKey:@"colors"])
	{
		PXPalette_addColor(self, current);
	}
	return self;
}

BOOL PXPalette_isDocumentPalette(PXPalette *self)
{
	if (self->canSave) { return NO; } // Must be a user palette.
	// Let's see if it's a system palette.
	int systemCount = PXPalette_getSystemPalettes(NULL,0);
	PXPalette **systemPalettes = calloc(systemCount, sizeof(PXPalette *));
	PXPalette_getSystemPalettes(systemPalettes, 0);
	int i;
	for (i = 0; i < systemCount; i++)
	{
		if (self == systemPalettes[i])
		{
			free(systemPalettes);
			return NO;
		}
	}
	free(systemPalettes);
	return YES;
}

NSArray *CreateGrayList()
{
	float rgb = 0;
	float alpha = 1;
	NSMutableArray *grays = [NSMutableArray arrayWithCapacity:256];
	NSColor *color;
	int i = 0;
	//Maybe we can factor these into a series of function calls?
	for (i=0; i<64; i++) {
		rgb = (float)i / 64.0;
		color = [NSColor colorWithDeviceRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	rgb = 0;
	for (i=0; i<64; i++) {
		alpha = log2(64 - i) * 0.1667;
		color = [NSColor colorWithDeviceRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	rgb = .5;
	for (i=0; i<64; i++) {
		alpha = log2(64 - i) * 0.1667;
		color = [NSColor colorWithDeviceRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	rgb = 1;
	for (i=0; i<64; i++) {
		alpha = log2(64 - i) * 0.1667;
		color = [NSColor colorWithDeviceRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	return grays;
}

unsigned int PXPalette_getSystemPalettes(PXPalette **pals, unsigned initialIndex)
{
	NSArray *lists = [NSColorList availableColorLists];
	int newCount = [lists count] + 1;
	if(pals == NULL) { return newCount; }
	if(systemPalettes == NULL)
	{
		systemPalettes = calloc(newCount, sizeof(PXPalette *));
	}
	if(newCount != systemPalettesCount)
	{
		int i;
		for (i = 0; i < systemPalettesCount; i++)
		{
			PXPalette_release(systemPalettes[i]);
		}
		free(systemPalettes);
		systemPalettes = calloc(newCount, sizeof(PXPalette *));
		for (i = 0; i < [lists count]; i++)
		{
			NSEnumerator *keyEnumerator;
			NSColorList *current = [lists objectAtIndex:i];
			NSString *currentKey;
			PXPalette *palette = PXPalette_alloc();
			PXPalette_initWithoutBackgroundColor(palette);
			PXPalette_setName(palette, [current name]);
			keyEnumerator = [[current allKeys] objectEnumerator];
			while((currentKey = [keyEnumerator nextObject]))
			{
				PXPalette_addColor(palette,[current colorWithKey:currentKey]);
			}
			palette->isSystemPalette = YES;
			palette->canSave = NO;
			systemPalettes[i] = palette;
		}
		NSMutableArray *grays = [NSMutableArray arrayWithArray:CreateGrayList()];
		PXPalette *palette = PXPalette_alloc();
		PXPalette_initWithoutBackgroundColor(palette);
		PXPalette_setName(palette, NSLocalizedString(@"GRAYSCALE", @"Grayscale"));
		palette->isSystemPalette = YES;
		palette->canSave = NO;
		for (id current in grays)
		{
			PXPalette_addColor(palette, current);
		}
		systemPalettes[[lists count]] = palette;
		systemPalettesCount = newCount;
	}
	int i;
	for (i = initialIndex; i < (initialIndex + systemPalettesCount); i++)
	{
		pals[i] = systemPalettes[i - initialIndex];
	}
	return systemPalettesCount;
}

unsigned int PXPalette_getUserPalettes(PXPalette **pals, unsigned initialIndex)
{
//FIXME: this code will leak or worse(probably just leak) if palettes are removed at runtime.
	NSMutableArray *paths = [NSMutableArray array];
	id enumerator = [[NSFileManager defaultManager] enumeratorAtPath:GetPixenPaletteDirectory()], current;
	while((current = [enumerator nextObject]))
	{
		if([[current pathExtension] isEqual:PXPaletteSuffix])
		{
			//removing path extension so it will sort correctly.
			[paths addObject:[current stringByDeletingPathExtension]];
		}
	}
	[paths sortUsingSelector:@selector(compareNumeric:)];
	int newCount = [paths count];
	if(pals == NULL) { return newCount; }
	if(userPalettes == NULL)
	{
		userPalettes = calloc(newCount, sizeof(PXPalette *));
	}
	if(newCount != userPalettesCount)
	{
		int i;
		for (i = 0; i < [paths count]; i++)
		{
			NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:[paths objectAtIndex:i]] stringByAppendingPathExtension:PXPaletteSuffix];
			id object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
			PXPalette *palette = NULL;
			palette = PXPalette_initWithDictionary(PXPalette_alloc(), object);
			palette->isSystemPalette = NO;
			palette->canSave = YES;
			userPalettes[i] = palette;
		}
		userPalettesCount = newCount;
	}
	int i;
	for (i = initialIndex; i < (initialIndex + userPalettesCount); i++)
	{
		pals[i] = userPalettes[i - initialIndex];
	}
	return userPalettesCount;
}

PXPalette *PXPalette_alloc()
{
	PXPalette *palette = (PXPalette *)calloc(1, sizeof(PXPalette));
	palette->retainCount = 1;
	return palette;
}

void PXPalette_dealloc(PXPalette *self)
{
	int i;
	if(self->reverseHashTable) {
		for (i=0; i<65536; i++) {
			if (self->reverseHashTable[i] != NULL) {
				PXColorBucket_dealloc(self->reverseHashTable[i]);
			}
		}
		free(self->reverseHashTable);
		self->reverseHashTable = nil;
	}
	if(self->colors) {
		for (i = 0; i < self->size; i++)
		{
			if(self->colors[i].color)
			{
				[self->colors[i].color release];
			}
		}
		free(self->colors);		
		self->colors = nil;
	}
	if(self->name) {		
		[self->name release];
		self->name = nil;
	}
	free(self);
}

PXPalette *PXPalette_initWithoutBackgroundColor(PXPalette *self)
{
	self->canSave = NO;
	self->isSystemPalette = NO;
	self->size = 0;
	self->colorCount = 0;
	self->reverseHashTable = (PXColorBucket **)calloc(65536, sizeof(PXColorBucket *));
	self->name = @"";
	return self;
}

PXPalette *PXPalette_init(PXPalette *self)
{
	PXPalette_initWithoutBackgroundColor(self);
	PXPalette_addBackgroundColor(self);
	return self;
}

PXPalette *PXPalette_copy(PXPalette *self)
{
	PXPalette *newPalette = PXPalette_initWithoutBackgroundColor(PXPalette_alloc());
	newPalette->name = [self->name copy];
	int i;
	for (i = 0; i < self->colorCount; i++) {
		PXPalette_addColorPair(newPalette, self->colors[i]);
	}
	return newPalette;
}

void PXPalette_encodeWithCoder(PXPalette *self, NSCoder *coder)
{
	[coder encodeObject:PXPalette_dictForArchiving(self) forKey:@"palette"];
	[coder encodeObject:[NSNumber numberWithInt:3] forKey:@"paletteVersion"];
}

PXPalette *PXPalette_initWithCoder(PXPalette *self, NSCoder *coder)
{
	return PXPalette_initWithDictionary(self, [coder decodeObjectForKey:@"palette"]);
}

PXPalette *PXPalette_retain(PXPalette *self)
{
	if(!self)
	{
		return NULL;
	}
	self->retainCount++;
	return self;
}

PXPalette *PXPalette_release(PXPalette *self)
{
	if(!self) { return NULL; }
	self->retainCount--;
	if (self->retainCount <= 0) {
		PXPalette_dealloc(self);
		return NULL;
	}
	return self;
}

void PXPalette_insertColorAtIndex(PXPalette *self, NSColor *color, unsigned index)
{
	PXPalette_addColorPair(self, (PXPaletteColorPair){color, 1});
	PXPalette_moveColorAtIndexToIndex(self,self->colorCount-1,index);
}

void PXPalette_removeAlphaComponents(PXPalette *self)
{
	int i;
	for (i = 0; i < self->colorCount; i++)
	{
		NSColor *color = [[PXPalette_colorAtIndex(self, i) retain] autorelease];
		if([color alphaComponent] == 0 || [color alphaComponent] == 1) { continue; }
		PXPalette_setColorAtIndex(self,[color colorWithAlphaComponent:1],i);
	}
}

NSString *PXPalette_name(PXPalette *self)
{
	return self->name;
}

void PXPalette_setName(PXPalette *self, NSString *name)
{
	if([name isEqual:self->name])
	{
		PXPalette_saveChanges(self);
		return;
	}
	id oldName = [self->name autorelease];
	if(self->canSave && [[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		NSString *name = self->name;
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")] setKeyEquivalent:@""];
		NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
		[button setKeyEquivalent:@"\r"];
		[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"A palette by that name already exists.  Would you like to overwrite the existing palette?", @"A palette by that name already exists.  Would you like to overwrite the existing palette?"), name]];
		[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"BACKGROUND_DELETE_INFORMATIVE_TEXT")];
		if([alert runModal] == NSAlertFirstButtonReturn)
		{
			return;
		}
	}
	self->name = [name retain];
	PXPalette_saveChanges(self);
	if(self->canSave)
	{
        //FIXME: Handle error.
		[[NSFileManager defaultManager] removeItemAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:oldName] stringByAppendingPathExtension:PXPaletteSuffix] error:NULL];
	}
}

void PXPalette_addColorPair(PXPalette *self, PXPaletteColorPair pair)
{
	if(!self) {
		return;
	}
	NSColor *colorToAdd = _PXPalette_correctColor(pair.color);
	if(!colorToAdd) { return; }
  pair.color = [colorToAdd retain];
	if (self->size - self->colorCount <= 0) {
		if (self->size < 64) {
			PXPalette_resize(self, 64);
		} else {
			PXPalette_resize(self, self->size * 2);
		}
	}
	self->colors[self->colorCount] = pair;
	PXPalette_insertColorBucket(self, PXColorBucket_init(PXColorBucket_alloc(), colorToAdd, self->colorCount));
	self->colorCount++;
	PXPalette_saveChanges(self);  
}

void PXPalette_addColor(PXPalette *self, NSColor *color)
{
  PXPalette_addColorPair(self, (PXPaletteColorPair){color, 1});
}

void PXPalette_resize(PXPalette *self, unsigned int newSize)
{
	unsigned int i;
	
	if (self->size == newSize) {
		return;
	}
	
	PXPaletteColorPair *oldColors = self->colors;
	if (newSize > 0) {
		self->colors = (PXPaletteColorPair *)calloc(newSize, sizeof(PXPaletteColorPair));
	} else {
		self->colors = NULL;
	}
	
	for (i=0; i<self->size; i++) {
		if (i < newSize) {
			self->colors[i] = oldColors[i];
		} else if (i < self->colorCount) {
			if (oldColors == NULL) {
				i = self->colorCount;
			} else {
				PXPalette_removeBucketForColor(self, oldColors[i].color);
				[oldColors[i].color release];
			}
		}
	}
	
	if (self->size > 0) {
		free(oldColors);
	}
	self->size = newSize;
	if (self->colorCount > self->size) {
		self->colorCount = self->size;
	}
}

NSColor *PXPalette_colorAtIndex(PXPalette *self, unsigned index) {
	return self->colors[index].color;
}


void PXPalette_swapColorsAtIndex(PXPalette* self, unsigned int colorIndex1, unsigned int colorIndex2)
{
	if (colorIndex1 >= self->colorCount || colorIndex2 >= self->colorCount) {
		return;
	}
	PXPaletteColorPair color1 = self->colors[colorIndex1];
	PXPaletteColorPair color2 = self->colors[colorIndex2];
	PXColorBucket *bucket1 = PXPalette_bucketForColor(self, color1.color);
	PXColorBucket *bucket2 = PXPalette_bucketForColor(self, color2.color);
	if (bucket1 != NULL) {
		bucket1->index = colorIndex2;
	}
	if (bucket2 != NULL) {
		bucket2->index = colorIndex1;
	}
	self->colors[colorIndex1] = color2;
	self->colors[colorIndex2] = color1;
	PXPalette_saveChanges(self);
}

void PXPalette_swapColors(PXPalette* self, NSColor *color1, NSColor *color2)
{
	PXPalette_swapColorsAtIndex(self,
								PXPalette_indexOfColorAddingIfNotPresent(self, color1),
								PXPalette_indexOfColorAddingIfNotPresent(self, color2));
}

void PXPalette_addBackgroundColor(PXPalette *self)
{
	PXPalette_addColorWithoutDuplicating(self, [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace]);
}

void PXPalette_addColorWithoutDuplicating(PXPalette *self, NSColor *color)
{
	PXPalette_indexOfColorAddingIfNotPresent(self, color);
}

unsigned int PXPalette_indexOfColorClosestToAddingIfTooFar(PXPalette *self, NSColor *color, float threshold, BOOL *added)
{
	unsigned int i;
	float distance, minDistance=INFINITY;
	unsigned int closestIndex=0;
	for (i=0; i<self->colorCount; i++) {
		distance = [self->colors[i].color distanceTo:color];
		if (distance < minDistance) {
			minDistance = distance;
			closestIndex = i;
		}
	}
  if(minDistance <= threshold)
  {
    *added=NO;
    return closestIndex;
  }
  *added=YES;
  PXPalette_addColor(self, color);
  return self->colorCount-1;
}

unsigned int PXPalette_indexOfColorClosestTo(PXPalette *self, NSColor *color)
{
	unsigned int i;
	float distance, minDistance=INFINITY;
	unsigned int closestIndex=0;
	for (i=0; i<self->colorCount; i++) {
		distance = [self->colors[i].color distanceTo:color];
		if (distance < minDistance) {
			minDistance = distance;
			closestIndex = i;
		}
	}
	return closestIndex;
}

NSColor *PXPalette_colorClosestTo(PXPalette *self, NSColor *color)
{
	unsigned int index = PXPalette_indexOfColorClosestTo(self, color);
	return self->colors[index].color;
}

unsigned int _PXPalette_indexOfCorrectedColor(PXPalette *self, NSColor *colorToCheck)
{
	if (self == NULL) { return -1; }
	PXColorBucket *bucket = PXPalette_bucketForColor(self, colorToCheck);
	if (bucket != NULL) {
		return bucket->index;
	}
	else
		return -1;
}

unsigned int PXPalette_indexOfColor(PXPalette *self, NSColor *color)
{
	if (self == NULL) { return -1; }
	return _PXPalette_indexOfCorrectedColor(self, _PXPalette_correctColor(color));
}

unsigned int PXPalette_indexOfColorAddingIfNotPresent(PXPalette *self, NSColor *color)
{
	NSColor *correctedColor = _PXPalette_correctColor(color);
	unsigned int index = _PXPalette_indexOfCorrectedColor(self, correctedColor);
	if (index != -1) {
		return index;
	}
	PXPalette_addColor(self, correctedColor);
	return self->colorCount - 1;
}

  //this one keeps the colors sorted, as long as it's the only way used to take colors out.
void PXPalette_decrementColorCount(PXPalette *self, NSColor *color, int amt)
{
	NSColor *correctedColor = _PXPalette_correctColor(color);
  BOOL added = NO;
	unsigned int idx = PXPalette_indexOfColorClosestToAddingIfTooFar(self, correctedColor, 0.05f, &added);
  if(added)
  {
    self->colors[idx].frequency = 0;
  }
  if(idx != -1)
  {
    NSInteger freq = self->colors[idx].frequency;
    freq-=amt;
    if(freq <= 0) 
    {
      PXPalette_removeColorAtIndex(self, idx);
      return;
    }
    self->colors[idx].frequency=freq;
    if(idx < self->colorCount-1)
    {
      unsigned int newIdx = idx+1;
      while((freq < self->colors[newIdx].frequency) && (newIdx < self->colorCount-1))
      {
        newIdx++;
      }
      if(freq < self->colors[newIdx].frequency)
      {
        PXPalette_moveColorAtIndexToIndex(self, idx, newIdx);
      }
    }
  }
}
  //this one keeps the colors sorted, as long as it's the only way used to put colors in.
void PXPalette_incrementColorCount(PXPalette *self, NSColor *color, int amt)
{
    //this could be hilariously accelerated if we were coalescing color updates.
	NSColor *correctedColor = _PXPalette_correctColor(color);
  BOOL added = NO;
	unsigned int idx = PXPalette_indexOfColorClosestToAddingIfTooFar(self, correctedColor, 0.05f, &added);
  if(added)
  {
    self->colors[idx].frequency = 0;
  }
  if(idx != -1)
  {
    NSInteger freq = self->colors[idx].frequency;
    freq+=amt;
    self->colors[idx].frequency=freq;
    if(idx > 0)
    {
      unsigned int newIdx = idx-1;
      while((freq > self->colors[newIdx].frequency) && (newIdx > 0))
      {
        newIdx--;
      }
      if(freq > self->colors[newIdx].frequency)
      {
        PXPalette_moveColorAtIndexToIndex(self, idx, newIdx);
      }
    }
  }
  else
  {
      //new colors always get pushed onto the end, by definition
    PXPalette_addColor(self, correctedColor);
  }
}

NSColor *PXPalette_restrictColor(PXPalette *self, NSColor *color)
{
	return color;
}

double PXPalette_hashEfficiency(PXPalette *self)
{
	int i;
	int bucketsFilled = 0;
	for (i=0; i<65536; i++) {
		if (self->reverseHashTable[i] != NULL) {
			bucketsFilled++;
		}
	}
	return (double)bucketsFilled / (double)(self->colorCount);
}

int PXPalette_colorCount(PXPalette *self)
{
	return self->colorCount;
}

NSArray *PXPalette_colors(PXPalette *self)
{
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:self->colorCount];
  for(int i = 0; i < self->colorCount; i++)
  {
    [result addObject:self->colors[i].color];
  }
  return result;
}

void PXPalette_removeColorAtIndex(PXPalette *self, unsigned int index)
{
	NSColor *color = self->colors[index].color;
	PXPalette_removeBucketForColor(self, color);
	[color release];
	int i;
	for (i = index + 1; i < self->colorCount; i++)
	{
		self->colors[i - 1] = self->colors[i];
		PXPalette_bucketForColor(self, self->colors[i].color)->index--;
	}
	self->colors[self->colorCount].color = nil;
	self->colors[self->colorCount].frequency = 0;
	self->colorCount -= 1;
	PXPalette_saveChanges(self);
}

void PXPalette_setColorAtIndex(PXPalette *self, NSColor *color, unsigned int index)
{
	if (index > self->colorCount) {
		return;
	}
	NSColor *oldColor = self->colors[index].color;
	PXPalette_removeBucketForColor(self, oldColor);
	[oldColor release];
  NSColor *correctedColor = _PXPalette_correctColor(color);
	self->colors[index].color = [correctedColor retain];
	PXPalette_insertColorBucket(self, PXColorBucket_init(PXColorBucket_alloc(), correctedColor, index));
	PXPalette_saveChanges(self);
}

// 5 to 3
//    1 2 3 4 5 6
//    1 2 5 3 4 6
//          ^ start at 3+1
//            ^ go to 5

// 3 to 5
//    1 2 3 4 5 6
//    1 2 4 5 3 6
//        ^ start at 3
//          ^ go to 5-1

  //swap 1 to 0
  // 0 1
  // $ ^
  // 

void PXPalette_moveColorAtIndexToIndex(PXPalette *self, unsigned int index1, unsigned int index2)
{
	int i;
  PXPaletteColorPair src = self->colors[index1];
  PXColorBucket *targBucket = PXPalette_bucketForColor(self, src.color);
  int sign = (index2 > index1) ? 1 : -1;
  for(i = index1; i != index2; i+=sign)
  {
      //i = i+sign
		self->colors[i] = self->colors[i+sign];
    PXColorBucket *oldBucket = PXPalette_bucketForColor(self, self->colors[i].color);
		oldBucket->index = i;
  }
	self->colors[index2] = src;
  targBucket->index = index2;
	PXPalette_saveChanges(self);
}

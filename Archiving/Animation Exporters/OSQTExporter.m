//
//  OSQTExporter.m
//  OSQTExporter
//
//  Created by Andy Matuschak on 8/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSQTExporter.h"
#import "OSProgressPopup.h"
#import <QuickTime/QuickTime.h>

#import <QTKit/QTKit.h>	

@implementation OSQTExporter

- (void)dealloc
{
	[qtMovie release];
	[super dealloc];
}

- (void)addImage:(NSImage *)image forLength:(NSTimeInterval)seconds
{
	// Put the passed image on a white background so transparency doesn't look black.
	NSImage *newImage = [[[NSImage alloc] initWithSize:[image size]] autorelease];
	[newImage lockFocus];
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(0, 0, [image size].width, [image size].height));
	[image compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	[newImage unlockFocus];
	
	if (!qtMovie)
	{
		// We have to do fanciness to get a new QTMovie out of an image. Sorry.
		NSString *tempName = [NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]];
		[[newImage TIFFRepresentation] writeToFile:tempName atomically:YES];
		qtMovie = [[QTMovie movieWithFile:tempName error:nil] retain];
		[qtMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
		[qtMovie scaleSegment:QTMakeTimeRange(QTZeroTime, [qtMovie duration]) newDuration:QTMakeTime(seconds * 600, 600)];
	}
	else
	{
		[qtMovie addImage:newImage forDuration:QTMakeTime(seconds * 600, 600) withAttributes:[NSDictionary dictionaryWithObject: @"tiff" forKey: QTAddImageCodecType]];
	}
}

- (void)exportToPath:(NSString *)path parentWindow:(NSWindow *)newParentWindow
{
	//[NSApp beginSheet:window modalForWindow:parentWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];	
	
	ComponentInstance sc = NULL;
	ComponentDescription compDesc;
    Component movieExporterComponent = 0;
	SCSpatialSettings ss;

    MovieExportComponent exporter = NULL;
	OSErr err = noErr;
	Boolean canceled = false;
	if (!qtMovie)
	{
		[NSException raise:@"Unset movie" format:@"Empty movie in OSQTExporter! You must first add images to it."];
		return;
	}
	Movie movie = [qtMovie quickTimeMovie];
	
	compDesc.componentType = MovieExportType;
    compDesc.componentSubType = MovieFileType;
    compDesc.componentManufacturer = kAppleManufacturer;
    compDesc.componentFlags = 0;
    compDesc.componentFlagsMask = cmpIsMissing;
    
    movieExporterComponent = FindNextComponent(NULL, &compDesc);
    if (movieExporterComponent == NULL)
        return;
	
    err = OpenAComponent(movieExporterComponent, &exporter);
    if (err)
        return;
	
    if (gExportSettings == NULL) {
        // set up some initial default settings; use Standard Compression just to help build atom container
        err = OpenADefaultComponent( StandardCompressionType, StandardCompressionSubType, &sc );
		
        ss.codecType = kMPEG4VisualCodecType;
        ss.codec = NULL;
        ss.depth = 0;
        ss.spatialQuality = codecNormalQuality;
        
        SCSetInfo(sc, scSpatialSettingsType, &ss);
		
#if 0        
        // not appropriate for non-temporal codecs
        if ( codecDoesTemporal( ss.codecType ) ) {
            ts.temporalQuality = codecNormalQuality;
            ts.frameRate = 30L<<16;
            ts.keyFrameRate = 30;
        } else {
            ts.temporalQuality = 0;
            ts.frameRate = 0;
            ts.keyFrameRate = 0;
        }
        
        SCSetInfo( sc, scTemporalSettingsType, &ts );
#endif
		
        SCGetSettingsAsAtomContainer(sc, &gExportSettings);    
		
        CloseComponent(sc);
        
        // first time thru, set a few settings
        if (gExportSettings != NULL) {
            UInt32 aLong = 0;
            UInt8 aChar;
            QTAtom videAtom = 0;
            QTAtom saveAtom = 0;
            
            // YES: video
            aChar = true;
            err = QTInsertChild( gExportSettings, kParentAtomIsContainer, kQTSettingsMovieExportEnableVideo, 1, 0, sizeof(aChar), &aChar, nil );
            
            // NO: audio
			aChar = false;
			err = QTInsertChild( gExportSettings, kParentAtomIsContainer, kQTSettingsMovieExportEnableSound, 1, 0, sizeof(aChar), &aChar, nil );
            
            // NO: save as Fast Start
            err = QTInsertChild( gExportSettings, kParentAtomIsContainer, kQTSettingsMovieExportSaveOptions, 1, 0, 0, nil, &saveAtom );
            aChar = false;
            err = QTInsertChild( gExportSettings, saveAtom, kQTSettingsMovieExportSaveForInternet, 1, 0, sizeof(aChar), &aChar, nil );
            
            // video options
            videAtom = QTFindChildByID( gExportSettings, kParentAtomIsContainer, kQTSettingsVideo, 1, nil );
            if (videAtom == 0)
                err = QTInsertChild( gExportSettings, kParentAtomIsContainer, kQTSettingsVideo, 1, 0, 0, nil, &videAtom );
            
            aLong = FixRatio(320,1);
            aLong = EndianU32_NtoB(aLong);
           // err = QTInsertChild( gExportSettings, videAtom, movieExportWidth, 1, 0, sizeof(aLong), &aLong, nil );
			
            aLong = FixRatio(240,1);
            aLong = EndianU32_NtoB(aLong);
           // err = QTInsertChild( gExportSettings, videAtom, movieExportHeight, 1, 0, sizeof(aLong), &aLong, nil );
        }
    }
    
    if (gExportSettings == NULL)
        return;
	
    // wrap 'em up, I'll take 'em....
    err = MovieExportSetSettingsFromAtomContainer(exporter, gExportSettings);
    
    // get the export settings from the user
    err = MovieExportDoUserDialog(exporter, movie, NULL, 0, 0, &canceled);
    
	if (canceled) { return; }
	
    QTDisposeAtomContainer(gExportSettings);
    gExportSettings = NULL;
	
    // get the selected export settings as an atom container (so we can pass them to the thread)
    err = MovieExportGetSettingsAsAtomContainer(exporter, &gExportSettings);
	
	parentWindow = newParentWindow;
	[qtMovie setDelegate:self];
	tempPath = [[NSString stringWithCString:tmpnam(nil) encoding:[NSString defaultCStringEncoding]] retain];
	[qtMovie writeToFile:tempPath withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:MovieFileType], QTMovieExportType, [NSNumber numberWithLong:kAppleManufacturer], QTMovieExportManufacturer, [NSNumber numberWithBool:YES], QTMovieExport, [NSData dataWithBytes:*gExportSettings length:GetHandleSize(gExportSettings)], QTMovieExportSettings, nil]];
	//[target performSelector:selector withObject:tempPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
		[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
	[[NSFileManager defaultManager] movePath:tempPath toPath:path handler:nil];
	DisposeHandle(gExportSettings);
}

- (BOOL)movie:(QTMovie *)movie shouldContinueOperation:(NSString *)op withPhase:(QTMovieOperationPhase)phase atPercent:(NSNumber *)percent withAttributes:(NSDictionary *)attributes
{
	switch (phase)
	{
		case QTMovieOperationBeginPhase:
			[[OSProgressPopup sharedProgressPopup] setCanCancel:YES];
			[[OSProgressPopup sharedProgressPopup] beginOperationWithStatusText:@"Exporting Movie..." parentWindow:parentWindow];
			break;
		case QTMovieOperationUpdatePercentPhase:
			[[OSProgressPopup sharedProgressPopup] setProgress:[percent doubleValue] * 100];
			break;
		case QTMovieOperationEndPhase:
			[[OSProgressPopup sharedProgressPopup] endOperation];
			break;
	}
	
	// This is such an amazing hack. But it was provided by Apple!
	NSButton *cancelButton = [[OSProgressPopup sharedProgressPopup] valueForKey:@"cancelButton"];
	NSEvent *event = [[[OSProgressPopup sharedProgressPopup] valueForKey:@"window"] nextEventMatchingMask:NSLeftMouseUpMask untilDate:[NSDate distantPast] inMode:NSDefaultRunLoopMode dequeue:YES];
	if (event && NSPointInRect([event locationInWindow], [cancelButton frame]))
	{
		[cancelButton performClick:self];
		[self movie:movie shouldContinueOperation:nil withPhase:QTMovieOperationEndPhase atPercent:nil withAttributes:nil];
		tempPath = nil;
		return NO;
	}
	return YES;
}

@end

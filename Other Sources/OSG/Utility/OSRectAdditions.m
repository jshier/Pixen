//
//  OSRectAdditions.m
//  Pixen
//
//  Created by Andy Matuschak on 12/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "OSRectAdditions.h"

NSRect OSCenterRectInRect(NSRect rectToFit, NSRect fitRect, float inset)
{
	NSRect output;
	output.origin = fitRect.origin;
	fitRect.size.width -= inset*2;
	fitRect.size.height -= inset*2;
	
	if (rectToFit.size.width > rectToFit.size.height)
	{
		if (rectToFit.size.width > fitRect.size.width)
		{
			output.size.width = fitRect.size.width;
			output.size.height = ceilf(rectToFit.size.height * (fitRect.size.width / rectToFit.size.width));
		}
		else
			output.size = rectToFit.size;
	}
	else
	{
		if (rectToFit.size.height > fitRect.size.height)
		{
			output.size.height = fitRect.size.height;
			output.size.width = ceilf(rectToFit.size.width * (fitRect.size.height / rectToFit.size.height));
		}
		else
			output.size = rectToFit.size;
	}
	
	if (output.size.width < fitRect.size.width)
		output.origin.x += ceilf((fitRect.size.width / 2) - (output.size.width / 2));
	if (output.size.height < fitRect.size.height)
		output.origin.y += ceilf((fitRect.size.height / 2) - (output.size.height / 2));
	
	output.origin.x += inset;
	output.origin.y += inset;
	
	return output;
}
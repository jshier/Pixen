//
//  CTGradient.m
//
//  Created by Chad Weider on 2/14/07.
//  Writtin by Chad Weider.
//
//  Released into public domain on 4/10/08.
//
//  Version: 1.8

#import "CTGradient.h"

@interface CTGradient (Private)
- (void)_commonInit;
- (void)setBlendingMode:(CTGradientBlendingMode)mode;
- (void)addElement:(CTGradientElement*)newElement;

- (CTGradientElement *)elementAtIndex:(unsigned)index;

- (CTGradientElement)removeElementAtIndex:(unsigned)index;
- (CTGradientElement)removeElementAtPosition:(float)position;
@end

@implementation CTGradient
/////////////////////////////////////Initialization Type Stuff
- (id)init
  {
  self = [super init];
  
  if (self != nil)
	{
	[self _commonInit];
	[self setBlendingMode:CTLinearBlendingMode];
	}
  return self;
  }

- (void)_commonInit
  {
  elementList = nil;
  }

- (void)dealloc
  {
  CGFunctionRelease(gradientFunction);
  
  CTGradientElement *elementToRemove = elementList;
  while(elementList != nil)
	{
	elementToRemove = elementList;
	elementList = elementList->nextElement;
	free(elementToRemove);
	}
  
  [super dealloc];
  }

- (id)copyWithZone:(NSZone *)zone
  {
  CTGradient *copy = [[[self class] allocWithZone:zone] init];
  
  //now just copy my elementlist
  CTGradientElement *currentElement = elementList;
  while(currentElement != nil)
	{
	[copy addElement:currentElement];
	currentElement = currentElement->nextElement;
	}
  
  [copy setBlendingMode:blendingMode];
  
  return copy;
  }

- (void)encodeWithCoder:(NSCoder *)coder
  {
  if([coder allowsKeyedCoding])
	{
	unsigned count = 0;
	CTGradientElement *currentElement = elementList;
	while(currentElement != nil)
		{
		[coder encodeValueOfObjCType:@encode(float) at:&(currentElement->red)];
		[coder encodeValueOfObjCType:@encode(float) at:&(currentElement->green)];
		[coder encodeValueOfObjCType:@encode(float) at:&(currentElement->blue)];
		[coder encodeValueOfObjCType:@encode(float) at:&(currentElement->alpha)];
		[coder encodeValueOfObjCType:@encode(float) at:&(currentElement->position)];
		
		count++;
		currentElement = currentElement->nextElement;
		}
	[coder encodeInt:count forKey:@"CTGradientElementCount"];
	[coder encodeInt:blendingMode forKey:@"CTGradientBlendingMode"];
	}
  else
	[NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders"];
  }

- (id)initWithCoder:(NSCoder *)coder
  {
  [self _commonInit];
  
  [self setBlendingMode:[coder decodeIntForKey:@"CTGradientBlendingMode"]];
  unsigned count = [coder decodeIntForKey:@"CTGradientElementCount"];
  
  while(count != 0)
	{
    CTGradientElement newElement;
	
	[coder decodeValueOfObjCType:@encode(float) at:&(newElement.red)];
	[coder decodeValueOfObjCType:@encode(float) at:&(newElement.green)];
	[coder decodeValueOfObjCType:@encode(float) at:&(newElement.blue)];
	[coder decodeValueOfObjCType:@encode(float) at:&(newElement.alpha)];
	[coder decodeValueOfObjCType:@encode(float) at:&(newElement.position)];
	
	count--;
	[self addElement:&newElement];
	}
  return self;
  }
#pragma mark -



#pragma mark Creation
+ (id)gradientWithBeginningColor:(NSColor *)begin endingColor:(NSColor *)end
  {
  id newInstance = [[[self class] alloc] init];
  
  CTGradientElement color1;
  CTGradientElement color2;
  
  [[begin colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&color1.red
															   green:&color1.green
																blue:&color1.blue
															   alpha:&color1.alpha];
  
  [[end   colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&color2.red
															   green:&color2.green
																blue:&color2.blue
															   alpha:&color2.alpha];  
  color1.position = 0;
  color2.position = 1;
  
  [newInstance addElement:&color1];
  [newInstance addElement:&color2];
  
  return [newInstance autorelease];
  }

+ (id)aquaNormalGradient
  {
  id newInstance = [[[self class] alloc] init];
  
  CTGradientElement color1;
  color1.red = color1.green = color1.blue  = 0.95;
  color1.alpha = 1.00;
  color1.position = 0;
  
  CTGradientElement color2;
  color2.red = color2.green = color2.blue  = 0.83;
  color2.alpha = 1.00;
  color2.position = 11.5/23;
  
  CTGradientElement color3;
  color3.red = color3.green = color3.blue  = 0.95;
  color3.alpha = 1.00;
  color3.position = 11.5/23;
  
  CTGradientElement color4;
  color4.red = color4.green = color4.blue  = 0.92;
  color4.alpha = 1.00;
  color4.position = 1;
  
  [newInstance addElement:&color1];
  [newInstance addElement:&color2];
  [newInstance addElement:&color3];
  [newInstance addElement:&color4];
  
  return [newInstance autorelease];
  }

- (void)fillRect:(NSRect)rect angle:(float)angle
  {
  //First Calculate where the beginning and ending points should be
  CGPoint startPoint;
  CGPoint endPoint;
  
  if(angle == 0)		//screw the calculations - we know the answer
  	{
  	startPoint = CGPointMake(NSMinX(rect), NSMinY(rect));	//right of rect
  	endPoint   = CGPointMake(NSMaxX(rect), NSMinY(rect));	//left  of rect
  	}
  else if(angle == 90)	//same as above
  	{
  	startPoint = CGPointMake(NSMinX(rect), NSMinY(rect));	//bottom of rect
  	endPoint   = CGPointMake(NSMinX(rect), NSMaxY(rect));	//top    of rect
  	}
  else						//ok, we'll do the calculations now 
  	{
  	float x,y;
  	float sina, cosa, tana;
  	
  	float length;
  	float deltax,
  		  deltay;
	
  	float rangle = angle * pi/180;	//convert the angle to radians
	
  	if(fabsf(tan(rangle))<=1)	//for range [-45,45], [135,225]
		{
		x = NSWidth(rect);
		y = NSHeight(rect);
		
		sina = sin(rangle);
		cosa = cos(rangle);
		tana = tan(rangle);
		
		length = x/fabsf(cosa)+(y-x*fabsf(tana))*fabsf(sina);
		
		deltax = length*cosa/2;
		deltay = length*sina/2;
		}
	else						//for range [45,135], [225,315]
		{
		x = NSHeight(rect);
		y = NSWidth(rect);
		
		sina = sin(rangle - 90*pi/180);
		cosa = cos(rangle - 90*pi/180);
		tana = tan(rangle - 90*pi/180);
		
		length = x/fabsf(cosa)+(y-x*fabsf(tana))*fabsf(sina);
		
		deltax =-length*sina/2;
		deltay = length*cosa/2;
		}
  
	startPoint = CGPointMake(NSMidX(rect)-deltax, NSMidY(rect)-deltay);
	endPoint   = CGPointMake(NSMidX(rect)+deltax, NSMidY(rect)+deltay);
	}
  
  //Calls to CoreGraphics
  CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
  CGContextSaveGState(currentContext);
	  #if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_4
		CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	  #else
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	  #endif
	  CGShadingRef myCGShading = CGShadingCreateAxial(colorspace, startPoint, endPoint, gradientFunction, false, false);
	  
	  CGContextClipToRect (currentContext, *(CGRect *)&rect);	//This is where the action happens
	  CGContextDrawShading(currentContext, myCGShading);
	  
	  CGShadingRelease(myCGShading);
	  CGColorSpaceRelease(colorspace );
  CGContextRestoreGState(currentContext);
  }
@end

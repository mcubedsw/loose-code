/*****************************************************************
 M3DigitalClockView.m
 M3Extensions
 
 Created by Martin Pilkington on 22/09/2009.
 
 Copyright (c) 2006-2010 M Cubed Software
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 *****************************************************************/

#import "M3DigitalClockView.h"
#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+M3Extensions.h"

static NSGradient *backGradient;
static NSGradient *glossGradient;
static NSShadow *insetShadow;


@interface M3DigitalClockView ()

- (NSBezierPath *)bezierPathInRect:(NSRect)rect forInteger:(NSUInteger)integer;
- (void)drawDividerInRect:(NSRect)rect size:(CGFloat)size;

@end




@implementation M3DigitalClockView

@synthesize time;

/**
 Set up gradients
 */
+ (void)initialize {
	backGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.108 green:0.142 blue:0.228 alpha:1.000], 0.0,
					[NSColor colorWithCalibratedRed:0.004 green:0.031 blue:0.097 alpha:1.000], 0.5,
					[NSColor colorWithCalibratedRed:0.076 green:0.110 blue:0.208 alpha:1.000], 1.0, nil];
	glossGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:1.0 alpha:0.1], 0.49,
					 [NSColor clearColor], 0.5, nil];
	insetShadow = [[NSShadow m3_shadowWithColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] offset:NSMakeSize(0, -1) blurRadius:0] retain];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        time = 0;
	}
	return self;
}

/**
 Update the time
 */
- (void)setTime:(NSTimeInterval)newTime {
	time = newTime;
	[self setNeedsDisplay:YES];
	NSAccessibilityPostNotification(self, NSAccessibilityValueChangedNotification);
}

/**
 Start counting once per second
 */
- (IBAction)start:(id)sender {
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increment:) userInfo:nil repeats:YES];
}

/**
 Update the time
 */
- (void)increment:(NSTimer *)timer {
	time++;
	[self setNeedsDisplay:YES];
	NSAccessibilityPostNotification(self, NSAccessibilityValueChangedNotification);
}

/**
 Stop timing
 */
- (IBAction)stop:(id)sender {
	[timer invalidate];
	timer = nil;
}

/**
 Go back to 0
 */
- (IBAction)reset:(id)sender {
	time = 0;
	[self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark Drawing

/**
 Calculate each digit from the time interval
 */
- (NSArray *)digitsArray {
	hourTime = ((int)time/3600);
	NSInteger dig2 = hourTime % 10;
	NSInteger dig1 = ((hourTime % 100) - dig2)/10;
	
	minutesTime = (((int)time - hourTime * 3600)/60);
	NSInteger dig4 = minutesTime % 10;
	NSInteger dig3 = ((minutesTime % 100) - dig4)/10;
	
	secondsTime = (int)time - (minutesTime * 60) - (hourTime * 3600);
	NSInteger dig6 = secondsTime % 10;
	NSInteger dig5 = (secondsTime - dig6)/10;
	
	return [NSArray arrayWithObjects:[NSNumber numberWithInteger:dig1], [NSNumber numberWithInteger:dig2], 
			[NSNumber numberWithInteger:dig3], [NSNumber numberWithInteger:dig4], 
			[NSNumber numberWithInteger:dig5], [NSNumber numberWithInteger:dig6], nil];
}

/**
 Draw the clock
 */
- (void)drawRect:(NSRect)dirtyRect {
	//Draw the black border with the inner shadow
	dirtyRect = NSInsetRect([self bounds], 1, 1);
	if (dirtyRect.size.width > 0 && dirtyRect.size.height > 0) {
		[[NSColor blackColor] set];
		[insetShadow set];
		[[NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:5 yRadius:5] fill];
	}
	
	//Draw the background gradient
	dirtyRect = NSInsetRect(dirtyRect, 1, 1);
	if (dirtyRect.size.width > 0 && dirtyRect.size.height > 0) {
		NSBezierPath *clockShapePath = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:5 yRadius:5];
		[backGradient drawInBezierPath:clockShapePath angle:-90];
		

		
		
		//Draw digits
		[[NSColor colorWithCalibratedRed:0.078 green:0.645 blue:1.000 alpha:1.000] set];
		
		[[NSShadow m3_shadowWithColor:[NSColor colorWithCalibratedRed:0.078 green:0.645 blue:1.000 alpha:0.7] 
								 offset:NSZeroSize
							 blurRadius:7.0] set];
		
		CGFloat digitHeight = dirtyRect.size.height * 0.6;
		CGFloat digitWidth = digitHeight / 1.75;
		CGFloat totalWidth = (digitWidth * 11.5);
		CGFloat padding = (dirtyRect.size.width - totalWidth) / 2;
		
		
		if (padding < 10) {
			padding = 10;
		}
		
		NSRect rect = NSMakeRect(padding, dirtyRect.size.height * 0.2, digitWidth, digitHeight);
		
		
		
		NSArray *digits = [self digitsArray];
		for (NSInteger i = 0; i < 6; i++) {
			NSBezierPath *path = [self bezierPathInRect:rect forInteger:[[digits objectAtIndex:i] integerValue]];
			[path setLineWidth:digitWidth/4];
			[path stroke];
			rect.origin.x += digitWidth * 1.5;
			if (i == 1 || i == 3) {
				[self drawDividerInRect:rect size:digitWidth/4];
				rect.origin.x += digitWidth * 1.5;
			}
		}
			
		//Draw the gloss
		[glossGradient drawInBezierPath:clockShapePath angle:-90];
		
		//Add the inner stroke
		NSShadow *shadow = [NSShadow m3_shadowWithColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.85] offset:NSZeroSize blurRadius:1.0];
		[clockShapePath fillWithInnerShadow:shadow];
	}
	
}

/**
 Get the bezier path for the supplied digit
 */
- (NSBezierPath *)bezierPathInRect:(NSRect)rect forInteger:(NSUInteger)integer {
	NSBezierPath *path = nil;
	NSPoint topLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
	NSPoint topRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
	NSPoint bottomLeft = NSMakePoint(NSMinX(rect), NSMinY(rect));
	NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));
	NSPoint middleLeft = NSMakePoint(NSMinX(rect), NSMidY(rect));
	NSPoint middleRight = NSMakePoint(NSMaxX(rect), NSMidY(rect));
	
	if (integer == 0) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:topLeft];
		[path lineToPoint:bottomLeft];
		[path lineToPoint:bottomRight];
		[path lineToPoint:topRight];
		[path lineToPoint:topLeft];
	} else if (integer == 1) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:bottomRight];
		[path lineToPoint:topRight];
	} else if (integer == 2) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:topLeft];
		[path lineToPoint:topRight];
		[path lineToPoint:middleRight];
		[path lineToPoint:middleLeft];
		[path lineToPoint:bottomLeft];
		[path lineToPoint:bottomRight];
	} else if (integer == 3) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:topLeft];
		[path lineToPoint:topRight];
		[path lineToPoint:bottomRight];
		[path lineToPoint:bottomLeft];
		[path moveToPoint:middleLeft];
		[path lineToPoint:middleRight];
	} else if (integer == 4) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:topLeft];
		[path lineToPoint:middleLeft];
		[path lineToPoint:middleRight];
		[path lineToPoint:topRight];
		[path lineToPoint:bottomRight];
	} else if (integer == 5) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:topRight];
		[path lineToPoint:topLeft];
		[path lineToPoint:middleLeft];
		[path lineToPoint:middleRight];
		[path lineToPoint:bottomRight];
		[path lineToPoint:bottomLeft];
	} else if (integer == 6) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:topLeft];
		[path lineToPoint:bottomLeft];
		[path lineToPoint:bottomRight];
		[path lineToPoint:middleRight];
		[path lineToPoint:middleLeft];
	} else if (integer == 7) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:bottomRight];
		[path lineToPoint:topRight];
		[path lineToPoint:topLeft];
	} else if (integer == 8) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:topLeft];
		[path lineToPoint:bottomLeft];
		[path lineToPoint:bottomRight];
		[path lineToPoint:topRight];
		[path lineToPoint:topLeft];
		[path moveToPoint:middleLeft];
		[path lineToPoint:middleRight];
	} else if (integer == 9) {
		path = [NSBezierPath bezierPath];
		[path moveToPoint:bottomRight];
		[path lineToPoint:topRight];
		[path lineToPoint:topLeft];
		[path lineToPoint:middleLeft];
		[path lineToPoint:middleRight];
	}
	[path setLineCapStyle:NSRoundLineCapStyle];
	[path setLineJoinStyle:NSRoundLineJoinStyle];
	return path;
}

/**
 Draw the time unit divider
 */
- (void)drawDividerInRect:(NSRect)rect size:(CGFloat)size {
	NSRect topRect = NSMakeRect(NSMidX(rect)-(size/2), NSMidY(rect)+(size/2), size, size);
	[[NSBezierPath bezierPathWithRoundedRect:topRect xRadius:2 yRadius:2] fill];
	
	NSRect bottomRect = NSMakeRect(NSMidX(rect)-(size/2), NSMidY(rect)-(size*1.5), size, size);
	[[NSBezierPath bezierPathWithRoundedRect:bottomRect xRadius:2 yRadius:2] fill];
}


#pragma mark -
#pragma mark Accessibility

- (BOOL)accessibilityIsIgnored {
	return NO;
}

- (NSArray *)accessibilityAttributeNames {
    static NSArray *attributes = nil;
    if (attributes == nil) {
        attributes = [[super accessibilityAttributeNames] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:NSAccessibilityDescriptionAttribute, NSAccessibilityValueAttribute, nil]];
    }
    return attributes;
}


- (id)accessibilityAttributeValue:(NSString *)attribute {
	if ([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
		return NSAccessibilityStaticTextRole;
	} else if ([attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
		return NSLocalizedString(@"timer", @"Accessibility role description for digital clock in recording panel");
	} else if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute]) {
		return NSLocalizedString(@"recording", @"Accessibility description for digital clock in recording panel");
	} else if ([attribute isEqualToString:NSAccessibilityValueAttribute]) {
		[self digitsArray];
		if (hourTime > 0) {
			return [NSString stringWithFormat:NSLocalizedString(@"%d hours, %d minutes, %d seconds", @"Accessibility value format for digital clock in recording panel"), hourTime, minutesTime, secondsTime];
		} else if (minutesTime > 0) {
			return [NSString stringWithFormat:NSLocalizedString(@"%d minutes, %d seconds", @"Accessibility value format for digital clock in recording panel"), minutesTime, secondsTime];
		} else {
			return [NSString stringWithFormat:NSLocalizedString(@"%d seconds", @"Accessibility value format for digital clock in recording panel"), secondsTime];
		}
	}
	return [super accessibilityAttributeValue:attribute];
}

- (BOOL)accessibilityIsAttributeSettable:(NSString *)attribute {
	if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute]) {
		return NO;
	} else if ([attribute isEqualToString:NSAccessibilityValueAttribute]) {
		return NO;
	}
	return [super accessibilityIsAttributeSettable:attribute];
}


@end

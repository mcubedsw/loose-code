/*****************************************************************
 M3AudioLevelBar.m
 M3Extensions
 
 Created by Martin Pilkington on 23/09/2009.
 
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

#import "M3AudioLevelBar.h"
#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+M3Extensions.h"
#import "NSBezierPath+M3Extensions.h"

@implementation M3AudioLevelBar

- (BOOL)acceptsFirstResponder {
	return NO;
}

/**
 Draw the level indicator
 */
- (void)drawLevelInPath:(NSBezierPath *)path {
	NSRect innerRect = [path bounds];
	
	NSRect light = NSMakeRect(innerRect.origin.x + 5, innerRect.origin.y + 2, 6, 2);
	CGFloat widthLeft = innerRect.size.width;
	//For each row
	while (widthLeft > light.size.width) {
		//Set the colour and glow for the level
		if (light.origin.x < innerRect.size.width * level) {
			if (!useGreyscale) {
				if (light.origin.x > innerRect.size.width * 0.9) {
					[[NSColor colorWithCalibratedRed:0.910 green:0.253 blue:0.194 alpha:1.000] set];
					[[NSShadow m3_shadowWithColor:[NSColor redColor] offset:NSZeroSize blurRadius:2.0] set];
				} else if (light.origin.x > innerRect.size.width * 0.7) {
					[[NSColor yellowColor] set];
					[[NSShadow m3_shadowWithColor:[NSColor yellowColor] offset:NSZeroSize blurRadius:2.0] set];
				} else {
					[[NSColor colorWithCalibratedRed:0.254 green:0.910 blue:0.341 alpha:1.000] set];
					[[NSShadow m3_shadowWithColor:[NSColor greenColor] offset:NSZeroSize blurRadius:2.0] set];
				}
			} else {
				if (light.origin.x > innerRect.size.width * 0.9) {
					[[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
				} else if (light.origin.x > innerRect.size.width * 0.7) {
					[[NSColor colorWithCalibratedWhite:1.0 alpha:0.6] set];
				} else {
					[[NSColor colorWithCalibratedWhite:1.0 alpha:0.4] set];
				}
			}
		} else {
			[[NSColor colorWithCalibratedWhite:1.0 alpha:0.15] set];
			[[NSShadow m3_shadowWithColor:[NSColor clearColor] offset:NSZeroSize blurRadius:0] set];
		}
		
		//Draw the current column
		light.origin.y = innerRect.origin.y + 2;
		CGFloat heightLeft = innerRect.size.height;
		while (heightLeft > light.size.height) {
			if ([path m3_containsRect:light]) {
				[NSBezierPath fillRect:light];
			} else {				
				NSRect halfLight = light;
				halfLight.size.width /= (3/2.0);
				if (light.origin.x < NSMidX(innerRect)) {
					halfLight.origin.x += light.size.width - halfLight.size.width;
				}
				if ([path m3_containsRect:halfLight]) {
					[NSBezierPath fillRect:halfLight];
				}
			}
			light.origin.y += light.size.height + 2;
			heightLeft -= light.size.height +2;
		}
		light.origin.x += light.size.width + 4;
		widthLeft -= light.size.width + 4;
	}
}

/**
 Handle the switch between greyscale mode
 */
- (void)mouseUp:(NSEvent *)theEvent {
	useGreyscale = !useGreyscale;
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
	//Cancel out the super class
}

- (void)mouseDragged:(NSEvent *)theEvent {
	//Cancel out the super class
}

- (void)keyDown:(NSEvent *)theEvent {
	//Cancel out the super class;
}

@end

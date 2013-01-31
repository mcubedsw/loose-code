/*****************************************************************
 M3PittedRubberView.m
 M3Extensions
 
 Created by Martin Pilkington on 16/10/2009.
 
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

#import "M3PittedRubberView.h"

#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+M3Extensions.h"

static NSColor *backColour;
static NSColor *circleColour;
static NSShadow *innerShadow;
static NSShadow *dropShadow;

@implementation M3PittedRubberView

+ (void)initialize {
	backColour = [[NSColor colorWithCalibratedRed:0.109 green:0.112 blue:0.115 alpha:1.000] retain];
	circleColour = [[NSColor colorWithCalibratedRed:0.100 green:0.103 blue:0.103 alpha:1.000] retain];
	innerShadow = [[NSShadow m3_shadowWithColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] offset:NSMakeSize(0, -1) blurRadius:0] retain];
	dropShadow = [[NSShadow m3_shadowWithColor:[NSColor colorWithCalibratedWhite:0.7 alpha:0.1] offset:NSMakeSize(0, -1) blurRadius:0] retain];
}

- (void)drawRect:(NSRect)dirtyRect {
    [backColour set];
	[NSBezierPath fillRect:[self bounds]];
	[self drawDots];
}

- (void)drawDots {
	if ([self bounds].size.height > [dots size].height || [self bounds].size.width > [dots size].width) {
		dots = nil;
	}
	
	NSInteger imageSize = 96;
	
	if (!dots) {
		dots = [[NSImage alloc] initWithSize:NSMakeSize(imageSize, imageSize)];
		[dots lockFocus];
		NSBezierPath *path = [NSBezierPath bezierPath];
		[circleColour set];
		[dropShadow set];
		NSInteger currentY = 1;
		while (currentY < [dots size].height) {
			NSInteger currentX = (currentY - 1) % 12 == 0 ? 0 : 6;
			while (currentX < [dots size].width) {
				[path appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(currentX, currentY, 4, 4)]];
				currentX += 12;
			}
			currentY += 6;
		}
		[path fill];
		[path fillWithInnerShadow:innerShadow];
		[dots unlockFocus];
	}
	
	NSInteger currentY = 0;
	while (currentY < [self bounds].size.height) {
		NSInteger currentX = 0;
		while (currentX < [self bounds].size.width) {
			[dots drawInRect:NSMakeRect(currentX, currentY, imageSize, imageSize) fromRect:NSMakeRect(0, 0, imageSize, imageSize) operation:NSCompositeSourceOver fraction:1];
			currentX += imageSize;
		}
		currentY += imageSize;
	}
}

@end

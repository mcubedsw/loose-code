/*****************************************************************
 M3SegmentedTabsCell.m
 M3Extensions
 
 Created by Martin Pilkington on 30/07/2009.
 
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

#import "M3SegmentedTabsCell.h"


@implementation M3SegmentedTabsCell

/**
 Generates the rect in which to draw each segment
 */
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	CGFloat currentX = 3;
	for (NSInteger i = 0; i < [self segmentCount]; i++) {
		CGFloat segmentWidth = [self widthForSegment:i];
		CGFloat height = cellFrame.size.height;
		CGFloat y = 0;
		CGFloat x = currentX;
		[self drawSegment:i inFrame:NSMakeRect(x, y, segmentWidth, height) withView:controlView];
		currentX += segmentWidth + 1;
	}
}

/**
 Draws each segment
 */
- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
	frame.size.width -= 3;
	frame.origin.x += 1;
	
	NSColor *topColor = nil;
	NSColor *bottomColor = nil;
	NSColor *textColor = nil;
	NSColor *shadowColor = nil;
	NSSize shadowOffset = NSZeroSize;
	CGFloat heightChange = 1;
	
	//Handle colours
	if ([self selectedSegment] == segment) {
		topColor = [NSColor colorWithCalibratedRed:0.826 green:0.839 blue:0.860 alpha:1.000];
		bottomColor = [NSColor colorWithCalibratedRed:0.744 green:0.770 blue:0.794 alpha:1.000];
		textColor = [NSColor blackColor];
		shadowColor = [NSColor whiteColor];
		shadowOffset = NSMakeSize(0, -1);
	} else {
		topColor = [NSColor colorWithCalibratedRed:0.363 green:0.385 blue:0.409 alpha:1.000];
		bottomColor = [NSColor colorWithCalibratedRed:0.316 green:0.342 blue:0.366 alpha:1.000];
		textColor = [NSColor whiteColor];
		shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.7];
		shadowOffset = NSMakeSize(0, 1);
		heightChange = 2;
	}
	
	//Creates the tab path
	NSBezierPath *path = [NSBezierPath bezierPath];
	CGFloat left = frame.origin.x;
	CGFloat right = frame.origin.x + frame.size.width;
	
	
	[path moveToPoint:NSMakePoint(left, frame.size.height-heightChange)];
	[path lineToPoint:NSMakePoint(left, 8)];
	[path curveToPoint:NSMakePoint(left+8, 0) controlPoint1:NSMakePoint(left, 3) controlPoint2:NSMakePoint(left+3, 0)];
	[path lineToPoint:NSMakePoint(right-8, 0)];
	[path curveToPoint:NSMakePoint(right, 8) controlPoint1:NSMakePoint(right-3, 0) controlPoint2:NSMakePoint(right, 3)];
	[path lineToPoint:NSMakePoint(right, frame.size.height-heightChange)];
	
	//Draws the gradient in the path
	NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:topColor, 0.0, bottomColor, 0.3, nil];
	[gradient drawInBezierPath:path angle:90.0];
	[gradient release];
	
	//Attributes
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	[attributes setObject:[NSFont systemFontOfSize:12.0] forKey:NSFontAttributeName];
	
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setAlignment:NSCenterTextAlignment];
	[attributes setObject:style forKey:NSParagraphStyleAttributeName];
	[style release];
	
	[attributes setObject:textColor forKey:NSForegroundColorAttributeName];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:shadowColor];
	[shadow setShadowOffset:shadowOffset];
	[attributes setObject:shadow forKey:NSShadowAttributeName];
	[shadow release];
	
	//Works out the rect to draw the label in and draws it
	NSRect rect = [[self labelForSegment:segment] boundingRectWithSize:frame.size options:0 attributes:attributes];
	
	frame.origin.y = (frame.size.height / 2) - (rect.size.height / 2);
	[[self labelForSegment:segment] drawInRect:frame withAttributes:attributes];
}

@end

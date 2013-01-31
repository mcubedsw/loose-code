/*****************************************************************
 M3GlossyBar.m
 M3Extensions
 
 Created by Martin Pilkington on 24/09/2009.
 
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

#import "M3GlossyBar.h"

#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+M3Extensions.h"
#import "M3GlossyBarDelegate.h"

static NSGradient *mainGradient;
static NSGradient *glossGradient;
static NSShadow *innerShadow;
static NSShadow *insetShadow;

@implementation M3GlossyBar

@synthesize level;
@synthesize delegate;

/**
 Set up gradients and shadows
 */
+ (void)initialize {
	mainGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.208 green:0.212 blue:0.222 alpha:1.000]
												 endingColor:[NSColor colorWithCalibratedRed:0.065 green:0.074 blue:0.082 alpha:1.000]];
	glossGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:1.0 alpha:0.1], 0.49,
					 [NSColor clearColor], 0.5, nil];
	insetShadow = [[NSShadow m3_shadowWithColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] offset:NSMakeSize(0, -1) blurRadius:0] retain];
	innerShadow = [[NSShadow m3_shadowWithColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] offset:NSMakeSize(0, -2) blurRadius:2] retain];
}


- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        level = 0.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		level = [aDecoder decodeFloatForKey:@"glossyBarLevel"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeFloat:level forKey:@"glossyBarLevel"];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

/**
 Set the level and refresh
 */
- (void)setLevel:(CGFloat)newLevel {
	level = newLevel;
	[self setNeedsDisplay:YES];
}

/**
 Draw the glossy bar
 */
- (void)drawRect:(NSRect)dirtyRect {
	NSRect drawingRect = NSInsetRect([self bounds], 1, 1);
	if (drawingRect.size.width > 0 && drawingRect.size.height > 0) {
		//Draw background and shadow
		NSBezierPath *outlinePath = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:drawingRect.size.height/2 yRadius:drawingRect.size.height/2];
		
		if ([[self window] firstResponder] == self) {
			[NSGraphicsContext saveGraphicsState];
			NSSetFocusRingStyle(NSFocusRingOnly);
			[outlinePath fill];
			[NSGraphicsContext restoreGraphicsState];
		}
		
		[insetShadow set];
		[[NSColor blackColor] set];
		[outlinePath fill];
		
		//Draw the background gradient
		NSRect innerRect = NSInsetRect(drawingRect, 1, 1);
		NSBezierPath *innerPath = [NSBezierPath bezierPathWithRoundedRect:innerRect xRadius:innerRect.size.height/2 yRadius:innerRect.size.height/2];
		[mainGradient drawInBezierPath:innerPath angle:-90];
		
		//Draw level
		[self drawLevelInPath:innerPath];
			
		//Draw the gloss and inner shadow
		[glossGradient drawInBezierPath:innerPath angle:-90];
		[innerPath fillWithInnerShadow:innerShadow];
	}
}

/**
 Draw the progress
 */
- (void)drawLevelInPath:(NSBezierPath *)path {
	CGFloat lowerLevel = level-0.001;
	if (lowerLevel < 0) {
		lowerLevel = 0;
	}
	
	if (level != lowerLevel) {
		NSGradient *fillGrad = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.169 green:0.324 blue:0.765 alpha:1.000], lowerLevel,
								[NSColor clearColor], level, nil];
		[fillGrad drawInBezierPath:path angle:0];
		[fillGrad release];
	}
}

#pragma mark -
#pragma mark Mouse Events

/**
 Handle clicks and drags to update the level
 */
- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSSize frameSize = [self frame].size;
	[self setLevel:location.x / frameSize.width];
	
	if ([[self delegate] respondsToSelector:@selector(glossyBarDidUpdateLevel:)]) {
		[[self delegate] glossyBarDidUpdateLevel:self];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSSize frameSize = [self frame].size;
	CGFloat newLevel = location.x / frameSize.width;
	if (newLevel < 0) {
		newLevel = 0;
	} else if (newLevel > 1) {
		newLevel = 1;
	}
	[self setLevel:newLevel];
	
	if ([[self delegate] respondsToSelector:@selector(glossyBarDidUpdateLevel:)]) {
		[[self delegate] glossyBarDidUpdateLevel:self];
	}
}

- (void)keyDown:(NSEvent *)theEvent {
	if (([theEvent keyCode] == 123 || [theEvent keyCode] == 124)) {
		if ([theEvent modifierFlags] & NSAlternateKeyMask) {
			[self setLevel:[theEvent keyCode] == 123 ? 0 : 1];
		} else {
			[self setLevel:[self level] + ([theEvent keyCode] == 123 ? -0.01 : 0.01)];
		}
		if ([[self delegate] respondsToSelector:@selector(glossyBarDidUpdateLevel:)]) {
			[[self delegate] glossyBarDidUpdateLevel:self];
		}
	} else {
		[super keyDown:theEvent];
	}
}


#pragma mark -
#pragma mark Accessibility

- (BOOL)accessibilityIsIgnored {
	return NO;
}

- (NSArray *)accessibilityAttributeNames {
    static NSArray *attributes = nil;
    if (attributes == nil) {
        attributes = [[super accessibilityAttributeNames] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:NSAccessibilityValueAttribute, nil]];
    }
    return attributes;
}


- (id)accessibilityAttributeValue:(NSString *)attribute {
	if ([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
		return NSAccessibilitySliderRole;
	} else if ([attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
		return NSAccessibilityRoleDescription(NSAccessibilityProgressIndicatorRole, nil);
	} else if ([attribute isEqualToString:NSAccessibilityValueAttribute]) {
		return [NSString stringWithFormat:@"%ld %%", (NSInteger)([self level] * 100)];
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

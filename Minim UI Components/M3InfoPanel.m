/*****************************************************************
 M3InfoPanel.m
 M3Extensions
 
 Created by Martin Pilkington on 16/01/2010.
 
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

#import "M3InfoPanel.h"

#import "M3InfoPanelViewController.h"
#import "M3InfoPanelDelegate.h"
#import "M3SegmentedTabsCell.h"
#import <QuartzCore/CoreAnimation.h>




@interface M3InfoPanel ()

- (void)setDefaults;
- (NSSegmentedControl *)tabControl;
- (NSButton *)closeButton;
- (NSView *)panelContainer;
- (void)updateTabControl;

- (NSButton *)previousButton;
- (NSButton *)nextButton;

- (void)updateAfterAddingPanel:(M3InfoPanelViewController *)aPanel;

@end



@implementation M3InfoPanel

@synthesize delegate;
@synthesize representedObject;
@synthesize displaysNavigationButtons;
@synthesize displaysCloseButton;
@synthesize hasPreviousObject;
@synthesize hasNextObject;

#pragma mark -
#pragma mark Setup

/**
 Initialise
 */
- (id)initWithFrame:(NSRect)rect {
	if ((self = [super initWithFrame:rect])) {
		[self setDefaults];
		displaysCloseButton = YES;
		displaysNavigationButtons = YES;
		panels = [[NSMutableArray alloc] init];
		
		[self addSubview:[self tabControl]];
		[self addSubview:[self closeButton]];
		[self addSubview:[self previousButton]];
		[self addSubview:[self nextButton]];
		
		[self addSubview:[self panelContainer]];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self setDefaults];
		displaysCloseButton = [aDecoder decodeBoolForKey:@"displaysCloseButton"];
		displaysNavigationButtons = [aDecoder decodeBoolForKey:@"displaysNavigationButtons"];
		panels = [[aDecoder decodeObjectForKey:@"panels"] mutableCopy];
		
		tabControl = [[aDecoder decodeObjectForKey:@"tabControl"] retain];
		closeButton = [[aDecoder decodeObjectForKey:@"closeButton"] retain];
		previousButton = [[aDecoder decodeObjectForKey:@"previousButton"] retain];
		nextButton = [[aDecoder decodeObjectForKey:@"nextButton"] retain];
		
		panelContainer = [[aDecoder decodeObjectForKey:@"panelContainer"] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
	[super encodeWithCoder:anEncoder];
	[anEncoder encodeBool:displaysCloseButton forKey:@"displaysCloseButton"];
	[anEncoder encodeBool:displaysNavigationButtons forKey:@"displaysNavigationButtons"];
	[anEncoder encodeObject:panels forKey:@"panels"];
	
	[anEncoder encodeObject:tabControl forKey:@"tabControl"];
	[anEncoder encodeObject:closeButton forKey:@"closeButton"];
	[anEncoder encodeObject:previousButton forKey:@"previousButton"];
	[anEncoder encodeObject:nextButton forKey:@"nextButton"];
	
	[anEncoder encodeObject:panelContainer forKey:@"panelContainer"];
}

- (void)awakeFromNib {
	[self updateTabControl];
	[self refreshPanels];
}


- (void)setDefaults {
	hasPreviousObject = YES;
	hasNextObject = YES;
	selectedIndex = 0;
}


- (void)dealloc {
	[panels release];
	[tabControl release];
	[closeButton release];
	[previousButton release];
	[nextButton release];
	[panelContainer release];
	[super dealloc];
}




#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect {
	NSRect topRect = NSMakeRect(0, [self frame].size.height-27, [self frame].size.width, 27);
	NSRect buttonBarRect = NSMakeRect(0, [self frame].size.height-54, [self frame].size.width, 27);
	
	NSGradient *topGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.097 green:0.104 blue:0.121 alpha:1.000]
															endingColor:[NSColor colorWithCalibratedRed:0.148 green:0.170 blue:0.189 alpha:1.000]];
	
	NSGradient *buttonBarGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.744 green:0.770 blue:0.794 alpha:1.000]
																  endingColor:[NSColor colorWithCalibratedRed:0.648 green:0.679 blue:0.702 alpha:1.000]];
	
	
	[topGradient drawInRect:topRect angle:-90];
	[buttonBarGradient drawInRect:buttonBarRect angle:-90];
	[[NSColor colorWithCalibratedRed:0.594 green:0.590 blue:0.594 alpha:1.000] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(buttonBarRect), NSMinY(buttonBarRect)-0.5) toPoint:NSMakePoint(NSMaxX(buttonBarRect), NSMinY(buttonBarRect)-0.5)];
	
	[topGradient release];
	[buttonBarGradient release];
}


#pragma mark -
#pragma mark Accessors

/**
 Shows/hides the nav buttons
 */
- (void)setDisplaysNavigationButtons:(BOOL)flag {
	displaysNavigationButtons = flag;
	[[self nextButton] setHidden:!displaysNavigationButtons];
	[[self previousButton] setHidden:!displaysNavigationButtons];
}

/**
 Shows/hides the close button
 */
- (void)setDisplaysCloseButton:(BOOL)flag {
	displaysCloseButton = flag;
	[[self closeButton] setHidden:!displaysCloseButton];
}

/**
 Enables/disables the next button
 */
- (void)setHasNextObject:(BOOL)flag {
	hasNextObject = flag;
	[[self nextButton] setEnabled:hasNextObject];
}

/**
 Enables/disables the prev button
 */
- (void)setHasPreviousObject:(BOOL)flag {
	hasPreviousObject = flag;
	[[self previousButton] setEnabled:hasPreviousObject];
}

/**
 Return the index of the selected subview
 */
- (NSInteger)selectedSubviewIndex {
	selectedIndex = [tabControl selectedSegment];
	return selectedIndex;
}


#pragma mark -
#pragma mark Controls

/**
 Sets up and returns the tab control
 */
- (NSSegmentedControl *)tabControl {
	if (!tabControl) {
		tabControl = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, [self bounds].size.height-28, 500, 25)];
		[tabControl setCell:[[[M3SegmentedTabsCell alloc] init] autorelease]];
		[tabControl setTarget:self];
		[tabControl setAction:@selector(switchPanel:)];
		[tabControl setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin | NSViewMaxXMargin];
	}
	[self updateTabControl];
	return tabControl;
}

/**
 Sets up and returns the close button
 */
- (NSButton *)closeButton {
	if (!closeButton) {
		closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX([self bounds])-23, NSMaxY([self bounds])-22, 18, 18)];
		[closeButton setBordered:NO];
		[closeButton setTitle:@""];
		
		
		NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.mcubedsw.M3AppKit"];
#ifdef M3APPKIT_IB_BUILD
		bundle = [NSBundle bundleWithIdentifier:@"com.mcubedsw.M3AppKitIB"];
#endif
		
		NSString *path = [bundle pathForResource:@"InfoClose" ofType:@"tif"];
		[closeButton setImage:[[[NSImage alloc] initWithContentsOfFile:path] autorelease]];
		[closeButton setButtonType:NSMomentaryChangeButton];
		[closeButton setTarget:self];
		[closeButton setAction:@selector(closePanel:)];
		[closeButton setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin];
	}
	return closeButton;
}

/**
 Sets up and returns the previous button
 */
- (NSButton *)previousButton {
	if (!previousButton) {
		previousButton = [[NSButton alloc] initWithFrame:NSMakeRect(5, NSMaxY([self bounds])-23, 25, 19)];
		[previousButton setBordered:NO];
		
		NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.mcubedsw.M3AppKit"];
#ifdef M3APPKIT_IB_BUILD
		bundle = [NSBundle bundleWithIdentifier:@"com.mcubedsw.M3AppKitIB"];
#endif
		
		NSString *path = [bundle pathForResource:@"InfoPrev" ofType:@"tif"];
		[previousButton setImage:[[[NSImage alloc] initWithContentsOfFile:path] autorelease]];
		[previousButton setButtonType:NSMomentaryChangeButton];
		[previousButton setTarget:self];
		[previousButton setAction:@selector(moveToPrev:)];
		[previousButton setAutoresizingMask:NSViewMinYMargin | NSViewMaxXMargin];
	}
	return previousButton;
}

/**
 Sets up and returns the next button
 */
- (NSButton *)nextButton {
	if (!nextButton) {
		nextButton = [[NSButton alloc] initWithFrame:NSMakeRect(30, NSMaxY([self bounds])-23, 25, 19)];
		[nextButton setBordered:NO];
		
		NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.mcubedsw.M3AppKit"];
#ifdef M3APPKIT_IB_BUILD
		bundle = [NSBundle bundleWithIdentifier:@"com.mcubedsw.M3AppKitIB"];
#endif
		
		NSString *path = [bundle pathForResource:@"InfoNext" ofType:@"tif"];
		[nextButton setImage:[[[NSImage alloc] initWithContentsOfFile:path] autorelease]];
		[nextButton setButtonType:NSMomentaryChangeButton];
		[nextButton setTarget:self];
		[nextButton setAction:@selector(moveToNext:)];
		[nextButton setAutoresizingMask:NSViewMinYMargin | NSViewMaxXMargin];
	}
	return nextButton;
}

/**
 Sets up and returns the panel container
 */
- (NSView *)panelContainer {
	if (!panelContainer) {
		NSRect bounds = [self bounds];
		bounds.size.height -= 27;
		panelContainer = [[NSView alloc] initWithFrame:bounds];
		[panelContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		
		//Set up moving animation
		CABasicAnimation *anim = [CABasicAnimation animation];
		[anim setDelegate:self];
		[anim setDuration:0.45];
		[anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[panelContainer setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frameOrigin"]];
	}
	return panelContainer;
}


#pragma mark -
#pragma mark UI Updating

/**
 Updates the tab control
 */
- (void)updateTabControl {
	[tabControl setSegmentCount:[panels count]];
	//Set the label of each segment and find what the tab width should be
	NSInteger tabWidth = 60;
	for (NSInteger i = 0; i < [tabControl segmentCount]; i++) {
		M3InfoPanelViewController *panel = [panels objectAtIndex:i];
		[tabControl setLabel:[panel title] forSegment:i];
		NSInteger newWidth = (7 * [[panel title] length]) + 10;
		if (newWidth > tabWidth)
			tabWidth = newWidth;
	}
	
	//Set the frame and centre, then update the tab width
	NSRect frame = [tabControl frame];
	frame.size.width = (tabWidth * [panels count]) + 10;
	frame.origin.x = ([self frame].size.width-frame.size.width)/2;
	[tabControl setFrame:frame];
	for (NSInteger i = 0; i < [tabControl segmentCount]; i++) {
		[tabControl setWidth:tabWidth forSegment:i];
	}
	
	//Make sure the selection is correct
	if ([tabControl segmentCount] > selectedIndex) {
		[tabControl setSelectedSegment:selectedIndex];
	}
}

/**
 Shows all the views
 */
- (void)showAll {
	for (id panel in panels) {
		[[panel view] setHidden:NO];
		[[panel buttonBarView] setHidden:NO];
	}
}

/**
 Hides all views not visible on screen, so voice over doesn't see them
 */
- (void)hideAllHidden {
	if ([panels count] > selectedIndex) {
		id selected = [panels objectAtIndex:selectedIndex];
		for (id panel in panels) {
			if (panel != selected) {
				[[panel view] setHidden:YES];
				[[panel buttonBarView] setHidden:YES];
			}
		}
	}
}

/**
 Refresh the panel frames and contents
 */
- (void)refreshPanels {
	//Position the container frame to display the current panel
	NSRect containerFrame = [panelContainer frame];
	containerFrame.size.width = [self frame].size.width * [panels count];
	containerFrame.origin.x = -([self frame].size.width * selectedIndex);
	containerFrame.size.height = [self frame].size.height - 27;
	[panelContainer setFrame:containerFrame];
	
	//Updates the subviews
	NSInteger index = 0;
	for (M3InfoPanelViewController *panel in panels) {
		if (index == selectedIndex) {
			[closeButton setNextKeyView:[panel firstView]];
		}
		NSRect subFrame = NSMakeRect([self frame].size.width*index, 0, [self frame].size.width, containerFrame.size.height - 27);
		[[panel view] setFrame:subFrame];
		
		NSRect barFrame = NSMakeRect(subFrame.origin.x, NSMaxY(containerFrame)-27, subFrame.size.width, 27);
		[[panel buttonBarView] setFrame:barFrame];
		if (![[panel view] superview]) {
			[panelContainer addSubview:[panel view]];
		}
		if (![[panel buttonBarView] superview]) {
			[panelContainer addSubview:[panel buttonBarView]];
		}
		index++;
	}
	[panels makeObjectsPerformSelector:@selector(reloadPanel)];
	[self hideAllHidden];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isKindOfClass:[M3InfoPanelViewController class]]) {
		if ([keyPath isEqualToString:@"title"]) {
			[self updateTabControl];
		} else if ([keyPath isEqualToString:@"view"]) {
			[self refreshPanels];
		}
	} 
}

#pragma mark -
#pragma mark Panel Management

- (NSArray *)panels {
	return [[panels copy] autorelease];
}

/**
 Add a panel and update the UI
 */
- (void)addPanel:(M3InfoPanelViewController *)panel {
	[self insertPanel:panel atIndex:[panels count]];
}

- (void)insertPanel:(M3InfoPanelViewController *)aPanel atIndex:(NSUInteger)aIndex {
	if ([aPanel isKindOfClass:[M3InfoPanelViewController class]]) {
		if (aIndex <= [panels count]) {
			[panels insertObject:aPanel atIndex:aIndex];
			[self updateAfterAddingPanel:aPanel];
		}
	}
}

- (void)replacePanelAtIndex:(NSUInteger)aIndex withPanel:(M3InfoPanelViewController *)aPanel {
	if ([aPanel isKindOfClass:[M3InfoPanelViewController class]]) {
		if (aIndex < [panels count]) {
			[panels replaceObjectAtIndex:aIndex withObject:aPanel];
			[self updateAfterAddingPanel:aPanel];
		}
	}
}

- (void)updateAfterAddingPanel:(M3InfoPanelViewController *)aPanel {
	[aPanel setParent:self];
	[aPanel addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
	[aPanel addObserver:self forKeyPath:@"view" options:NSKeyValueObservingOptionOld context:nil];
	[self updateTabControl];
	[self refreshPanels];
}

/**
 Remove a panel and update the UI
 */
- (void)removePanelAtIndex:(NSUInteger)aIndex {
	if (aIndex < [panels count]) {
		M3InfoPanelViewController *panel = [panels objectAtIndex:aIndex];
		[panels removeObjectAtIndex:aIndex];
		if (![panels containsObject:panel]) {
			[panel setParent:nil];
			[panel removeObserver:self forKeyPath:@"title"];
			[panel removeObserver:self forKeyPath:@"view"];
		}
		[self updateTabControl];
		[self refreshPanels];
	}
}


/**
 Animate to the panel at the supplied index
 */
- (void)switchToPanelAtIndex:(NSInteger)index {
	if (index < [tabControl segmentCount]) {
		[self showAll];
		NSRect containerFrame = [panelContainer frame];
		containerFrame.origin.x = -([self frame].size.width * index);
		[[panelContainer animator] setFrame:containerFrame];
		
		M3InfoPanelViewController *panel = [panels objectAtIndex:index];
		[panel reloadPanel];
		[closeButton setNextKeyView:[panel firstView]];
		[tabControl setSelectedSegment:index];
		
		if ([(id)[self delegate] respondsToSelector:@selector(infoPanelSelectionDidChange:)]) {
			[[self delegate] infoPanelSelectionDidChange:self];
		}
		selectedIndex = index;
	}
}






#pragma mark -
#pragma mark Actions

- (void)switchPanel:(id)sender {
	[self switchToPanelAtIndex:[tabControl selectedSegment]];
}

- (void)closePanel:(id)sender {
	if ([(id)[self delegate] respondsToSelector:@selector(infoPanelWillClose:)]) {
		[[self delegate] infoPanelWillClose:self];
	}
}

- (void)moveToNext:(id)sender {
	if ([(id)[self delegate] respondsToSelector:@selector(infoPanelWillMoveToNextObject:)]) {
		[[self delegate] infoPanelWillMoveToNextObject:self];
	}
}

- (void)moveToPrev:(id)sender {
	if ([(id)[self delegate] respondsToSelector:@selector(infoPanelWillMoveToPreviousObject:)]) {
		[[self delegate] infoPanelWillMoveToPreviousObject:self];
	}
}



/**
 Handle clean up after animation ends
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	if (flag) {
		[self hideAllHidden];
	}
}

/**
 Refresh the panel sizes and positions after the frame is resized
 */
- (void)setFrame:(NSRect)aRect {
	[super setFrame:aRect];
	[self refreshPanels];
}



@end

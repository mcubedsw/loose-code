/*****************************************************************
 M3OutlineView.h
 M3Extensions
 
 Created by Martin Pilkington on 28/07/2009.
 
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

#import "M3OutlineView.h"

#import "M3OutlineViewDelegate.h"
#import "M3OutlineViewDataSource.h"
#import "M3IndexSetEnumerator.h"

@interface M3OutlineView ()

@property (readwrite, copy) NSIndexSet *previousSelection;
@property (retain) NSIndexSet *currentSelection;

- (NSIndexSet *)adjustRowIndexes:(NSIndexSet *)indexset forChildrenOfItem:(id)item up:(BOOL)up;
- (NSArray *)childrenForItem:(id)item;

@end


@implementation M3OutlineView

@synthesize previousSelection;
@synthesize currentSelection;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		previousSelection = [[NSIndexSet alloc] init];
		currentSelection = [[NSIndexSet alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updatePreviousSelection:)
													 name:NSOutlineViewSelectionDidChangeNotification
												   object:self];
	}
	return self;
}

-(id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
		previousSelection = [[NSIndexSet alloc] init];
		currentSelection = [[NSIndexSet alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updatePreviousSelection:)
													 name:NSOutlineViewSelectionDidChangeNotification
												   object:self];
	}
	return self;
}

- (void)dealloc {
	[previousSelection release];
	[currentSelection release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


- (id <M3OutlineViewDelegate>)delegate {
	return (id <M3OutlineViewDelegate>)[super delegate];
}

- (void)setDelegate:(id <M3OutlineViewDelegate>)aDelegate {
	[super setDelegate:aDelegate];
}


- (id <M3OutlineViewDataSource>)dataSource {
	return (id <M3OutlineViewDataSource>)[super delegate];
}

- (void)setDataSource:(id <M3OutlineViewDataSource>)aDataSource {
	[super setDataSource:aDataSource];
}





- (void)updatePreviousSelection:(NSNotification *)note {
	[self setPreviousSelection:currentSelection];
	[self setCurrentSelection:[self selectedRowIndexes]];
}

- (void)keyDown:(NSEvent *)theEvent {
	//Handle keyboard re-arrange
	if (([theEvent keyCode] == 125 || [theEvent keyCode] == 126) && ([theEvent modifierFlags] & NSAlternateKeyMask && [theEvent modifierFlags] & NSShiftKeyMask)) {
		//No point doing all this work if we don't even respond to the selector, is there?
		if ([[self dataSource] respondsToSelector:@selector(outlineView:moveChildrenOfItem:atIndexes:toIndexes:)]) {
			NSMutableArray *items = [NSMutableArray arrayWithObject:@"nil"];
			NSMutableArray *selectedItems = [NSMutableArray array];
			NSMutableArray *indexes = [NSMutableArray arrayWithObject:[NSMutableIndexSet indexSet]];
			
			M3IndexSetEnumerator *indexEnum = [M3IndexSetEnumerator enumeratorWithIndexSet:[self selectedRowIndexes]];
			NSUInteger index;
			
			//Loop the indexes
			while ((index = [indexEnum nextIndex]) != NSNotFound) {
				
				id item = [self parentForItem:[self itemAtRow:index]];		//Get the parent for the current item
				[selectedItems addObject:[self itemAtRow:index]];			//Add the current item to an array for calculating selection later
				NSArray *children = [self childrenForItem:item];			//Get the children for the item
				index = [children indexOfObject:[self itemAtRow:index]];	//So we can get the index of the item within the children
				
				//If item is nil then we're at the root so add the index to the nil group
				if (!item) {
					[[indexes objectAtIndex:0] addIndex:index];
				} else {
					//If this is the first child of the parent then we need to initalise the index set
					if ([items indexOfObject:item] == NSNotFound) {
						[items addObject:item];
						[indexes addObject:[NSMutableIndexSet indexSet]];
					}
					[[indexes objectAtIndex:[items indexOfObject:item]] addIndex:index];
				}
			}
			
			
			//Loop through all the parent items
			for (id item in items) {
				//Get the current indexes
				NSIndexSet *currentRowIndexes = [indexes objectAtIndex:[items indexOfObject:item]];
				if ([currentRowIndexes count]) {
					//We have to store the string "nil"
					if ([item isEqual:@"nil"]) {
						item = nil;
					}
					//Get what we think the new rows should be
					NSIndexSet *suggestedRowIndexes = [self adjustRowIndexes:currentRowIndexes forChildrenOfItem:item up:[theEvent keyCode] == 126];
					BOOL move = YES;
					//Check if we should move for this item
					if ([[self dataSource] respondsToSelector:@selector(outlineView:validateMoveChildrenOfItem:atIndexes:toIndexes:)]) {
						move = [[self dataSource] outlineView:self validateMoveChildrenOfItem:item atIndexes:currentRowIndexes toIndexes:suggestedRowIndexes];
					}
					//If we do them tell the data source to move them (if it doesn't nasty things will happen! mwhahahaha)
					if (move) {
						[[self dataSource] outlineView:self moveChildrenOfItem:item atIndexes:currentRowIndexes toIndexes:suggestedRowIndexes];
					}
				}
			}
			
			//Build an index set of rows to be selected
			NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
			for (id item in selectedItems) {
				[indexSet addIndex:[self rowForItem:item]];
			}
			
			//If there are any to be selected then select them, otherwise beep to let the user know this action isn't allowed
			if ([indexSet count]) {
				[self selectRowIndexes:indexSet byExtendingSelection:NO];
			} else {
				NSBeep();
			}
		}
		return;
	}
	
	if ([[self delegate] respondsToSelector:@selector(outlineView:didReceiveKeyPressWithCode:)]) {
		[[self delegate] outlineView:self didReceiveKeyPressWithCode:[theEvent keyCode]];
	}
	
	BOOL performKeyDown = YES;
	if ([[self delegate] respondsToSelector:@selector(outlineView:shouldIgnoreKeyPressWithCode:)]) {
		performKeyDown = ![[self delegate] outlineView:self shouldIgnoreKeyPressWithCode:[theEvent keyCode]];
	}
	
	if (performKeyDown) {
		[super keyDown:theEvent];
	}
}

- (NSIndexSet *)adjustRowIndexes:(NSIndexSet *)indexset forChildrenOfItem:(id)item up:(BOOL)up {
	NSMutableIndexSet *adjustedIndexSet = [[NSMutableIndexSet alloc] init];
	NSUInteger numberOfRows = [[self dataSource] outlineView:self numberOfChildrenOfItem:item];
	//If we're moving down
	if (!up) {
		M3IndexSetEnumerator *enumerator = [M3IndexSetEnumerator reverseEnumeratorWithIndexSet:indexset];
		NSUInteger index;
		//Loop through the indexes and update
		while ((index = [enumerator nextIndex]) != NSNotFound) {
			NSUInteger newIndex = index + 1;
			//If we are at the highest index or the next index already exists then don't move
			if (newIndex >= numberOfRows || [adjustedIndexSet containsIndex:newIndex]) {
				newIndex = index;
			}
			[adjustedIndexSet addIndex:newIndex];
		}
	//If we're moving up
	} else {
		M3IndexSetEnumerator *enumerator = [M3IndexSetEnumerator enumeratorWithIndexSet:indexset];
		NSUInteger index;
		//Loop through the indexes and update
		while ((index = [enumerator nextIndex]) != NSNotFound) {
			NSInteger newIndex = index - 1;
			//If we are at the lowest index or the next index already exists then don't move
			if (newIndex < 0 || [adjustedIndexSet containsIndex:newIndex]) {
				newIndex = index;
			}
			[adjustedIndexSet addIndex:newIndex];
		}
	}
	return [adjustedIndexSet autorelease];
}

- (NSArray *)childrenForItem:(id)item {
	NSMutableArray *items = [NSMutableArray array];
	NSUInteger numberOfRows = [[self dataSource] outlineView:self numberOfChildrenOfItem:item];
	NSUInteger i = 0;
	for (i = 0; i < numberOfRows; i++) {
		[items addObject:[[self dataSource] outlineView:self child:i ofItem:item]];
	}
	return [[items copy] autorelease];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
	if ([theEvent type] == NSRightMouseDown) {
		NSIndexSet *selectedIndexes = [self selectedRowIndexes];
		NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		NSInteger row = [self rowAtPoint:mousePoint];
		BOOL shouldSelectRow = YES;
		if ([[self delegate] respondsToSelector:@selector(outlineView:shouldSelectItem:)] && ![selectedIndexes containsIndex:row]) {
			shouldSelectRow = [[self delegate] outlineView:self shouldSelectItem:[self itemAtRow:row]];
		}
		if (row >= 0 && shouldSelectRow) {
			if (![selectedIndexes containsIndex:row]) {
				[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
			}
			if ([[self delegate] respondsToSelector:@selector(contextMenuForOutlineView:)]) {
				NSMenu *menu = [[self delegate] contextMenuForOutlineView:self];
				if (menu) {
					return menu;
				}
			}
			return [self menu];
		} else {
			// you can disable this if you don't want clicking on an empty space to deselect all rows
			[self deselectAll:self];
		}
	}
	return nil;
}

@end
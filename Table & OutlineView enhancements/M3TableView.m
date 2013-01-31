/*****************************************************************
 M3TableView.m
 M3Extensions
 
 Created by Martin Pilkington on 07/05/2007.
 
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

#import "M3TableView.h"

#import "M3TableViewDelegate.h"
#import "M3TableViewDataSource.h"
#import "M3IndexSetEnumerator.h"

@interface M3TableView ()

@property (readwrite, copy) NSIndexSet *previousSelection;
@property (retain) NSIndexSet *currentSelection;
@property (readwrite, assign) NSInteger selectedRow;

- (NSIndexSet *)adjustRowIndexes:(NSIndexSet *)indexset up:(BOOL)up;
- (void)shiftRows:(NSIndexSet *)rows up:(BOOL)up;
- (void)collectRows:(NSIndexSet *)rows atIndex:(NSInteger)newIndex;
- (void)makeRowsSticky:(NSIndexSet *)indexes;

@end


@implementation M3TableView

@synthesize previousSelection;
@synthesize currentSelection;
@synthesize allowsStickySelection;
@synthesize stickySelectionIndexes;
@synthesize selectedRow;

#pragma mark -
#pragma mark Initialisation

/**
 Set everything up
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		previousSelection = [[NSIndexSet alloc] init];
		currentSelection = [[NSIndexSet alloc] init];
		stickySelectionIndexes = [[NSIndexSet alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updatePreviousSelection:)
													 name:NSTableViewSelectionDidChangeNotification
												   object:self];
	}
	return self;
}

-(id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
		previousSelection = [[NSIndexSet alloc] init];
		currentSelection = [[NSIndexSet alloc] init];
		stickySelectionIndexes = [[NSIndexSet alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updatePreviousSelection:)
													 name:NSTableViewSelectionDidChangeNotification
												   object:self];
	}
	return self;
}

/**
 Bring everything down
 */
- (void)dealloc {
	[previousSelection release];
	[currentSelection release];
	[stickySelectionIndexes release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}



- (id <M3TableViewDelegate>)delegate {
	return (id <M3TableViewDelegate>)[super delegate];
}

- (void)setDelegate:(id <M3TableViewDelegate>)aDelegate {
	[super setDelegate:aDelegate];
}


- (id <M3TableViewDataSource>)dataSource {
	return (id <M3TableViewDataSource>)[super dataSource];
}

- (void)setDataSource:(id <M3TableViewDataSource>)aDataSource {
	[super setDataSource:aDataSource];
}



#pragma mark -
#pragma mark Selection

/**
 Remove all stick indexes
 */
- (IBAction)deselectAll:(id)sender {
	[self setStickySelectionIndexes:[NSIndexSet indexSet]];
	[self selectRowIndexes:nil byExtendingSelection:NO];
}

/**
 Remove the row from a sticky index
 */
- (void)deselectRow:(NSInteger)rowIndex {
	[self removeStickyRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex]];
	[super deselectRow:rowIndex];
}

/**
 Selects rows, preserving the selection of sticky rows
 */
- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend {
	[self setSelectedRow:[indexes firstIndex]];
	NSMutableIndexSet *index = [indexes mutableCopy];
	if (allowsStickySelection) {
		[index addIndexes:[self stickySelectionIndexes]];
	}
	[super selectRowIndexes:index byExtendingSelection:extend];
	[index release];
}

/**
 Select row, preserving the selection of sticky rows
 */

- (void)selectRow:(NSInteger)rowIndex byExtendingSelection:(BOOL)extend {
	[self setSelectedRow:rowIndex];
	NSMutableIndexSet *index = [NSMutableIndexSet indexSetWithIndex:rowIndex];
	if (allowsStickySelection) {
		[index addIndexes:[self stickySelectionIndexes]];
	}
	[super selectRowIndexes:index byExtendingSelection:extend];
}

/**
 Update the current selection (which we need to handle manually now) for a mouse down
 */
- (void)mouseDown:(NSEvent *)theEvent {
	if ([[self window] isKeyWindow]) {
		NSPoint point = [self convertPointFromBase:[theEvent locationInWindow]];
		[self setSelectedRow:[self rowAtPoint:point]];
	}
	[super mouseDown:theEvent];
}

/**
 Updates the previous selection index set
 */
- (void)updatePreviousSelection:(NSNotification *)note {
	[self setPreviousSelection:currentSelection];
	[self setCurrentSelection:[self selectedRowIndexes]];
}



#pragma mark -
#pragma mark New keyboard events

- (void)keyDown:(NSEvent *)theEvent {
	//Handle keyboard re-arrange
	if ([theEvent keyCode] == 125 || [theEvent keyCode] == 126) {
		//Move rows
		if ([theEvent modifierFlags] & NSAlternateKeyMask && [theEvent modifierFlags] & NSShiftKeyMask) {
			[self shiftRows:[self selectedRowIndexes] up:[theEvent keyCode] == 126];
			return;
		//Collect rows
		} else if ([theEvent modifierFlags] & NSControlKeyMask && [theEvent modifierFlags] & NSShiftKeyMask) {
			NSIndexSet *selected = [self selectedRowIndexes];
			[self collectRows:selected atIndex:[theEvent keyCode] == 126 ? [selected firstIndex] : ([selected lastIndex] + 1)];
			return;
		}
	}
	
	//Sticky rows
	if ([theEvent keyCode] == 49 && [theEvent modifierFlags] & NSAlternateKeyMask && [theEvent modifierFlags] & NSShiftKeyMask && allowsStickySelection) {
		[self makeRowsSticky:[self selectedRowIndexes]];
		return;
	}
	
	//Did get keypress
	if ([[self delegate] respondsToSelector:@selector(tableView:didReceiveKeyPressWithCode:)]) {
		[[self delegate] tableView:self didReceiveKeyPressWithCode:[theEvent keyCode]];
	}
	
	//Should ignore it
	BOOL performKeyDown = YES;
	if ([[self delegate] respondsToSelector:@selector(tableView:shouldIgnoreKeyPressWithCode:)]) {
		performKeyDown = ![[self delegate] tableView:self shouldIgnoreKeyPressWithCode:[theEvent keyCode]];
	}
	
	//If we should accept it then do the standard action
	if (performKeyDown) {
		[super keyDown:theEvent];
	}
}

#pragma mark -
#pragma mark Shift Rows

/**
 Shifts the supplied rows up or down
 */
- (void)shiftRows:(NSIndexSet *)rows up:(BOOL)up {
	NSIndexSet *suggestedRowIndexes = [self adjustRowIndexes:rows up:up];
	BOOL move = YES;
	//Check if delegate lets us move
	if ([[self delegate] respondsToSelector:@selector(tableView:shouldMoveFromIndexes:toIndexes:)]) {
		move = [[self delegate] tableView:self shouldMoveFromIndexes:rows toIndexes:suggestedRowIndexes];
	}
	//If we can move and the data source works then move them and sort out the new selection
	if (move && [[self dataSource] respondsToSelector:@selector(tableView:moveRowsAtIndexes:toIndexes:)]) {
		[[self dataSource] tableView:self moveRowsAtIndexes:rows toIndexes:suggestedRowIndexes];
		[self deselectAll:self];
		[self selectRowIndexes:suggestedRowIndexes byExtendingSelection:NO];
	}
	if (!move) {
		NSBeep();
	}
}

/**
 Calculates the new indexes for the shift
*/
- (NSIndexSet *)adjustRowIndexes:(NSIndexSet *)indexset up:(BOOL)up {
	NSMutableIndexSet *adjustedIndexSet = [[NSMutableIndexSet alloc] init];
	NSUInteger numberOfRows = [[self dataSource] numberOfRowsInTableView:self];
	//Move rows down
	if (!up) {
		M3IndexSetEnumerator *enumerator = [M3IndexSetEnumerator reverseEnumeratorWithIndexSet:indexset];
		NSUInteger index;
		while ((index = [enumerator nextIndex]) != NSNotFound) {
			NSUInteger newIndex = index + 1;
			//If we're at the bottom then don't shift
			if (newIndex >= numberOfRows || [adjustedIndexSet containsIndex:newIndex]) {
				newIndex = index;
			}
			[adjustedIndexSet addIndex:newIndex];
		}
	//Move rows up
	} else {
		M3IndexSetEnumerator *enumerator = [M3IndexSetEnumerator enumeratorWithIndexSet:indexset];
		NSUInteger index;
		while ((index = [enumerator nextIndex]) != NSNotFound) {
			NSInteger newIndex = index - 1;
			//If we're at the top then don't shift
			if (newIndex < 0 || [adjustedIndexSet containsIndex:newIndex]) {
				newIndex = index;
			}
			[adjustedIndexSet addIndex:newIndex];
		}
	}
	return [adjustedIndexSet autorelease];
}


#pragma mark -
#pragma mark Collect Rows

/**
 Collects the supplied rows at newIndex
 */
- (void)collectRows:(NSIndexSet *)rows atIndex:(NSInteger)newIndex {
	BOOL collect = YES;
	//Check if the delegate says we shouldn't work
	if ([[self delegate] respondsToSelector:@selector(tableView:shouldCollectRowsAtIndexes:atNewIndex:)]) {
		collect = [[self delegate] tableView:self shouldCollectRowsAtIndexes:rows atNewIndex:newIndex];
	}
	//If we can collect and the data source implements it then collect and sort out the new welection
	if (collect && [[self dataSource] respondsToSelector:@selector(tableView:collectRowsAtIndexes:atNewIndex:)]) {
		[[self dataSource] tableView:self collectRowsAtIndexes:rows atNewIndex:newIndex];
		[self deselectAll:self];
		[self selectRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newIndex - (newIndex == [rows lastIndex] + 1 ? [rows count] : 0), [rows count])] byExtendingSelection:NO];
	}
	if (!collect) {
		NSBeep();
	}
}


#pragma mark -
#pragma mark Sticky Rows

/**
 Makes the supplied rows sticky
 */
- (void)makeRowsSticky:(NSIndexSet *)indexes {
	if ([self isRowSticky:[self selectedRow]]) {
		[self removeStickyRowIndexes:[NSIndexSet indexSetWithIndex:[self selectedRow]]];
	} else {
		[self addStickyRowIndexes:[NSIndexSet indexSetWithIndex:[self selectedRow]]];
	}
}


/**
 Marks the supplied rows as sticky
 */
- (void)addStickyRowIndexes:(NSIndexSet *)rowIndexes {
	if (allowsStickySelection) {
		NSMutableIndexSet *index = [[self stickySelectionIndexes] mutableCopy];
		[index addIndexes:rowIndexes];
		[self setStickySelectionIndexes:index];
		[index release];
	}
}

/**
 Unmarks the supplied rows as sticky
 */
- (void)removeStickyRowIndexes:(NSIndexSet *)rowIndexes {
	if (allowsStickySelection) {
		NSMutableIndexSet *index = [[self stickySelectionIndexes] mutableCopy];
		[index removeIndexes:rowIndexes];
		[self setStickySelectionIndexes:index];
		[index release];
	}
}

/**
 Checks if the supplied row is sticky
 */
- (BOOL)isRowSticky:(NSInteger)rowIndex {
	return [[self stickySelectionIndexes] containsIndex:rowIndex];
}

/**
 Deselects all rows that aren't sticky
 */
- (IBAction)deselectAllNonStickyRows:(id)sender {
	NSIndexSet *indexSet = [[self stickySelectionIndexes] retain];
	[super deselectAll:sender];
	[self setStickySelectionIndexes:indexSet];
	[indexSet release];
	[self selectRowIndexes:indexSet byExtendingSelection:NO];
}

/**
 Gets rid of all sticky rows
 */
- (IBAction)clearAllStickyRows:(id)sender {
	[self setStickySelectionIndexes:[NSIndexSet indexSet]];
}



#pragma mark -
#pragma mark Context Menu

/**
 Asks the delegate to provide a context menu for the table, selecting the appropriate row
 */
- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
	if ([theEvent type] == NSRightMouseDown) {
		NSIndexSet *selectedIndexes = [self selectedRowIndexes];
		NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		NSInteger row = [self rowAtPoint:mousePoint];
		BOOL shouldSelectRow = YES;
		if ([[self delegate] respondsToSelector:@selector(tableView:shouldSelectRow:)] && ![selectedIndexes containsIndex:row]) {
			shouldSelectRow = [[self delegate] tableView:self shouldSelectRow:row];
		}
		if (row >= 0 && shouldSelectRow) {
			if (![selectedIndexes containsIndex:row]) {
				[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
			}
			if ([[self delegate] respondsToSelector:@selector(contextMenuForTableView:)]) {
				NSMenu *menu = [[self delegate] contextMenuForTableView:self];
				if (menu) {
					return menu;
				}
			}
			return [self menu];
		} else {
			[self deselectAll:self];
		}
	}
	return nil;
}

@end

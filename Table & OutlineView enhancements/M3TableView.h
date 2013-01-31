/*****************************************************************
 M3TableView.h
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

#import <Cocoa/Cocoa.h>

#ifdef M3APPKIT_IB_BUILD
#import "M3IndexSetEnumerator.h"
#else
#import <M3Foundation/M3Foundation.h>
#endif


@protocol M3TableViewDelegate, M3TableViewDataSource;

/**
 @class M3TableView
 Adds delegate methods for dealing with key presses and context menus to NSTableView, as well as the option to get the previous selection index set
@since Available in M3AppKit 1.0 and later
 */
@interface M3TableView : NSTableView {
	NSIndexSet *previousSelection;
	NSIndexSet *currentSelection;
	NSIndexSet *stickySelectionIndexes;
	BOOL allowsStickySelection;
	NSInteger selectedRow;
}

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (assign) id <M3TableViewDelegate> delegate;

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (assign) id <M3TableViewDataSource> dataSource;

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (readonly, copy) NSIndexSet *previousSelection;

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (copy) NSIndexSet *stickySelectionIndexes;

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (assign) BOOL allowsStickySelection;

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (readonly) NSInteger selectedRow;


/**
 Adds the supplied rows to the list of sticky rows
 @param rowIndexes The rows to make sticky
 @since Available in M3AppKit 1.0 and later
 */
- (void)addStickyRowIndexes:(NSIndexSet *)rowIndexes;

/**
 Removes the supplied rows from the list of sticky rows
 @param rowIndexes The rows to unstick
 @since Available in M3AppKit 1.0 and later
 */
- (void)removeStickyRowIndexes:(NSIndexSet *)rowIndexes;

/**
 Deselects all rows that aren't sticky
 @param sender The sender of the call
 @since Available in M3AppKit 1.0 and later
 */

- (IBAction)deselectAllNonStickyRows:(id)sender;

/**
 Clears all the sticky rows
 @param sender The sender of the call
 This method does not deselect the rows, to deselect all rows then use -(void)deselectAll:(id)sender
 @since Available in M3AppKit 1.0 and later
 */
- (IBAction)clearAllStickyRows:(id)sender;

/**
 Returns a boolean value to indicate whether the row at the supplied index is sticky
 @param rowIndex The index of the row to test
 @return YES if the supplied row is sticky, otherwise NO
 @since Available in M3AppKit 1.0 and later
 */
- (BOOL)isRowSticky:(NSInteger)rowIndex;

@end
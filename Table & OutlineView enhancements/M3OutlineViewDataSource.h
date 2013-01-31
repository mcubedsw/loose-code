/*****************************************************************
M3OutlineViewDataSource.h
M3Extensions

Created by Martin Pilkington on 20/06/2010.

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

@class M3OutlineView;

/**
 @protocol PROTOCOL_HERE
 DESCRIPTION_HERE
 @since Available in M3AppKit 1.0 and later
 */
@protocol M3OutlineViewDataSource <NSOutlineViewDataSource>

@optional
/**
 Asks the data source whether the move should be allowed to go ahead
 @param outlineView The M3OutlineView sending the message
 @param currentIndexes The index set of the currently selected rows
 @prarm suggestedIndexes The index set of where the outline view has moved these indexes
 If this method isn't implemented, the the outline view always assumes that all moves are valid
 @return YES if the move should go ahead, NO if it should be cancelled
 @since Available in M3AppKit 1.0 and later
 */
- (BOOL)outlineView:(M3OutlineView *)anOutlineView validateMoveChildrenOfItem:(id)item atIndexes:(NSIndexSet *)currentIndexes toIndexes:(NSIndexSet *)suggestedIndexes;

/**
 Tells the data source to move the rows to new indexes
 @param outlineView The M3OutlineView sending the message
 @param currentIndexes The index set of the currently selected rows
 @prarm newIndexes The index set of where the data source should move these rows
 @since Available in M3AppKit 1.0 and later
 */
- (void)outlineView:(M3OutlineView *)anOutlineView moveChildrenOfItem:(id)item atIndexes:(NSIndexSet *)currentIndexes toIndexes:(NSIndexSet *)newIndexes;


@end

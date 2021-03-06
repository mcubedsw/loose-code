/*****************************************************************
 M3TableViewDataSource.h
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

@class M3TableView;

/**
 @protocol PROTOCOL_HERE
 DESCRIPTION_HERE
 @since Available in M3AppKit 1.0 and later
 */
@protocol M3TableViewDataSource <NSTableViewDataSource>

@optional
/**
 Tells the data source to move the rows to new indexes
 @param tableView The M3TableView sending the message
 @param currentIndexes The index set of the currently selected rows
 @prarm newIndexes The index set of where the data source should move these rows
 @since Available in M3AppKit 1.0 and later
 */
- (void)tableView:(M3TableView *)tableView moveRowsAtIndexes:(NSIndexSet *)currentIndexes toIndexes:(NSIndexSet *)newIndexes;

/**
 Tells the data source to collect the rows at the new index
 @param tableView The M3TableView sending the message
 @param currentIndexes The index set of the currently selected rows
 @prarm newIndex The index where the rows should be inserted
 @since Available in M3AppKit 1.0 and later
 */
- (void)tableView:(M3TableView *)tableView collectRowsAtIndexes:(NSIndexSet *)selectedIndexes atNewIndex:(NSInteger)newIndex;

@end

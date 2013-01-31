/*****************************************************************
 M3TableViewDelegate.h
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
@protocol M3TableViewDelegate <NSTableViewDelegate>

@optional
/**
 Asks the delegate for a menu to use when the right mouse button is clicked
 @param tableView The M3TableView sending the message
 @result An NSMenu object to use as a context menu when the right mouse button is clicked
 @since Available in M3AppKit 1.0 and later
 */
- (NSMenu *)contextMenuForTableView:(M3TableView *)tableView;

/**
 Informs the delegate that a key was pressed on the table
 @param tableView The M3TableView sending the message
 @param code The virtual key code of the key pressed
 @since Available in M3AppKit 1.0 and later
 */
- (void)tableView:(M3TableView *)tableView didReceiveKeyPressWithCode:(unsigned short)code;

/**
 Asks the delegate whether a pressed key should be ignored (often to be handled by the delegate)
 @param tableView The M3TableView sending the message
 @param code The virtual key code of the key pressed
 @return YES if the table view should ignore the keypress or NO if it should handle the key press itself
 @since Available in M3AppKit 1.0 and later
 */
- (BOOL)tableView:(M3TableView *)tableView shouldIgnoreKeyPressWithCode:(unsigned short)code;

/**
 Asks the delegate whether the move should be allowed to go ahead
 @param tableView The M3TableView sending the message
 @param currentIndexes The index set of the currently selected rows
 @prarm suggestedIndexes The index set of where the table view has moved these indexes
 If this method isn't implemented, the the table view always assumes that all moves are valid
 @return YES if the move should go ahead, NO if it should be cancelled
 @since Available in M3AppKit 1.0 and later
 */
- (BOOL)tableView:(M3TableView *)tableView shouldMoveFromIndexes:(NSIndexSet *)currentIndexes toIndexes:(NSIndexSet *)suggestedIndexes;

/**
 Asks the delegate whether the row collect should be allowed to go ahead
 @param tableView The M3TableView sending the message
 @param currentIndexes The index set of the currently selected rows
 @prarm newIndex The index where the rows should be inserted
 If this method isn't implemented, the the table view always assumes that all row collections are valid
 @return YES if the collect should go ahead, NO if it should be cancelled
 @since Available in M3AppKit 1.0 and later
 */
- (BOOL)tableView:(M3TableView *)tableView shouldCollectRowsAtIndexes:(NSIndexSet *)currentIndexes atNewIndex:(NSInteger)newIndex;

@end

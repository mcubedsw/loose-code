/*****************************************************************
 M3OutlineViewDelegate.h
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
@protocol M3OutlineViewDelegate <NSOutlineViewDelegate>

@optional
/**
 Asks the delegate for a menu to use when the right mouse button is clicked
 @param outlineView The M3OutlineView sending the message
 @result An NSMenu object to use as a context menu when the right mouse button is clicked
 @since Available in M3AppKit 1.0 and later
 */
- (NSMenu *)contextMenuForOutlineView:(M3OutlineView *)outlineView;

/**
 Informs the delegate that a key was pressed on the outline
 @param outlineView The M3OutlineView sending the message
 @param code The virtual key code of the key pressed
 @since Available in M3AppKit 1.0 and later
 */
- (void)outlineView:(M3OutlineView *)anOutlineView didReceiveKeyPressWithCode:(unsigned short)code;

/**
 Asks the delegate whether a pressed key should be ignored (often to be handled by the delegate)
 @param outlineView The M3OutlineView sending the message
 @param code The virtual key code of the key pressed
 @return YES if the outline view should ignore the keypress or NO if it should handle the key press itself
 @since Available in M3AppKit 1.0 and later
 */
- (BOOL)outlineView:(M3OutlineView *)anOutlineView shouldIgnoreKeyPressWithCode:(unsigned short)code;

@end

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

#import <Cocoa/Cocoa.h>

#ifdef M3APPKIT_IB_BUILD
#import "M3IndexSetEnumerator.h"
#else
#import <M3Foundation/M3Foundation.h>
#endif


@protocol M3OutlineViewDelegate, M3OutlineViewDataSource;

/**
 @class CLASS_HERE
 DESCRIPTION_HERE
 @since Available in M3AppKit 1.0 and later
 */
@interface M3OutlineView : NSOutlineView {
	NSIndexSet *previousSelection;
	NSIndexSet *currentSelection;
}

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (assign) id <M3OutlineViewDelegate> delegate;

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (assign) id <M3OutlineViewDataSource> dataSource;

/**
 @property PROPERTY_NAME
 ABSTRACT_HERE
 @since Available in M3AppKit 1.0 and later
 */
@property (readonly, copy) NSIndexSet *previousSelection;

@end



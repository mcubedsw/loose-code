/*****************************************************************
 M3InfoPanelViewController.m
 M3Extensions
 
 Created by Martin Pilkington on 18/06/2010.
 
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

#import "M3InfoPanelViewController.h"


@implementation M3InfoPanelViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self setParent:[aDecoder decodeObjectForKey:@"parent"]];
		[self setFirstView:[aDecoder decodeObjectForKey:@"firstView"]];
		[self setLastView:[aDecoder decodeObjectForKey:@"lastView"]];
		[self setButtonBarView:[aDecoder decodeObjectForKey:@"buttonBarView"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeConditionalObject:parent forKey:@"parent"];
	[aCoder encodeObject:firstView forKey:@"firstView"];
	[aCoder encodeObject:lastView forKey:@"lastView"];
	[aCoder encodeObject:buttonBarView forKey:@"buttonBarView"];
}

- (void)dealloc {
	parent = nil;
	[firstView release];
	[lastView release];
	[buttonBarView release];
	[super dealloc];
}

- (void)loadView {
	if ([self nibName]) {
		[super loadView];
	}
}

@synthesize parent;
@synthesize firstView;
@synthesize lastView;
@synthesize buttonBarView;

- (void)reloadPanel {}

@end

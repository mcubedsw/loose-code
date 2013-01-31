//
//  M3SectionedTableView.m
//  Lighthouse Keeper
//
//  Created by Martin Pilkington on 17/06/2011.
//  Copyright 2011 M Cubed Software. All rights reserved.
//

#import "M3SectionedTableView.h"

@class M3SectionedTableView;
@interface M3SectionedTableViewDelegate : NSObject <NSTableViewDelegate>
- (id)initWithTableView:(M3SectionedTableView *)aTableView;
@property (assign) id <M3SectionedTableViewDelegate>realDelegate;
@end

@interface M3SectionedTableViewDataSource : NSObject <NSTableViewDataSource>
- (id)initWithTableView:(M3SectionedTableView *)aTableView;
@property (assign) id <M3SectionedTableViewDataSource>realDataSource;
@end


@interface M3SectionedTableView () {
	M3SectionedTableViewDelegate *sectionedDelegate;
	M3SectionedTableViewDataSource *sectionedDataSource;
}

- (void)_setup;
- (NSUInteger)__totalNumberOfViews;
- (NSIndexPath *)__indexPathFromAbsoluteIndex:(NSInteger)aAbsoluteIndex;
- (NSInteger)__absoluteIndexFromIndexPath:(NSIndexPath *)aIndexPath;
- (NSView *)__viewForTableColumn:(NSTableColumn *)aTableColumn absoluteRow:(NSUInteger)aRow;
- (BOOL)__sectionHasHeader:(NSUInteger)aSection;

@end


@implementation M3SectionedTableView


#pragma mark -
#pragma mark Setup

/***************************
 
 **************************/
- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {
		[self _setup];
	}
	return self;
}

/***************************
 
 **************************/
- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self _setup];
	}
	return self;
}

/***************************
 
 **************************/
- (void)_setup {
	sectionedDelegate = [[M3SectionedTableViewDelegate alloc] initWithTableView:self];
	sectionedDataSource = [[M3SectionedTableViewDataSource alloc] initWithTableView:self];
}

/***************************
 
 **************************/
- (id<M3SectionedTableViewDataSource>)sectionedDataSource {
	return [sectionedDataSource realDataSource];
}

/***************************
 
 **************************/
- (void)setSectionedDataSource:(id<M3SectionedTableViewDataSource>)dataSource {
	[sectionedDataSource setRealDataSource:dataSource];
	[self setDataSource:(id)sectionedDataSource];
}

/***************************
 
 **************************/
- (id<M3SectionedTableViewDelegate>)sectionedDelegate {
	return [sectionedDelegate realDelegate];
}

/***************************
 
 **************************/
- (void)setSectionedDelegate:(id<M3SectionedTableViewDelegate>)delegate {
	[sectionedDelegate setRealDelegate:delegate];
	[self setDelegate:(id)sectionedDelegate];
}


- (NSRect)frameOfCellAtColumn:(NSInteger)aColumn rowAtIndexPath:(NSIndexPath *)aRow {
	NSRect frame = [super frameOfCellAtColumn:aColumn row:[self __absoluteIndexFromIndexPath:aRow]];
	frame.size.width = [self frame].size.width;
	return frame;
}

- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row {	
	return [self frameOfCellAtColumn:column rowAtIndexPath:[self __indexPathFromAbsoluteIndex:row]];
}






#pragma mark -
#pragma mark Internal

/***************************
 
 **************************/
- (NSUInteger)__totalNumberOfViews {
	NSUInteger totalViews = 0;
	for (NSUInteger i = 0; i < [self numberOfSections]; i++) {
		totalViews += [self numberOfRowsInSection:i];
		if ([self __sectionHasHeader:i]) {
			totalViews++;
		}
	}
	return totalViews;
}

/***************************
 
 **************************/
- (BOOL)__sectionHasHeader:(NSUInteger)aSection {
	if ([[sectionedDataSource realDataSource] respondsToSelector:@selector(tableView:shouldDisplayHeaderRowForSection:)]) {
		return [[sectionedDataSource realDataSource] tableView:self shouldDisplayHeaderRowForSection:aSection];
	}
	return YES;
}

/***************************
 
 **************************/
- (NSIndexPath *)__indexPathFromAbsoluteIndex:(NSInteger)aAbsoluteIndex {
	NSInteger row = aAbsoluteIndex;
	NSUInteger section = 0;
	for (NSUInteger i = 0; i < [self numberOfSections]; i++) {
		NSUInteger rowsInSection = [self numberOfRowsInSection:i];
		if ([self __sectionHasHeader:i]) {
			rowsInSection++;
		}
		if (row < rowsInSection) {
			section = i;
			break;
		} else {
			row -= rowsInSection;
		}
	}
	
	if ([self __sectionHasHeader:section]) {
		if (row == 0) {
			row = NSUIntegerMax;
		} else {
			row--;
		}
	}
	return [NSIndexPath indexPathForRow:row inSection:section];
}

/***************************
 
 **************************/
- (NSInteger)__absoluteIndexFromIndexPath:(NSIndexPath *)aIndexPath {
	NSUInteger absoluteIndex = 0;
	for (NSUInteger i = 0; i < [aIndexPath section]; i++) {
		absoluteIndex += [self numberOfRowsInSection:i];
		if ([self __sectionHasHeader:i]) {
			absoluteIndex++;
		}
	}
	absoluteIndex += [aIndexPath row];
	if ([self __sectionHasHeader:[aIndexPath section]]) {
		absoluteIndex++;
	}
	return absoluteIndex;
}

/***************************
 
 **************************/
- (NSView *)__viewForTableColumn:(NSTableColumn *)aTableColumn absoluteRow:(NSUInteger)aRow {
	NSIndexPath *indexPath = [self __indexPathFromAbsoluteIndex:aRow];
	if ([indexPath row] == NSUIntegerMax) {
		return [[sectionedDataSource realDataSource] tableView:self headerViewForTableColumn:aTableColumn section:[indexPath section]];
	} 
	return [[sectionedDataSource realDataSource] tableView:self viewForTableColumn:aTableColumn rowAtIndexPath:indexPath];
}




/***************************
 
 **************************/
- (NSInteger)numberOfSections {
	return [[sectionedDataSource realDataSource] numberOfSectionsInTableView:self];
}

/***************************
 
 **************************/
- (NSInteger)numberOfRowsInSection:(NSUInteger)aSection {
	return [[sectionedDataSource realDataSource] tableView:self numberOfRowsInSection:aSection];
}

/***************************
 
 **************************/
- (void)scrollRowAtIndexPathToVisible:(NSIndexPath *)aPath {
	[self scrollRowToVisible:[self __absoluteIndexFromIndexPath:aPath]];
}

/***************************
 
 **************************/
- (void)reloadDataForRowsAtIndexPaths:(NSArray *)aIndexPaths columnIndexes:(NSIndexSet *)aColumnIndexes{
	NSMutableIndexSet *rowIndexes = [NSMutableIndexSet indexSet];
	for (NSIndexPath *indexPath in aIndexPaths) {
		[rowIndexes addIndex:[self __absoluteIndexFromIndexPath:indexPath]];
	}
	
	[self reloadDataForRowIndexes:rowIndexes columnIndexes:aColumnIndexes];
}

/***************************
 
 **************************/
- (NSIndexPath *)indexPathForClickedRow {
	return [self __indexPathFromAbsoluteIndex:[self clickedRow]];
}

/***************************
 
 **************************/
- (void)selectRowsAtIndexPaths:(NSArray *)aIndexPaths byExtendingSelection:(BOOL)aExtend {
	NSMutableIndexSet *rowIndexes = [NSMutableIndexSet indexSet];
	for (NSIndexPath *indexPath in aIndexPaths) {
		[rowIndexes addIndex:[self __absoluteIndexFromIndexPath:indexPath]];
	}
	[self selectRowIndexes:rowIndexes byExtendingSelection:aExtend];
}

/***************************
 
 **************************/
- (NSArray *)indexPathsForSelectedRows {
	NSMutableArray *indexPaths = [NSMutableArray array];
	[[self selectedRowIndexes] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[indexPaths addObject:[self __indexPathFromAbsoluteIndex:idx]];
	}];
	return [indexPaths copy];
}

/***************************
 
 **************************/
- (void)deselectRowAtIndexPath:(NSIndexPath *)aRow {
	[self deselectRow:[self __absoluteIndexFromIndexPath:aRow]];
}

/***************************
 
 **************************/
- (NSIndexPath *)indexPathForSelectedRow {
	if ([self selectedRow] >= 0)
		return [self __indexPathFromAbsoluteIndex:[self selectedRow]];
	return nil;
}


/***************************
 
 **************************/
- (id)viewAtColumn:(NSInteger)aColumn rowAtIndexPath:(NSIndexPath *)aRow makeIfNecessary:(BOOL)aMakeIfNecessary {
	return [self viewAtColumn:aColumn row:[self __absoluteIndexFromIndexPath:aRow] makeIfNecessary:aMakeIfNecessary];
}

/***************************
 
 **************************/
- (id)rowViewAtIndexPath:(NSIndexPath *)aRow makeIfNecessary:(BOOL)aMakeIfNecessary {
	return [self rowViewAtRow:[self __absoluteIndexFromIndexPath:aRow] makeIfNecessary:aMakeIfNecessary];
}

/***************************
 
 **************************/
- (NSIndexPath *)indexPathForView:(NSView *)view {
	return [self __indexPathFromAbsoluteIndex:[self rowForView:view]];
}

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070

/***************************
 
 **************************/
- (void)insertRowsAtIndexPaths:(NSArray *)aIndexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions {
	NSMutableIndexSet *rowIndexes = [NSMutableIndexSet indexSet];
	for (NSIndexPath *indexPath in aIndexPaths) {
		[rowIndexes addIndex:[self __absoluteIndexFromIndexPath:indexPath]];
	}
	[self insertRowsAtIndexes:rowIndexes withAnimation:animationOptions];
}

/***************************
 
 **************************/
- (void)removeRowsAtIndexPaths:(NSArray *)aIndexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions {
	NSMutableIndexSet *rowIndexes = [NSMutableIndexSet indexSet];
	for (NSIndexPath *indexPath in aIndexPaths) {
		[rowIndexes addIndex:[self __absoluteIndexFromIndexPath:indexPath]];
	}
	[self removeRowsAtIndexes:rowIndexes withAnimation:animationOptions];
}

/***************************
 
 **************************/
- (void)moveRowAtIndexPath:(NSIndexPath *)aOldIndexPath toIndexPath:(NSIndexPath *)aNewIndexPath {
	[self moveRowAtIndex:[self __absoluteIndexFromIndexPath:aOldIndexPath] toIndex:[self __absoluteIndexFromIndexPath:aNewIndexPath]];
}

#endif



- (NSArray *)indexPathsForRowsInRect:(NSRect)aRect {
	NSMutableArray *indexPaths = [NSMutableArray array];
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:[self rowsInRect:aRect]];
	[indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[indexPaths addObject:[self __indexPathFromAbsoluteIndex:idx]];
	}];
	return [indexPaths copy];
}


@end





#pragma mark -
#pragma mark Delegate



@implementation M3SectionedTableViewDelegate {
	M3SectionedTableView *tableView;
}

@synthesize realDelegate;

/***************************
 
 **************************/
- (id)initWithTableView:(M3SectionedTableView *)aTableView {
	if ((self = [super init])) {
		tableView = aTableView;
	}
	return self;
}

/***************************
 
 **************************/
- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return [tableView __viewForTableColumn:tableColumn absoluteRow:row];
}

/***************************
 
 **************************/
- (NSTableRowView *)tableView:(NSTableView *)aTableView rowViewForRow:(NSInteger)row {
	return [[self realDelegate] tableView:aTableView rowViewForRowAtIndexPath:[tableView __indexPathFromAbsoluteIndex:row]];
}

/***************************
 
 **************************/
- (void)tableView:(NSTableView *)aTableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
	if ([[self realDelegate] respondsToSelector:@selector(tableView:didAddRowView:forRowAtIndexPath:)]) {
		[[self realDelegate] tableView:aTableView didAddRowView:rowView forRowAtIndexPath:[tableView __indexPathFromAbsoluteIndex:row]];
	}
}

/***************************
 
 **************************/
- (void)tableView:(NSTableView *)aTableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
	if ([[self realDelegate] respondsToSelector:@selector(tableView:didRemoveRowView:forRow:)]) {
		[[self realDelegate] tableView:aTableView didRemoveRowView:rowView forRowAtIndexPath:[tableView __indexPathFromAbsoluteIndex:row]];
	}
}

/***************************
 
 **************************/
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)row {
	NSIndexPath *indexPath = [tableView __indexPathFromAbsoluteIndex:row];
	if ([indexPath row] == NSUIntegerMax)
		return NO;
	if ([[self realDelegate] respondsToSelector:@selector(tableView:shouldSelectRowAtIndexPath:)])
		return [[self realDelegate] tableView:aTableView shouldSelectRowAtIndexPath:indexPath];
	return YES;
}

/***************************
 
 **************************/
- (CGFloat)tableView:(NSTableView *)aTableView heightOfRow:(NSInteger)row {
	NSIndexPath *indexPath = [tableView __indexPathFromAbsoluteIndex:row];
	if ([indexPath row] == NSUIntegerMax) {
		return [[self realDelegate] tableView:aTableView heightOfHeaderForSection:[indexPath section]];
	}
	return [[self realDelegate] tableView:aTableView heightOfRowAtIndexPath:indexPath];
}






#pragma mark -
#pragma mark Forwarding

/***************************
 
 **************************/
- (id)forwardingTargetForSelector:(SEL)aSelector {
	return [self realDelegate];
}

/***************************
 
 **************************/
- (BOOL)respondsToSelector:(SEL)aSelector {
	BOOL responds = [super respondsToSelector:aSelector];
	if (!responds) {
		responds = [[self realDelegate] respondsToSelector:aSelector];
	} else if (aSelector == @selector(tableView:rowViewForRow:)) {
		responds = [[self realDelegate] respondsToSelector:@selector(tableView:rowViewForRowAtIndexPath:)];
	} else if (aSelector == @selector(tableView:heightOfRow:)) {
		responds = [[self realDelegate] respondsToSelector:@selector(tableView:heightOfRowAtIndexPath:)] &&
					[[self realDelegate] respondsToSelector:@selector(tableView:heightOfHeaderForSection:)];
	}
	return responds;
}

@end





#pragma mark -
#pragma mark Data Source

@implementation M3SectionedTableViewDataSource {
	M3SectionedTableView *tableView;
}

@synthesize realDataSource;

/***************************
 
 **************************/
- (id)initWithTableView:(M3SectionedTableView *)aTableView {
	if ((self = [super init])) {
		tableView = aTableView;
	}
	return self;
}

/***************************
 
 **************************/
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [tableView __totalNumberOfViews];
}

//- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedIndexPath:(NSIndexPath *)aIndexPath proposedDropOperation:(NSTableViewDropOperation)dropOperation;
//- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info indexPath:(NSIndexPath *)aIndexPath dropOperation:(NSTableViewDropOperation)dropOperation;

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
	NSIndexPath *indexPath = [tableView __indexPathFromAbsoluteIndex:row];
	return [[self realDataSource] tableView:aTableView validateDrop:info proposedIndexPath:indexPath proposedDropOperation:dropOperation];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
	NSIndexPath *indexPath = [tableView __indexPathFromAbsoluteIndex:row];
	return [[self realDataSource] tableView:aTableView acceptDrop:info indexPath:indexPath dropOperation:dropOperation];
}

/***************************
 
 **************************/
- (id)forwardingTargetForSelector:(SEL)aSelector {
	return [self realDataSource];
}

/***************************
 
 **************************/
- (BOOL)respondsToSelector:(SEL)aSelector {
	BOOL responds = [super respondsToSelector:aSelector];
	if (!responds) {
		responds = [[self realDataSource] respondsToSelector:aSelector];
	} else if (aSelector == @selector(tableView:acceptDrop:row:dropOperation:)) {
		responds = [[self realDataSource] respondsToSelector:@selector(tableView:acceptDrop:indexPath:dropOperation:)];
	} else if (aSelector == @selector(tableView:validateDrop:proposedRow:proposedDropOperation:)) {
		responds = [[self realDataSource] respondsToSelector:@selector(tableView:validateDrop:proposedIndexPath:proposedDropOperation:)];
	}
	return responds;
}

@end





#pragma mark -
#pragma mark Index Path Extensions

@implementation NSIndexPath (M3SectionedTableViewExtensions) 

/***************************
 
 **************************/
+ (NSIndexPath *)indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section {
	NSUInteger indexes[2] = {section, row};
	return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

/***************************
 
 **************************/
- (NSUInteger)row {
	return [self indexAtPosition:1];
}

/***************************
 
 **************************/
- (NSUInteger)section {
	return [self indexAtPosition:0];
}

@end
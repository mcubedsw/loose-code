//
//  M3SectionedTableView.h
//  Lighthouse Keeper
//
//  Created by Martin Pilkington on 17/06/2011.
//  Copyright 2011 M Cubed Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "M3TableView.h"

@protocol M3SectionedTableViewDelegate, M3SectionedTableViewDataSource;

@interface M3SectionedTableView : M3TableView {
	
}

@property (assign) IBOutlet id<M3SectionedTableViewDataSource>sectionedDataSource;
@property (assign) IBOutlet id<M3SectionedTableViewDelegate>sectionedDelegate;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSUInteger)aSection;

- (void)scrollRowAtIndexPathToVisible:(NSIndexPath *)aPath;

- (void)reloadDataForRowsAtIndexPaths:(NSArray *)aRowIndexPaths columnIndexes:(NSIndexSet *)aColumnIndexes;

- (NSIndexPath *)indexPathForClickedRow;

//- (BOOL)canDragRowsAtIndexPaths:(NSArray *)aRowIndexPaths atPoint:(NSPoint)aMouseDownPoint;
//- (NSImage *)dragImageForRowsAtIndexPaths:(NSArray *)aDragRows tableColumns:(NSArray *)aTableColumns event:(NSEvent *)aDragEvent offset:(NSPointPointer)aDragImageOffset;
//- (void)setDropRowAtIndexPath:(NSIndexPath *)aRow dropOperation:(NSTableViewDropOperation)aDropOperation;

- (void)selectRowsAtIndexPaths:(NSArray *)aIndexPaths byExtendingSelection:(BOOL)aExtend;
- (NSArray *)indexPathsForSelectedRows;
- (void)deselectRowAtIndexPath:(NSIndexPath *)aRow;
- (NSIndexPath *)indexPathForSelectedRow;
//- (BOOL)isRowAtIndexPathSelected:(NSIndexPath *)aRow;

//- (NSRect)rectForRowAtIndexPath:(NSIndexPath *)aRow;
- (NSArray *)indexPathsForRowsInRect:(NSRect)aRect;
//- (NSIndexPath *)indexPathForRowAtPoint:(NSPoint)aPoint;

//- (NSRect)frameOfCellAtColumn:(NSInteger)aColumn rowAtIndexPath:(NSIndexPath *)aRow;

//- (void)editColumn:(NSInteger)aColumn rowAtIndexPath:(NSIndexPath *)aRow withEvent:(NSEvent *)aEvent select:(BOOL)aSelect;

- (id)viewAtColumn:(NSInteger)aColumn rowAtIndexPath:(NSIndexPath *)aRow makeIfNecessary:(BOOL)aMakeIfNecessary;
- (id)rowViewAtIndexPath:(NSIndexPath *)aRow makeIfNecessary:(BOOL)aMakeIfNecessary;

- (NSIndexPath *)indexPathForView:(NSView *)view;

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070

- (void)insertRowsAtIndexPaths:(NSArray *)aIndexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)removeRowsAtIndexPaths:(NSArray *)aIndexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveRowAtIndexPath:(NSIndexPath *)aOldIndexPath toIndexPath:(NSIndexPath *)aNewIndexPath;

#endif

@end






@protocol M3SectionedTableViewDelegate <NSTableViewDelegate>

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
@optional
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRowAtIndexPath:(NSIndexPath *)aRow;

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRowAtIndexPath:(NSIndexPath *)aRow;
- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRowAtIndexPath:(NSIndexPath *)aRow;

#endif

//- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

//- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation;

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)aRow;

//- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes;

- (CGFloat)tableView:(NSTableView *)tableView heightOfRowAtIndexPath:(NSIndexPath *)aRow;
- (CGFloat)tableView:(NSTableView *)tableView heightOfHeaderForSection:(NSUInteger)aSection;

//- (NSString *)tableView:(NSTableView *)tableView typeSelectStringForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
//- (NSInteger)tableView:(NSTableView *)tableView nextTypeSelectMatchFromRow:(NSInteger)startRow toRow:(NSInteger)endRow forString:(NSString *)searchString;

//- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row;

@end





@protocol M3SectionedTableViewDataSource <NSObject>

@required
- (NSInteger)numberOfSectionsInTableView:(NSTableView *)aTableView;
- (NSInteger)tableView:(NSTableView *)aTableView numberOfRowsInSection:(NSInteger)aSection;
- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)aTableColumn rowAtIndexPath:(NSIndexPath *)aRow;
- (NSView *)tableView:(NSTableView *)aTableView headerViewForTableColumn:(NSTableColumn *)aTableColumn section:(NSUInteger)aSection;

@optional
- (BOOL)tableView:(NSTableView *)aTableView shouldDisplayHeaderRowForSection:(NSUInteger)aSection;

//- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors;

//- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row;

//- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes;
//- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation;
//- (void)tableView:(NSTableView *)tableView updateDraggingItemsForDrag:(id <NSDraggingInfo>)draggingInfo;


//- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedIndexPath:(NSIndexPath *)aIndexPath proposedDropOperation:(NSTableViewDropOperation)dropOperation;
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info indexPath:(NSIndexPath *)aIndexPath dropOperation:(NSTableViewDropOperation)dropOperation;

//- (NSArray *)tableView:(NSTableView *)tableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet;

@end





@interface NSIndexPath (M3SectionedTableViewExtensions) 

+ (NSIndexPath *)indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section;

@property (readonly) NSUInteger row;
@property (readonly) NSUInteger section;

@end

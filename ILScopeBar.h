//
//  ILScopeBar.h
//  Iconolatrous
//
//  Created by Alex Zielenski on 8/1/10.
//  Copyright 2010 Alex Zielenski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ILScopeBar;
@protocol ILScopeBarDataSource
@required
- (NSInteger)numberOfItemsInScopeBar:(ILScopeBar*)bar;
- (NSString*)titleOfItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;

@optional
- (NSString*)titleForBar:(ILScopeBar*)bar;
- (NSInteger)tagForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;
- (NSImage*)imageForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;
@end
@protocol ILScopeBarDelegate
@optional
- (BOOL)shouldSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;
- (void)didSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx withTag:(NSInteger)tag andTitle:(NSString*)title;
@end


#define gItemCountSelector @selector(numberOfItemsInScopeBar:)
#define gItemTitleSelector @selector(titleOfItemInScopeBar:atIndex:)

#define gBarTitleSelector @selector(titleForBar:)
#define gItemTagSelector @selector(tagForItemInScopeBar:atIndex:)
#define gItemImageSelector @selector(imageForItemInScopeBar:atIndex:)

#define gShouldSelectItemSelector @selector(shouldSelectItemInScopeBar:atIndex:)
#define gDidSelectItemSelector @selector(didSelectItemInScopeBar:atIndex:withTag:andTitle:)

@interface ILScopeBar : NSView {
	id <ILScopeBarDataSource> dataSource;
	id <ILScopeBarDelegate> delegate;
	id selectedItem;
	NSInteger cutoffIndex;
	NSPopUpButton *overflowButton;
}
@property (readonly) NSPopUpButton *overflowButton;
@property (assign) NSInteger cutoffIndex;
@property (assign) IBOutlet id delegate;
@property (assign) id selectedItem;
@property (assign) NSInteger selectedIndex;
@property (assign) IBOutlet id dataSource;
- (void)reload;
- (NSRect)frameForItemAtIndex:(NSInteger)idx; // Generates a new frame for an item. To get the actual frame of the item, use the scope bar's subviews and objectAtIndex:
- (NSRect)frameForBarTitle;

- (NSString*)titleOfItemAtIndex:(NSInteger)idx;
- (NSInteger)itemCount;
- (NSImage*)imageForItemAtIndex:(NSInteger)idx; // Calls the dataSource method. If it isnt implemented or it returns null. Just returns nil.
- (NSInteger)tagForItemAtIndex:(NSInteger)idx; // Calls the dataSource method. If not implemented, returns 0.
- (NSString*)title; // Calls the dataSource method. If not implemented, returns nil.
- (NSAttributedString*)attributedTitle;
- (BOOL)shouldSelectItemAtIndex:(NSInteger)idx;
- (void)didSelectItem:(id)item;

- (NSButton*)itemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;
- (void)addItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;
- (NSMenuItem*)menuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;
- (void)addMenuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;

- (void)rearrangeItems;
- (void)createOverflowButton;

- (BOOL)overflows;
- (NSInteger)cutoffIndex;
- (NSInteger)indexOfItem:(id)item;
- (NSArray*)items;

@end



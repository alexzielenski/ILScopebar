//
//  ILScopeBar.h
//  Iconolatrous
//
//  Created by Alex Zielenski on 8/1/10.
//  Copyright 2010 Alex Zielenski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILScopeBarProtocols.h"

/**
 @c ILScopebar is a @c NSView subclass for a scope bar like the one finder uses in it's search. 
 It is different from MGScopebar and apple's scope bar because instead of grouping, it consolidates all the items that 
 don't fit into a menu at the end of it. 
 */
@interface ILScopeBar : NSView {
	id <ILScopeBarDataSource> dataSource;
	id <ILScopeBarDelegate> delegate;
	id selectedItem;
	NSInteger cutoffIndex;
	NSPopUpButton *overflowButton;
}
	//////////////////////////////////////////////////////////////////////////////////////////
	/// @name Properties
	//////////////////////////////////////////////////////////////////////////////////////////
/** @c ILScopeBar uses NSPopUpButton to display it's overflow menu.
 @see cutoffIndex
 */
@property (readonly) NSPopUpButton *overflowButton;
/** If every item fits, returns the last index of the items.
 @return Returns the index of which the scope bar's items cut off.
 @see overflowButton
 */
@property (readonly) NSInteger cutoffIndex;
/** 
 @return Returns an @c NSButton or @c NSMenuItem depending upon if the item is in the overflow menu.
 @see selectedIndex
 */
@property (assign) id selectedItem;
/**
 @see selectedItem
 @return Returns the index of the selected item.
 */
@property (assign) NSInteger selectedIndex;
/** The delegate could implement the option @c ILScopeBarDelegate Protocol methods.
 @see ILScopeBarDelegate
 @see dataSource
 */
@property (assign) IBOutlet id delegate;
/** The datasource to use for the scope bar.
 
 @warning The datasource must implement the @c ILScopeBarDataSource protocol required methods.
 
 @see ILScopeBarDataSource
 @see delegate
 */
@property (assign) IBOutlet id dataSource;

	//////////////////////////////////////////////////////////////////////////////////////////
	/// @name Displaying the Scope Bar
	//////////////////////////////////////////////////////////////////////////////////////////
/** The title that gets displayed at the left side of the scope bar.
 @return Returns the datasource's @c titleForMethod: method. If not implemented, returns nil.
 @see attributedTitle
 */
- (NSString*)title; // Calls the dataSource method. If not implemented, returns nil.
/**
 @return Returns an @c NSAttributed string used when drawing the title.
 @see title
 */
- (NSAttributedString*)attributedTitle;

/** Rearranges the items and recreates the overflow button.
 @see rearrangeItems
 @see createOverflowButton
 */
- (void)reload;
/** Removes all of the items from the bar and overflow button and then recreates them in their appropriate position.
 @see reload
 @see createOverflowButton
 */
- (void)rearrangeItems;
/** Releases and recreates the overflow button.
 
 @see reload
 @see rearrangeItems
 */
- (void)createOverflowButton;

	//////////////////////////////////////////////////////////////////////////////////////////
	/// @name Getting Item Info
	//////////////////////////////////////////////////////////////////////////////////////////
/** To get the actual frame of the item, use the scope bar's subviews and objectAtIndex:
 @return Returns a newly generated frame for the item.
 @warning Value may not be exact.
 @see indexOfItem:
 @see frameForBarTitle
 */
- (NSRect)frameForItemAtIndex:(NSInteger)idx;

/**
 @returns Returns the frame of the bar title used for drawing.
 @see frameForItemAtIndex:
 */
- (NSRect)frameForBarTitle;

/** 
 @return Index of the specified item.
 @warning If the item isn't in the Scope Bar's @c items array, returns NSNotFound
 */
- (NSInteger)indexOfItem:(id)item;
/** Calls the data source method, @c titleOfItemInScopeBar:atIndex:
 @return Returns the value returned by the data source, nil if the data source doesn't implement it or if the data source hasn't been defined.
 
 @see itemCount
 @see imageForItemAtIndex:
 @see tagForItemAtIndex:
 */
- (NSString*)titleOfItemAtIndex:(NSInteger)idx;
/** Calls the data source method, @c numberOfItemsInScopeBar:
 @return Returns the value returned by the data source, 0 if the data source doesn't implement it or if the data source hasn't been defined.
 
 @see titleOfItemAtIndex:
 @see imageForItemAtIndex:
 @see tagForItemAtIndex:
 */
- (NSInteger)itemCount;
/** Calls the data source method, @c imageOfItemInScopeBar:atIndex:
 @return Returns the value returned by the data source, nil if the data source doesn't implement it or if the data source hasn't been defined.
 
 @see itemCount
 @see titleForItemAtIndex:
 @see tagForItemAtIndex:
 */
- (NSImage*)imageForItemAtIndex:(NSInteger)idx; // Calls the dataSource method. If it isnt implemented or it returns null. Just returns nil.
/** Calls the data source method, @c tagOfItemInScopeBar:atIndex:
 @return Returns the value returned by the data source, 0 if the data source doesn't implement it or if the data source hasn't been defined.
 
 @see itemCount
 @see imageForItemAtIndex:
 @see titleForItemAtIndex:
 */
- (NSInteger)tagForItemAtIndex:(NSInteger)idx; // Calls the dataSource method. If not implemented, returns 0.
/**
 @return Returns the list of the scopebar's subviews filtered by the classes @c NSButton or @c NSMenuItem
 @warning If there are any unexpected subviews in items, they will be in this list or be removed and released on the next @c reload call.
 */
- (NSArray*)items;
@end



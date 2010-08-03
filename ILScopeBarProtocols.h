//
//  ILScopeBarProtocols.h
//  ILScopeBar
//
//  Created by Alex Zielenski on 8/3/10.
//  Copyright 2010 Alex Zielenski. All rights reserved.
//


@class ILScopeBar;
/**
 The required protocol used for any Data Source set for @c ILScopeBar
 */
@protocol ILScopeBarDataSource
	//////////////////////////////////////////////////////////////////////////////////////////
	/// @name Required Methods
	//////////////////////////////////////////////////////////////////////////////////////////
@required
/**
 @return Return the number of items to be used for the scope bar.
 @warning This method gets called often, so be sure to optimize it accordingly.
 */
- (NSInteger)numberOfItemsInScopeBar:(ILScopeBar*)bar;
/**
 @return Return the tile of all the items to be used for the scope bar.
 @warning This method gets called often, so be sure to optimize it accordingly.
 */
- (NSString*)titleOfItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;
	//////////////////////////////////////////////////////////////////////////////////////////
	/// @name Optional Methods
	//////////////////////////////////////////////////////////////////////////////////////////
@optional
/** Usually this would have a semicolon
 @return Return the title drawn at the left of the scope bar.
 @warning This method gets called often, so be sure to optimize it accordingly.
 */
- (NSString*)titleForBar:(ILScopeBar*)bar;
/**
 @return Return the tag of the items in the scope bar.
 @warning This method gets called often, so be sure to optimize it accordingly.
 */
- (NSInteger)tagForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;
/**
 @return Return the image of items to be used for the scope bar.
 @warning This method gets called often, so be sure to optimize it accordingly.
 */
- (NSImage*)imageForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;

@end

/**
 A protocol of optional methods that ccould be used for the delegate of an @c ILScopeBar
 @see ILScopeBarDataSource
 @see ILScopeBar
 */
@protocol ILScopeBarDelegate
	//////////////////////////////////////////////////////////////////////////////////////////
	/// @name Optional Methods
	//////////////////////////////////////////////////////////////////////////////////////////
@optional
/** The scope bar calls this method before an item gets selected. If the delegate returns NO, it doesn't change the selection.
 @warning This method gets called often so be weary of what gets done inside of it.
 */
- (BOOL)shouldSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx;
/** The scope bar calls this delegate method after every time an item is selection. 
 
 */
- (void)didSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx withTag:(NSInteger)tag andTitle:(NSString*)title;
@end

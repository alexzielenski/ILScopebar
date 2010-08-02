//
//  ILScopeBarAppDelegate.m
//  ILScopeBar
//
//  Created by Alex Zielenski on 8/2/10.
//  Copyright 2010 Alex Zielenski. All rights reserved.
//

#import "ILScopeBarAppDelegate.h"

@implementation ILScopeBarAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	people=[[NSArray alloc] initWithObjects:@"Alex", @"Bill", @"Paula", @"Jane", @"Kendra", @"Walter", @"Valerie", @"Rachel", @"Victoria", @"Tiffany", @"Thomas", @"Tom K.", @"Maria", @"Peter", @"Brandon", @"William", @"Josephine", @"Barbara", @"Louis", @"Robert", nil];
	[scopeBar reload];
}
- (void)dealloc {
	[people release];
	[super dealloc];
}
- (NSInteger)numberOfItemsInScopeBar:(ILScopeBar*)bar {
	return [people count];
}
- (NSString*)titleOfItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	return [people objectAtIndex:idx];
}

- (NSString*)titleForBar:(ILScopeBar*)bar {
	return @"People:";
}
- (NSInteger)tagForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	return idx;
}
- (NSImage*)imageForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	if (idx % 2 == 1)
		return [NSImage imageNamed:@"NSComputer"];
	return nil;
}

- (BOOL)shouldSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	return YES;
}
- (void)didSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx withTag:(NSInteger)tag andTitle:(NSString*)title {
	[label setStringValue:[NSString stringWithFormat:@"Selected Item in Bar: %@\nTag: %i\nTitle: %@\nType: %@", bar.title, tag, title, [bar.selectedItem className]]];
}
@end

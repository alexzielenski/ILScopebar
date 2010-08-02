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
	
	NSArray *temp=[[NSArray alloc] initWithObjects:@"Alex", @"Bill", 
				   @"Paula", @"Jane", 
				   @"Kendra", @"Walter", 
				   @"Valerie", @"Rachel", 
				   @"Victoria", @"Tiffany", 
				   @"Thomas", @"Tom K.",
				   @"Maria", @"Peter", 
				   @"Brandon", @"William", 
				   @"Josephine", @"Barbara", 
				   @"Louis", @"Robert", nil];
	people=[[NSMutableArray alloc] init];
	for (int x = 0;x<temp.count;x++) {
		NSString *name = [temp objectAtIndex:x];
		NSInteger tag = x;
		NSImage *image = (tag % 2 == 1) ? [NSImage imageNamed:@"NSComputer"] : nil;
		[people addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name", [NSNumber numberWithInteger:tag], @"tag", image, @"image", nil]]; // image needs to go last because if it is nil, it'll count that as the sentinel
	}
	[scopeBar reload];
}
- (void)dealloc {
	[people release];
	[super dealloc];
}

#pragma mark -
#pragma mark Interface
- (IBAction)setTitle:(id)sender {
	NSLog(@"Setting title to: %@", [barTitle stringValue]);
	[scopeBar reload];
}
- (IBAction)addObject:(id)sender {
	if ([sender tag]==101) {
		int idx = idxField.intValue;
		if (idx<0||idx>=people.count)
			idx=people.count;
		NSString *name = titleField.stringValue;
		NSInteger tag = tagField.integerValue;
		NSImage *image = imageView.image;
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", [NSNumber numberWithInteger:tag], @"tag", image, @"image", nil];
		[people insertObject:dict 
					 atIndex:idx];
		[scopeBar reload];
		[self cancelAdd:sender];
		return;
	}
	[NSApp beginSheet:addWindow
	   modalForWindow:self.window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
}
- (IBAction)cancelAdd:(id)sender {
	[NSApp endSheet:addWindow];
	[addWindow orderOut:sender];
}
- (IBAction)removeSelected:(id)sender {
	[people removeObjectAtIndex:scopeBar.selectedIndex];
	[scopeBar reload];
}

#pragma mark -
#pragma mark Scope Bar Data Source Methods
- (NSInteger)numberOfItemsInScopeBar:(ILScopeBar*)bar {
	return [people count];
}
- (NSString*)titleOfItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	return [[people objectAtIndex:idx] objectForKey:@"name"];
}

- (NSString*)titleForBar:(ILScopeBar*)bar {
	return [barTitle stringValue];
}
- (NSInteger)tagForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	return [[[people objectAtIndex:idx] objectForKey:@"tag"] integerValue];
}
- (NSImage*)imageForItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	return [[people objectAtIndex:idx] objectForKey:@"image"];
}

#pragma mark -
#pragma mark Scope Bar Delegate Methods
- (BOOL)shouldSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx {
	return YES;
}
- (void)didSelectItemInScopeBar:(ILScopeBar*)bar atIndex:(NSInteger)idx withTag:(NSInteger)tag andTitle:(NSString*)title {
	[label setStringValue:[NSString stringWithFormat:@"Selected Item in Bar: %@\nTag: %i\nTitle: %@\nType: %@", bar.title, tag, title, [bar.selectedItem className]]];
}
@end

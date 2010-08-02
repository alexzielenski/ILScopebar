//
//  ILScopeBarAppDelegate.h
//  ILScopeBar
//
//  Created by Alex Zielenski on 8/2/10.
//  Copyright 2010 Alex Zielenski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILScopeBar.h"

@interface ILScopeBarAppDelegate : NSObject <NSApplicationDelegate, ILScopeBarDelegate, ILScopeBarDataSource> {
    NSWindow *window;
	NSMutableArray *people;
	
	IBOutlet ILScopeBar *scopeBar;
	IBOutlet NSTextField *label;
	IBOutlet NSTextField *barTitle;
	
	IBOutlet NSWindow *addWindow;
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *idxField;
	IBOutlet NSTextField *tagField;
	IBOutlet NSImageView *imageView;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)addObject:(id)sender;
- (IBAction)cancelAdd:(id)sender;
- (IBAction)removeSelected:(id)sender;
- (IBAction)setTitle:(id)sender;
@end

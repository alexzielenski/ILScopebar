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
	NSArray *people;
	IBOutlet ILScopeBar *scopeBar;
}

@property (assign) IBOutlet NSWindow *window;

@end

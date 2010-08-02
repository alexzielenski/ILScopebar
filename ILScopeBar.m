//
//  ILScopeBar.m
//  Iconolatrous
//
//  Created by Alex Zielenski on 8/1/10.
//  Copyright 2010 Alex Zielenski. All rights reserved.
//

#import "ILScopeBar.h"

#define gTopColor [NSColor colorWithCalibratedWhite:0.883f alpha:1.000f]
#define gBottomColor [NSColor colorWithCalibratedWhite:0.774f alpha:1.000f]
#define gBorderColor [NSColor colorWithCalibratedWhite:0.427f alpha:1.000f]

#define gGradient [[[NSGradient alloc] initWithStartingColor:gTopColor endingColor:gBottomColor] autorelease]

#define gTitleLeftPadding
#define gTitleColor [NSColor darkGrayColor]
#define gTitleFont [NSFont boldSystemFontOfSize:12.0f]

#define gItemTitleFont [NSFont fontWithName:@"LucidaGrande-Bold" size:12.0f]
#define gItemTitlePadding gItemSpacing+4
#define gItemSpacing 10

@implementation ILScopeBar
@synthesize dataSource, selectedItem, delegate, cutoffIndex, overflowButton;
@dynamic selectedIndex;
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[[NSImage imageNamed:@"Arrows"] setTemplate:YES];
		[self reload];
    }
    return self;
}
- (void)dealloc {
	[overflowButton removeFromSuperview];
	[overflowButton release];
	[super dealloc];
}
- (NSButton*)itemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index {
	NSButton *nb = [[NSButton alloc] initWithFrame:[self frameForItemAtIndex:index]];
	[nb setShowsBorderOnlyWhileMouseInside:YES];
	[nb setBordered:YES];
	[nb setAlignment:NSCenterTextAlignment];
	[nb setButtonType:NSPushOnPushOffButton];
	[nb.cell setHighlightsBy:NSCellIsBordered | NSCellIsInsetButton];
	[nb.cell setImageScaling:NSImageScaleProportionallyDown];
	[nb setBezelStyle:NSRecessedBezelStyle];
	[nb setImagePosition:NSImageLeft];
	
	[nb setTitle:title];
	[nb setImage:img];
	[nb setTag:tag];
	
	
	[nb setTarget:self];
	[nb setAction:@selector(setSelectedItem:)];
	return [nb autorelease];
}
- (void)addItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index {
	[self addSubview:[self itemWithTitle:title tag:tag image:img forIndex:index]];
}
- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	[gGradient drawInRect:dirtyRect angle:270];
	[gBorderColor set];
	NSRectFill(NSMakeRect(0, 0, dirtyRect.size.width, 1));
	
	NSTextFieldCell *tf = [[NSTextFieldCell alloc] init];
	[tf setAttributedStringValue:self.attributedTitle];
	[tf setBackgroundStyle:NSBackgroundStyleRaised];
	[tf drawWithFrame:self.frameForBarTitle 
			   inView:self];
	[tf release];
	
	if (self.inLiveResize) {
			//[self reload];
	}
	
	
}
- (void)reload {
	
	for (NSView *v in self.subviews) {
		[v removeFromSuperview];
		[v release];
	}
		
	if (overflowButton)
		[overflowButton removeFromSuperview], [overflowButton release], overflowButton=nil;
	
	if (!overflowButton && [self overflows]) {
		overflowButton=[[NSPopUpButton alloc] initWithFrame:NSMakeRect(NSMaxX(self.bounds)-28-gItemSpacing, 4, 28, 19)];		
		[overflowButton setButtonType:NSMomentaryLightButton];
		[overflowButton setBezelStyle:NSRecessedBezelStyle];
		[overflowButton setShowsBorderOnlyWhileMouseInside:YES];
			//[overflowButton setTextAlignment:NSCenterTextAlignment];
		[overflowButton setPreferredEdge:NSMinYEdge];
		[overflowButton.cell setUsesItemFromMenu:NO];
		[overflowButton.cell setArrowPosition:NSPopUpNoArrow];
		[overflowButton.cell setAltersStateOfSelectedItem:YES];
		[overflowButton.cell setHighlightsBy:NSCellIsBordered | NSCellIsInsetButton];
		[overflowButton.cell setImageScaling:NSImageScaleProportionallyDown];
		
		[overflowButton setTarget:self];
		[overflowButton setAction:@selector(setSelectedItem:)];
		
		NSMenuItem *men = [[NSMenuItem alloc] init];
		[men setTitle:@""];
		[men setImage:[NSImage imageNamed:@"Arrows"]];
		[overflowButton.cell setMenuItem:men];
		[men release];
		
		[self addSubview:overflowButton];
	}
	
	for (int x = 0; x<=self.cutoffIndex;x++) {
		[self addItemWithTitle:[self titleOfItemAtIndex:x] 
						   tag:[self tagForItemAtIndex:x] 
						 image:[self imageForItemAtIndex:x]
					  forIndex:x];
	}
	for (int x = self.cutoffIndex+1; x<self.itemCount;x++) {
		[self addMenuItemWithTitle:[self titleOfItemAtIndex:x] 
							   tag:[self tagForItemAtIndex:x] 
							 image:[self imageForItemAtIndex:x] 
						  forIndex:x];
	}
}
- (NSMenuItem*)menuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index {
	NSMenuItem *item = [NSMenuItem new];
	
	[item setTitle:title];
	[item setTag:tag];
	[item setImage:img];
	
	return [item autorelease];
}
- (void)addMenuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index {
	[overflowButton.menu addItem:[self menuItemWithTitle:title tag:tag image:img forIndex:index]];
}

#pragma mark Display
- (NSRect)frameForItemAtIndex:(NSInteger)idx { // Generates a new frame for an item. To get the actual frame of the item, use the scope bar's subviews and objectAtIndex:
	
	
	NSRect n = NSZeroRect;
	
	if (idx==0) {
		NSRect t = self.frameForBarTitle;
		n.origin.x=t.origin.x+t.size.width; // root origin
		n.size.height=19;
		n.origin.y=roundf(NSMidY(self.bounds)-n.size.height/2)-1;
	}
	if (idx > 0) {
		n = [self frameForItemAtIndex:idx-1];
		n.origin.x+=n.size.width;
		n.origin.x+=gItemSpacing;

	}
	
	
	NSString *title = [self titleOfItemAtIndex:idx];
	NSImage *itemImage = [self imageForItemAtIndex:idx];
	NSSize titleSize = [title sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:gItemTitleFont, NSFontAttributeName, nil]];
	if (itemImage)
		titleSize.width+=itemImage.size.width;
	
	n.size.width=titleSize.width;
	n.size.width+=gItemTitlePadding;
	return n;
}
- (NSRect)frameForBarTitle {
	NSString *title = self.title;
	if (!title)
		return NSZeroRect;
	NSSize titleSize=[self.attributedTitle size];
	NSRect t = NSZeroRect;
	t.origin.x=gItemSpacing;
	t.size.width=titleSize.width+gItemTitlePadding*2;
	t.size.height=titleSize.height;
	t.origin.y=roundf(NSMidY(self.bounds)-t.size.height/2);
	return t;
}


- (BOOL)overflows {
	for (int x = 0; x<self.itemCount;x++) {
		NSRect f = [self frameForItemAtIndex:x];
		if (f.origin.x+f.size.width+gItemSpacing>self.bounds.size.width) {
			self.cutoffIndex=x-1;
			return YES;
		}
	}
	self.cutoffIndex=self.itemCount-1;
	return NO;
}


#pragma mark -
#pragma mark Data Source Data
- (NSString*)titleOfItemAtIndex:(NSInteger)idx {
	
	if (idx==-1)
		return @">>";
	
	if ([self.dataSource respondsToSelector:gItemTitleSelector])
		return [self.dataSource titleOfItemInScopeBar:self atIndex:idx];
	return @"Untitled";
}
- (NSInteger)itemCount {
	if ([self.dataSource respondsToSelector:gItemCountSelector])
		return [self.dataSource numberOfItemsInScopeBar:self];
	return 0;
}

- (NSImage*)imageForItemAtIndex:(NSInteger)idx { // Calls the dataSource method. If it isnt implemented or it returns null. Just returns nil.
	
	if (idx==-1)
		return nil;
	
	if ([self.dataSource respondsToSelector:gItemImageSelector])
		return [self.dataSource imageForItemInScopeBar:self atIndex:idx];
	return nil;
}
- (NSInteger)tagForItemAtIndex:(NSInteger)idx { // Calls the dataSource method. If not implemented, returns 0.
	if ([self.dataSource respondsToSelector:gItemTagSelector])
		return [self.dataSource tagForItemInScopeBar:self atIndex:idx];
	return 0;
}
- (NSAttributedString*)attributedTitle {
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:self.title attributes:[NSDictionary dictionaryWithObjectsAndKeys:gTitleFont, NSFontAttributeName, gTitleColor, NSForegroundColorAttributeName, nil]];
	return [title autorelease];
}
- (NSString*)title { // Calls the dataSource method. If not implemented, returns nil.
	if ([self.dataSource respondsToSelector:gBarTitleSelector])
		return [self.dataSource titleForBar:self];
	return nil;
}
- (NSArray*)items {
	NSPredicate *p = [NSPredicate predicateWithFormat:@"className == %@", [NSButton className]];
	return [self.subviews filteredArrayUsingPredicate:p];
}
- (BOOL)shouldSelectItemAtIndex:(NSInteger)idx {
	if ([self.delegate respondsToSelector:gShouldSelectItemSelector])
		return [self.delegate shouldSelectItemInScopeBar:self 
												 atIndex:idx];
	return YES;
}
- (void)didSelectItem:(NSButton*)item {
	if ([self.delegate respondsToSelector:gDidSelectItemSelector])
		[self.delegate didSelectItemInScopeBar:self 
									   atIndex:[self indexOfItem:item] 
									   withTag:item.tag 
									  andTitle:item.title];
}
#pragma mark -
#pragma mark Accessors
- (NSInteger)indexOfItem:(id)item {
	NSInteger idx = [self.items indexOfObject:item];
	if (idx >= 0 && idx != NSNotFound)
		return idx;
	idx=[overflowButton indexOfItem:item]+1;
	if (idx >= 0 && idx!=NSNotFound) {
		idx+=self.cutoffIndex;
		return idx;
	}
	return NSNotFound;
}
- (NSInteger)selectedIndex {
	NSArray *i = self.items;
	return [i indexOfObject:self.selectedItem];
}
- (void)setSelectedIndex:(NSInteger)idx {
	[self setSelectedItem:[self.items objectAtIndex:idx]];
}
- (void)setSelectedItem:(id)newItem {
	if (newItem!=overflowButton) {
		if (self.selectedItem==newItem) {
			[newItem setState:NSOnState];
			return;
		}
		if (!newItem)
			return;
		
		NSInteger idx = [self indexOfItem:newItem];
		if (idx < 0 || idx == NSNotFound)
			return;
		if ([self shouldSelectItemAtIndex:idx]) {
			[self willChangeValueForKey:@"selectedItem"];
			[selectedItem setState:NSOffState];
			selectedItem=newItem;
			[selectedItem setState:NSOnState];
			[self didChangeValueForKey:@"selectedItem"];
			[self didSelectItem:newItem];
			
		} else {
			[newItem setState:NSOffState];
		}
	} else {
		NSMenuItem *n = [(NSPopUpButton*)newItem selectedItem];
		if (self.selectedItem==n) {
			[n setState:NSOnState];
			return;
		}
		NSInteger idx = [self indexOfItem:n];
		if (idx <0 || idx==NSNotFound)
			return;
		if ([self shouldSelectItemAtIndex:idx]) {
			[self willChangeValueForKey:@"selectedItem"];
			[selectedItem setState:NSOffState];
			selectedItem=n;
			[selectedItem setState:NSOnState];
			[self didChangeValueForKey:@"selectedItem"];
			[self didSelectItem:n];
		} else {
			[n setState:NSOffState];
		}
	}
	if ([overflowButton selectedItem]!=nil)
		[overflowButton setState:NSOnState];
}
@end

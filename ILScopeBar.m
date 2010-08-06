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
#define gItemTitlePadding gItemSpacing+6
#define gItemSpacing 10


#define gItemCountSelector @selector(numberOfItemsInScopeBar:)
#define gItemTitleSelector @selector(titleOfItemInScopeBar:atIndex:)

#define gBarTitleSelector @selector(titleForBar:)
#define gItemTagSelector @selector(tagForItemInScopeBar:atIndex:)
#define gItemImageSelector @selector(imageForItemInScopeBar:atIndex:)

#define gShouldSelectItemSelector @selector(shouldSelectItemInScopeBar:atIndex:)
#define gDidSelectItemSelector @selector(didSelectItemInScopeBar:atIndex:withTag:andTitle:)

#define gDidClickPlusButtonSelector @selector(didClickPlusButtonInScopeBar:)
#define gDidClickMinusButtonSelector @selector(didClickMinusButtonInScopeBar:)

#define gPlusMinusWidth 55
#define gPlusMinusHeight 20
#define gPlusMinusPad (gPlusMinusWidth+gItemSpacing)
#define gPlusMinusOrigin (NSMaxX(self.bounds)-gPlusMinusPad)

@interface ILScopeBar (Private)

- (BOOL)shouldSelectItemAtIndex:(NSInteger)idx;
- (void)didSelectItem:(id)item;

- (NSButton*)itemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;
- (void)addItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;
- (NSMenuItem*)menuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;
- (void)addMenuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index;

- (BOOL)overflows;
- (NSRect)frameForOverflowButton;
- (NSRect)frameForPlusMinus;

- (void)didClickMinusButton;
- (void)didClickPlusButton;
- (void)buttonAction:(id)sender;
@end


@implementation ILScopeBar

@synthesize dataSource, selectedItem, delegate, cutoffIndex, overflowButton;
@dynamic selectedIndex;

- (void)awakeFromNib {
}
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[[NSImage imageNamed:@"Arrows"] setTemplate:YES];
		[self showPlusMinus];
    }
    return self;
}
- (void)dealloc {
	if (plusMinus) {
		[plusMinus removeFromSuperview];
		[plusMinus release];
		plusMinus=nil;
	}
	if (overflowButton) {
		[overflowButton removeFromSuperview];
		[overflowButton release];
		overflowButton=nil;
	}
	if (titleCell) {
		[titleCell release];
		titleCell=nil;
	}
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
		// Drawing code here.
	[gGradient drawInRect:self.bounds angle:270];
	[gBorderColor set];
	NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
	
		// Probably not the best idea to create it on every draw call
	[titleCell drawWithFrame:self.frameForBarTitle inView:self];
	
	if (self.inLiveResize) {
		[self rearrangeItems];
	}
	[self showPlusMinus];
}
#pragma mark -
#pragma mark Creating and Adding Items
- (void)rearrangeItems {
	[self createOverflowButton];
	
	BOOL overflows = self.overflows;
	NSInteger cutoff = self.cutoffIndex;
	NSInteger se=self.selectedIndex;
	NSArray *items = self.items;
	NSMenu *overflowMenu = overflowButton.menu;
	NSInteger itemCount = self.itemCount;

	for (int x=0;x<itemCount;x++) {
		id item = nil;
		if (itemCount>0&&x<items.count) {
			item=[items objectAtIndex:x];
		}
		if (item) {
			if (x>cutoff&&![item isKindOfClass:[NSMenuItem class]]&&overflows) {
				[item removeFromSuperview];
				[self addMenuItemWithTitle:[self titleOfItemAtIndex:x] 
									   tag:[self tagForItemAtIndex:x] 
									 image:[self imageForItemAtIndex:x] 
								  forIndex:x];
			} else if (x<=cutoff&&![item isKindOfClass:[NSButton class]]) {
				[overflowMenu removeItem:item];
				[self addItemWithTitle:[self titleOfItemAtIndex:x] 
								   tag:[self tagForItemAtIndex:x] 
								 image:[self imageForItemAtIndex:x]
							  forIndex:x];
			}
			if ([item isKindOfClass:[NSButton class]]) {
				[item setFrame:[self frameForItemAtIndex:x]];
			}
			
		} else {
			if (x>cutoff)
				[self addMenuItemWithTitle:[self titleOfItemAtIndex:x] 
									   tag:[self tagForItemAtIndex:x] 
									 image:[self imageForItemAtIndex:x] 
								  forIndex:x];
			else
				[self addItemWithTitle:[self titleOfItemAtIndex:x] 
								   tag:[self tagForItemAtIndex:x] 
								 image:[self imageForItemAtIndex:x]
							  forIndex:x];
		}

	}
	
	if (overflowMenu.numberOfItems>0) {
		[[overflowMenu itemAtIndex:0] setState:NSOffState];
	}
	
	if (se>=0&&se!=NSNotFound&&se<=self.itemCount)
		[self setSelectedIndex:se];
	
	[overflowButton setHidden:(overflowButton.menu.numberOfItems<=0)];
}
- (void)reload {
	for (int x = self.subviews.count-1;x>=0;x--) {
		[[self.subviews objectAtIndex:x] removeFromSuperview];
	}
	if (overflowButton)
		[overflowButton removeAllItems];
	
	[self createOverflowButton];
	[self rearrangeItems];
	
	if (titleCell)
		[titleCell release], titleCell=nil;
	
	titleCell = [[NSTextFieldCell alloc] init];
	[titleCell setAttributedStringValue:self.attributedTitle];
	[titleCell setBackgroundStyle:NSBackgroundStyleRaised];
	NSArray *items = self.items;
	if (![items containsObject:selectedItem]&&items.count>0) {
		self.selectedItem=[self.items objectAtIndex:0];
	} else {
		self.selectedItem=nil;
	}

	
	[self setNeedsDisplay:YES];
}
- (void)createOverflowButton {
		// it probably actually isnt the best idea to release and create the overflow button so frequently. And instead i should use removeAllItems. Maybe later?
		//if (overflowButton)
		//[overflowButton removeFromSuperview], [overflowButton release], overflowButton=nil;
	//[overflowButton setFrame:[self frameForOverflowButton]];
	[self overflows];
	if (!overflowButton) {
		overflowButton=[[NSPopUpButton alloc] initWithFrame:NSMakeRect(NSMaxX(self.bounds)-28-gItemSpacing, roundf(NSMidY(self.bounds)-19/2), 28, 19)];		
		[overflowButton setButtonType:NSMomentaryLightButton];
		[overflowButton setBezelStyle:NSRecessedBezelStyle];
		[overflowButton setAutoresizingMask:NSViewMinXMargin|NSViewMaxYMargin|NSViewMinYMargin|NSViewMaxYMargin];

		[overflowButton setShowsBorderOnlyWhileMouseInside:YES];
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
		
			//		[self addSubview:overflowButton];
	}
	if (![self.subviews containsObject:overflowButton])
		[self addSubview:overflowButton];
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
		//[nb setAutoresizingMask:NSViewMaxYMargin|NSViewMinYMargin|NSViewMaxXMargin];
	return [nb autorelease];
}
- (void)addItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index {
	[self addSubview:[self itemWithTitle:title tag:tag image:img forIndex:index]];
}
- (NSMenuItem*)menuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index {
	NSMenuItem *item = [NSMenuItem new];
	
	[item setTitle:title];
	[item setTag:tag];
	[item setImage:img];
	[item setState:NSOffState];
	
		// proportionately (sp?) set the height of the item's image to 16.
	
	NSSize imgSize = NSMakeSize(0, 16);
	CGFloat wpec = img.size.height/16;
	imgSize.width=img.size.width/wpec;
	[item.image setSize:imgSize];
	
	return [item autorelease];
}
- (void)addMenuItemWithTitle:(NSString*)title tag:(NSInteger)tag image:(NSImage*)img forIndex:(NSInteger)index {
	NSMenuItem *item = [self menuItemWithTitle:title tag:tag image:img forIndex:index];
	[overflowButton.menu insertItem:item atIndex:index-cutoffIndex-1];
	[item setState:NSOffState];
}

#pragma mark -
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
		titleSize.width+=itemImage.size.width+gItemTitlePadding-gItemSpacing;
	
	n.size.width=titleSize.width;
	n.size.width+=gItemTitlePadding;
	return n;
}
- (NSRect)frameForBarTitle {
	NSString *title = self.title;
	if (!title || title.length<=0)
		return NSMakeRect(gItemSpacing, 0, 0, 0);
	NSSize titleSize=[self.attributedTitle size];
	NSRect t = NSZeroRect;
	t.origin.x=gItemSpacing;
	t.size.width=titleSize.width+gItemTitlePadding*2;
	t.size.height=titleSize.height;
	t.origin.y=roundf(NSMidY(self.bounds)-t.size.height/2);
	
	if (t.size.width+t.origin.x>self.bounds.size.width-gItemSpacing*2) {
		t.size.width=self.bounds.size.width-gItemSpacing*2;
		if (![overflowButton isHidden] || !overflowButton) {
			t.size.width-=overflowButton.frame.size.width;
		}
	}
	
	return t;
}
- (NSRect)frameForOverflowButton {
	NSRect orig = NSMakeRect(NSMaxX(self.bounds)-28-gItemSpacing, roundf(NSMidY(self.bounds)-19/2), 28, 19);
	if (showPlusMinus)
		orig.origin.x-=gPlusMinusPad;
	return orig;
}
- (NSRect)frameForPlusMinus {
	return NSMakeRect(gPlusMinusOrigin, roundf(NSMidY(self.bounds)-gPlusMinusHeight/2), gPlusMinusWidth, gPlusMinusHeight);
}
- (BOOL)overflows {
	[self willChangeValueForKey:@"cutoffIndex"];
	for (int x = 0; x<self.itemCount;x++) {
		NSRect f = [self frameForItemAtIndex:x];
		float ovrpadding = self.bounds.size.width-overflowButton.frame.origin.x;
		if (f.origin.x+f.size.width+ovrpadding>self.bounds.size.width) {
			cutoffIndex=x-1;
			[self didChangeValueForKey:@"cutoffIndex"];
			return YES;
		}
	}
	cutoffIndex=self.itemCount-1;
	[self didChangeValueForKey:@"cutoffIndex"];
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
	
	if ([self.dataSource respondsToSelector:gItemImageSelector]) {
		NSImage *im = [self.dataSource imageForItemInScopeBar:self atIndex:idx];
		if (im)
			[im setSize:NSMakeSize(16, 16)];
		return im;
	}
	return nil;
}
- (NSInteger)tagForItemAtIndex:(NSInteger)idx { // Calls the dataSource method. If not implemented, returns 0.
	if ([self.dataSource respondsToSelector:gItemTagSelector])
		return [self.dataSource tagForItemInScopeBar:self atIndex:idx];
	return 0;
}
- (NSAttributedString*)attributedTitle {
	if (self.title) {
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		[style setLineBreakMode:NSLineBreakByTruncatingTail];
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:self.title 
																	attributes:[NSDictionary dictionaryWithObjectsAndKeys:gTitleFont, NSFontAttributeName, gTitleColor, NSForegroundColorAttributeName, 
																				style, NSParagraphStyleAttributeName, nil]];
		[style release];
		return [title autorelease];
	}
	return nil;
}
- (NSString*)title { // Calls the dataSource method. If not implemented, returns nil.
	if ([self.dataSource respondsToSelector:gBarTitleSelector])
		return [self.dataSource titleForBar:self];
	return nil;
}
- (NSArray*)items {
	NSPredicate *p = [NSPredicate predicateWithFormat:@"className == %@", [NSButton className]];
	return [[self.subviews filteredArrayUsingPredicate:p] arrayByAddingObjectsFromArray:overflowButton.menu.itemArray];
}
- (BOOL)shouldSelectItemAtIndex:(NSInteger)idx {
	if ([self.delegate respondsToSelector:gShouldSelectItemSelector])
		return [self.delegate shouldSelectItemInScopeBar:self 
												 atIndex:idx];
	return YES;
}
- (void)didSelectItem:(NSButton*)item {
	if ([self.delegate respondsToSelector:gDidSelectItemSelector]) {
		NSInteger idx = -1;
		NSInteger tag = -1;
		NSString *title = @"";
		if (item) {
			idx=[self indexOfItem:item];
			tag=item.tag;
			title=item.title;
		}
		[self.delegate didSelectItemInScopeBar:self 
									   atIndex:idx
									   withTag:tag
									  andTitle:title];
	}
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
		if (!newItem) {
			[self willChangeValueForKey:@"selectedItem"];
			[self willChangeValueForKey:@"selectedIndex"];
			selectedItem=nil;
			[self didSelectItem:nil];
			[self didChangeValueForKey:@"selectedItem"];
			[self didChangeValueForKey:@"selectedIndex"];
			return;
		}
		NSInteger idx = [self indexOfItem:newItem];
		if (idx < 0 || idx == NSNotFound)
			return;
		if ([self shouldSelectItemAtIndex:idx]) {
			[self willChangeValueForKey:@"selectedItem"];
			[self willChangeValueForKey:@"selectedIndex"];
			if ([self.items containsObject:selectedItem])
				[selectedItem setState:NSOffState];
			selectedItem=newItem;
			[selectedItem setState:NSOnState];
			[self didChangeValueForKey:@"selectedItem"];
			[self didChangeValueForKey:@"selectedIndex"];
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
			[self willChangeValueForKey:@"selectedIndex"];
			[selectedItem setState:NSOffState];
			selectedItem=n;
			[selectedItem setState:NSOnState];
			[self didChangeValueForKey:@"selectedItem"];
			[self didChangeValueForKey:@"selectedIndex"];
			[self didSelectItem:n];
		} else {
			[n setState:NSOffState];
		}
	}
	if ([overflowButton selectedItem]!=nil)
		[overflowButton setState:NSOnState];
}
#pragma mark -
#pragma mark Buttons
- (void)createPlusMinus {
	if (plusMinus)
		return;
	plusMinus=[[NSSegmentedControl alloc] initWithFrame:[self frameForPlusMinus]];
	[plusMinus setSegmentCount:2];
	[plusMinus setImage:[NSImage imageNamed:@"NSAddTemplate"] forSegment:0];
	[plusMinus setImage:[NSImage imageNamed:@"NSRemoveTemplate"] forSegment:1];
	[plusMinus setSelectedSegment:1];
	[plusMinus setSegmentStyle:NSSegmentStyleRoundRect];
	
	[plusMinus setAutoresizingMask:NSViewMinXMargin|NSViewMaxYMargin|NSViewMinYMargin|NSViewMaxYMargin];
	
	[plusMinus.cell setTag:0 forSegment:0];
	[plusMinus.cell setTag:1 forSegment:1];
	[plusMinus.cell setTrackingMode:NSSegmentSwitchTrackingMomentary];
	
	[plusMinus setTarget:self];
	[plusMinus setAction:@selector(buttonAction:)];
	
}
- (void)showPlusMinus {
	[self createPlusMinus];
	if (![self.subviews containsObject:plusMinus])
		[self addSubview:plusMinus];
	[self setNeedsDisplay:YES];
	showPlusMinus=YES;
	[overflowButton setFrame:[self frameForOverflowButton]];
}
- (void)hidePlusMinus {
	if ([self.subviews containsObject:plusMinus])
		[plusMinus removeFromSuperview];
	[self setNeedsDisplay:YES];
	showPlusMinus=NO;
	[overflowButton setFrame:[self frameForOverflowButton]];
}
- (void)didClickMinusButton {
	if ([self.delegate respondsToSelector:gDidClickMinusButtonSelector]) {
		[self.delegate didClickMinusButtonInScopeBar:self];
	}
}
- (void)didClickPlusButton {
	if ([self.delegate respondsToSelector:gDidClickPlusButtonSelector]) {
		[self.delegate didClickPlusButtonInScopeBar:self];
	}
}
- (void)buttonAction:(id)sender {
	if (sender==plusMinus) {
		switch ([plusMinus selectedSegment]) {
			case 0:
				[self didClickPlusButton];
				break;
			case 1:
				[self didClickMinusButton];
				break;
			default:
				break;
		}
	}
}

@end

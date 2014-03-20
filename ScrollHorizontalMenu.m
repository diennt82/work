//
//  ScrollHorizontalMenu.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 14/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "ScrollHorizontalMenu.h"
#import "define.h"

#define kButtonBaseTag 10000
#define kLeftOffset 40
#define kLeftOffset_iPhone 8
#define kButtonSize 40
#define kPaddingBetweenButton 30
#define kButtonSize_iPhone 36
@implementation ScrollHorizontalMenu

@synthesize imageMenu = _imageMenu;
@synthesize selectedImage = _selectedImage;
@synthesize itemSelectedDelegate;
@synthesize dataSource;
@synthesize itemCount = _itemCount;
@synthesize lastItemSelected = _lastItemSelected;

-(void) awakeFromNib
{
    self.bounces = YES;
    self.scrollEnabled = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [self reloadData:NO];
}

-(void) reloadData:(BOOL)isLand
{
    NSArray *viewsToRemove = [self subviews];
	for (UIView *v in viewsToRemove) {
		[v removeFromSuperview];
	}
    self.scrollEnabled = NO;
    self.itemCount = [dataSource numberOfItemsForMenu:self];
//    self.backgroundColor = [dataSource backgroundColorForMenu:self];
    int tag = kButtonBaseTag;
    int xPos, marginLR;
    int buttonWidth;
    NSInteger paddingBetweenButton;
    
    if (isLand)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            marginLR = kLeftOffset + 60; //padding left and right = 100
            xPos = 0; //
            buttonWidth = 60; //60 for iPad
            paddingBetweenButton = 65;
        }
        else if (isiPhone4)
        {
            marginLR = 0;
            xPos = 0;
            buttonWidth = kButtonSize_iPhone - 2;
            paddingBetweenButton = kPaddingBetweenButton - 6;
        }
        else
        {
            marginLR = 0;
            xPos = 0;
            buttonWidth = kButtonSize_iPhone;
            paddingBetweenButton = kPaddingBetweenButton - 5;
        }
        
    } else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            marginLR = 100; //padding left and right = 100
            xPos = 30; //
            buttonWidth = 60; //60 for iPad
            paddingBetweenButton = 50;
        }
        else
        {
            marginLR = kLeftOffset_iPhone;
            xPos = kLeftOffset_iPhone;
            buttonWidth = kButtonSize_iPhone;
            paddingBetweenButton = kPaddingBetweenButton;
        }
    }
    
    // This is SharedCam, the menu has 4 items
    if (_itemCount == 4)
    {
        // Make items is center menu.
        xPos += buttonWidth;
    }
    
    for(int i = 0 ; i < self.itemCount; i++)
    {
        NSString *imageName = [dataSource horizMenu:self nameImageForItemAtIndex:i];
        NSString *imageSelected = [dataSource horizMenu:self nameImageSelectedForItemAtIndex:i];
        
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [customButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [customButton setBackgroundImage:[UIImage imageNamed:imageSelected] forState:UIControlStateSelected];
        
        customButton.tag = tag++;
        [customButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        customButton.frame = CGRectMake(xPos, 0, buttonWidth, buttonWidth);
        
        xPos += buttonWidth;
        xPos += paddingBetweenButton;
        [self addSubview:customButton];
    }
    
    xPos += marginLR;
    
    self.contentSize = CGSizeMake(xPos, buttonWidth);
    [self layoutSubviews];
}

-(void) setSelectedIndex:(int) index animated:(BOOL) animated
{
    UIButton *thisButton = (UIButton*) [self viewWithTag:index + kButtonBaseTag];
    thisButton.selected = YES;
    [self setContentOffset:CGPointMake(thisButton.frame.origin.x - kLeftOffset, 0) animated:animated];
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:index];
}

-(void) buttonTapped:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    for(int i = 0; i < self.itemCount; i++)
    {
        NSLog(@"i = %i", i);
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        
        if(i + kButtonBaseTag == button.tag)
        {
            if (_lastItemSelected == thisButton)
            {
                [self clearButtons];
                _lastItemSelected = NULL;
                
                [self.itemSelectedDelegate clearHorizonMenu];
                
                return;
            }
            
            thisButton.selected = YES;
            _lastItemSelected = thisButton;
        }
        else
        {
            thisButton.selected = NO;
        }
    }
    
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
}

- (void) clearButtons
{
    for(int i = 0; i < self.itemCount; i++)
    {
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        
        thisButton.selected = NO;
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	NSLog(@"abc");
}

- (void)dealloc
{
    [_selectedImage release];
    _selectedImage = nil;
    [_imageMenu release];
    _imageMenu = nil;
    
    [super dealloc];
}
@end

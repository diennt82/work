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

#define ITEMS_MAX 5

@implementation ScrollHorizontalMenu

@synthesize imageMenu = _imageMenu;
@synthesize selectedImage = _selectedImage;
@synthesize itemSelectedDelegate;
@synthesize dataSource;
@synthesize itemCount = _itemCount;
@synthesize isAllButtonDeselected = _isAllButtonDeselected;

-(void) awakeFromNib
{
    currentTappedButtonIndex = -1;
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
            buttonWidth = 60; //60 for iPad
            paddingBetweenButton = 65;
            xPos = 218;
        }
        else if (isiPhone4)
        {
            marginLR = 0;
            buttonWidth = kButtonSize_iPhone - 2;
            paddingBetweenButton = kPaddingBetweenButton - 6;
            xPos = 101;
        }
        else
        {
            marginLR = 0;
            buttonWidth = kButtonSize_iPhone;
            paddingBetweenButton = kPaddingBetweenButton - 5;
            xPos = 145;
        }
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            marginLR = 0; //padding left and right = 100
            xPos = 130; //
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
    
    /*!
     * 1. This is CameraHD with fully feature, the menu has 5 items.
     * 2. This is SharedCam, the menu has 4 items
     * 3. This is SharedCam and this shared cam is connected via MACOS, the menu has 2 items
     * 4. This is remote viewing, the menu maybe has 3 items
     */
    
    xPos += (ITEMS_MAX - _itemCount) * buttonWidth;
    
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
    //[self setContentOffset:CGPointMake(thisButton.frame.origin.x - kLeftOffset, 0) animated:animated];
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:index];
}

-(void) buttonTapped:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    for(int i = 0; i < self.itemCount; i++)
    {
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        
        if(i + kButtonBaseTag == button.tag)
        {
            _isOddTapButton = !_isOddTapButton;
            //select one button
            if (currentTappedButtonIndex == i)
            {
                //select continue;
                if (_isOddTapButton)
                {
                    thisButton.selected = YES;
                    _isAllButtonDeselected = NO;
                }
                else
                {
                    _isAllButtonDeselected = YES;
                    thisButton.selected = NO;
                }
                
            } else
            {
                _isAllButtonDeselected = NO;
                _isOddTapButton = YES;
                thisButton.selected = YES;
            }
            currentTappedButtonIndex = i;
        }
        else
        {
            thisButton.selected = NO;
        }
    }
    
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
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

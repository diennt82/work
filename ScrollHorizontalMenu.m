//
//  ScrollHorizontalMenu.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 14/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
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

@interface ScrollHorizontalMenu ()

@property (nonatomic) BOOL isOddTapButton;
@property (nonatomic) NSInteger currentTappedButtonIndex;

@end

@implementation ScrollHorizontalMenu

-(void) awakeFromNib
{
    self.currentTappedButtonIndex = -1;
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
    self.itemCount = [_dataSource numberOfItemsForMenu:self];
    
    int tag = kButtonBaseTag;
    int xPos, marginLR;
    int buttonWidth;
    NSInteger paddingBetweenButton;
    
    if (isLand) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            marginLR = kLeftOffset + 60; //padding left and right = 100
            buttonWidth = 60; //60 for iPad
            paddingBetweenButton = 65;
        }
        else if (isiPhone4) {
            marginLR = 0;
            buttonWidth = kButtonSize_iPhone - 2;
            paddingBetweenButton = kPaddingBetweenButton - 6;
        }
        else {
            marginLR = 0;
            buttonWidth = kButtonSize_iPhone;
            paddingBetweenButton = kPaddingBetweenButton - 5;
        }
        
        xPos = 0;
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            marginLR = 100; //padding left and right = 100
            xPos = 30; //
            buttonWidth = 60; //60 for iPad
            paddingBetweenButton = 50;
        }
        else {
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
    
    for(int i = 0 ; i < _itemCount; i++) {
        NSString *imageName = [_dataSource horizMenu:self nameImageForItemAtIndex:i];
        NSString *imageSelected = [_dataSource horizMenu:self nameImageSelectedForItemAtIndex:i];
        
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

- (void)setSelectedIndex:(int)index animated:(BOOL)animated
{
    UIButton *thisButton = (UIButton *)[self viewWithTag:index + kButtonBaseTag];
    thisButton.selected = YES;
    [_itemSelectedDelegate horizMenu:self itemSelectedAtIndex:index];
}

- (void)buttonTapped:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    for(int i = 0; i < _itemCount; i++) {
        UIButton *thisButton = (UIButton *)[self viewWithTag:i + kButtonBaseTag];
        
        if(i + kButtonBaseTag == button.tag) {
            self.isOddTapButton = !_isOddTapButton;
            
            //select one button
            if (_currentTappedButtonIndex == i) {
                //select continue;
                if (_isOddTapButton) {
                    thisButton.selected = YES;
                    self.isAllButtonDeselected = NO;
                }
                else {
                    self.isAllButtonDeselected = YES;
                    thisButton.selected = NO;
                }
                
            }
            else {
                self.isAllButtonDeselected = NO;
                self.isOddTapButton = YES;
                thisButton.selected = YES;
            }
            self.currentTappedButtonIndex = i;
        }
        else {
            thisButton.selected = NO;
        }
    }
    
    [_itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
}

@end

//
//  ScrollHorizontalMenu.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 14/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "ScrollHorizontalMenu.h"

#define kButtonBaseTag 10000
#define kLeftOffset 10
#define kButtonSize 41
#define kPaddingBetweenButton 40

@implementation ScrollHorizontalMenu

@synthesize imageMenu = _imageMenu;

@synthesize itemSelectedDelegate;
@synthesize dataSource;
@synthesize itemCount = _itemCount;

-(void) awakeFromNib
{
    self.bounces = YES;
    self.scrollEnabled = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [self reloadData];
}

-(void) reloadData
{
    NSArray *viewsToRemove = [self subviews];
	for (UIView *v in viewsToRemove) {
		[v removeFromSuperview];
	}
    
    self.itemCount = [dataSource numberOfItemsForMenu:self];
    self.backgroundColor = [dataSource backgroundColorForMenu:self];
//    self.selectedImage = [dataSource selectedItemImageForMenu:self];
    
    int tag = kButtonBaseTag;
    int xPos = kLeftOffset;
    
    for(int i = 0 ; i < self.itemCount; i ++)
    {
        NSString *imageName = [dataSource horizMenu:self nameImageForItemAtIndex:i];
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [customButton setBackgroundImage:self.selectedImage forState:UIControlStateSelected];
        
        customButton.tag = tag++;
        [customButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        int buttonWidth = kButtonSize;
        [customButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        customButton.frame = CGRectMake(xPos, 0, buttonWidth, buttonWidth);
        xPos += buttonWidth;
        xPos += kPaddingBetweenButton;
        [self addSubview:customButton];
    }
    xPos += kLeftOffset;
    
    self.contentSize = CGSizeMake(xPos, 41);
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
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        if(i + kButtonBaseTag == button.tag)
            thisButton.selected = YES;
        else
            thisButton.selected = NO;
    }
    
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
}


- (void)dealloc
{
    [_imageMenu release];
    _imageMenu = nil;
    
    [super dealloc];
}
@end

//
//  ScrollHorizontalMenu.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 14/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollHorizontalMenu;

@protocol ScrollHorizontalMenuDataSource <NSObject>

@required
- (UIImage *)selectedItemImageForMenu:(ScrollHorizontalMenu *)tabMenu withIndexItem:(NSInteger)index;
- (UIColor *)backgroundColorForMenu:(ScrollHorizontalMenu*)tabView;
- (int)numberOfItemsForMenu:(ScrollHorizontalMenu *)tabView;

- (NSString *)horizMenu:(ScrollHorizontalMenu *)horizMenu titleForItemAtIndex:(NSUInteger)index;
- (NSString*)horizMenu:(ScrollHorizontalMenu *)horizMenu nameImageForItemAtIndex:(NSUInteger)index;
- (NSString*)horizMenu:(ScrollHorizontalMenu *)horizMenu nameImageSelectedForItemAtIndex:(NSUInteger)index;

@end

@protocol ScrollHorizontalMenuDelegate <NSObject>

@required

- (void)horizMenu:(ScrollHorizontalMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index;

@end

@interface ScrollHorizontalMenu : UIScrollView

@property (nonatomic, weak) IBOutlet id <ScrollHorizontalMenuDelegate> itemSelectedDelegate;
@property (nonatomic, weak) IBOutlet id <ScrollHorizontalMenuDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *imageMenu;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, assign) int itemCount;
@property (nonatomic, assign) BOOL isAllButtonDeselected;

- (void)reloadData:(BOOL)isLand;
- (void)setSelectedIndex:(int)index animated:(BOOL)animated;

@end

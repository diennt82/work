//
//  ScrollHorizontalMenu.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 14/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScrollHorizontalMenu;

@protocol ScrollHorizontalMenuDataSource <NSObject>
@required
- (UIImage *) selectedItemImageForMenu:(ScrollHorizontalMenu *) tabMenu withIndexItem:(NSInteger)index;
- (UIColor *) backgroundColorForMenu:(ScrollHorizontalMenu*) tabView;
- (int) numberOfItemsForMenu:(ScrollHorizontalMenu *) tabView;

- (NSString *) horizMenu:(ScrollHorizontalMenu *) horizMenu titleForItemAtIndex:(NSUInteger) index;
- (NSString*) horizMenu:(ScrollHorizontalMenu *)horizMenu nameImageForItemAtIndex:(NSUInteger)index;
- (NSString*) horizMenu:(ScrollHorizontalMenu *)horizMenu nameImageSelectedForItemAtIndex:(NSUInteger)index;
@end

@protocol ScrollHorizontalMenuDelegate <NSObject>
@required
- (void)horizMenu:(ScrollHorizontalMenu *) horizMenu itemSelectedAtIndex:(NSUInteger) index;
@end

@interface ScrollHorizontalMenu : UIScrollView {
    
    int _itemCount;
    UIImage *_selectedImage;
    //image for menu scroll
    NSMutableArray *_imageMenu;
    id <ScrollHorizontalMenuDataSource> dataSource;
    id <ScrollHorizontalMenuDelegate> itemSelectedDelegate;
}
@property (nonatomic, retain) NSMutableArray *imageMenu;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, assign) IBOutlet id <ScrollHorizontalMenuDelegate> itemSelectedDelegate;
@property (nonatomic, retain) IBOutlet id <ScrollHorizontalMenuDataSource> dataSource;
@property (nonatomic, assign) int itemCount;

-(void) reloadData:(BOOL)isLand;
-(void) setSelectedIndex:(int) index animated:(BOOL) animated;
@end

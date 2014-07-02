//
//  CameraItemView.h
//  BlinkHD_ios
//
//  Created by Developer on 1/7/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Camera.h"

#define ITEM_WIDTH      110
#define ITEM_HEIGHT     145

@protocol CameraItemViewDelegate <NSObject>
- (void)selectedItem:(CAMERA_TAG)cameraTad;
@end

@interface CameraItemView : UIView
@property (nonatomic, retain) IBOutlet UIButton     *itemButton;
@property (nonatomic, retain) IBOutlet UILabel      *itemLable;
@property (nonatomic, assign) id<CameraItemViewDelegate>    delegate;

- (id)initWithConorLeftLocation:(CGPoint)location;
- (void)setCamera:(Camera *)camera;
- (IBAction)handlerItemButton:(id)sender;
@end

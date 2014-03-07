//
//  AddCameraViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 3/6/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCameraVCDelegate <NSObject>

- (void)sendActionCommand: (BOOL)flag;

@end

@interface AddCameraViewController : UIViewController

@property (nonatomic, assign) id<AddCameraVCDelegate> delegate;

@end

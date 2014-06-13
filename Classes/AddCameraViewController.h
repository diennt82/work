//
//  AddCameraViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 3/6/14.
//  Copyright (c) 2014 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCameraVCDelegate <NSObject>

- (void)continueWithAddCameraAction;

@end

@interface AddCameraViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *buyCameraButton;
@property (nonatomic, assign) id<AddCameraVCDelegate>delegate;

- (IBAction)buyCameraButtonAction:(id)sender;

@end

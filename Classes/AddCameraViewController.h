//
//  AddCameraViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 3/6/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCameraVCDelegate <NSObject>

- (void)continueWithAddCameraAction;

@end

@interface AddCameraViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *buyCameraButton;
@property (nonatomic, weak) id<AddCameraVCDelegate>delegate;

- (IBAction)buyCameraButtonAction:(id)sender;

@end

//
//  AddCameraViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 3/6/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "AddCameraViewController.h"
#import "define.h"
#import "PublicDefine.h"

@interface AddCameraViewController ()

@property (nonatomic, retain) IBOutlet UIButton *btnCancel;

@end

@implementation AddCameraViewController

#define MAX_CAM_ALLOWED 4
#define CAMERA_TAG_66 566
#define CAMERA_TAG_83 583 //83/ 836

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_btnCancel setBackgroundImage:[UIImage imageNamed:@"cancel_btn"] forState:UIControlStateNormal];
    [_btnCancel setBackgroundImage:[UIImage imageNamed:@"cancel_btn_pressed"] forState:UIControlEventTouchDown];
    
    _buyCameraButton.layer.cornerRadius = 5.0f; // set to match the L&F of the Cancel button
    _buyCameraButton.clipsToBounds = YES;
}

#pragma mark - Custom Actions

- (IBAction)btnCameraTypeTouchUpInsideAction:(UIButton *)sender
{
    NSInteger cameraType = WIFI_SETUP;
    
    if (sender.tag == CAMERA_TAG_83) {
        //MBP 83/ 836
        cameraType = BLUETOOTH_SETUP;
    }
    else {
        // Focus 66
        cameraType = WIFI_SETUP;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:cameraType forKey:SET_UP_CAMERA];
    [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [_delegate continueWithAddCameraAction];
    }];
}

- (IBAction)btnCancelTouchUpInsideAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buyCameraButtonAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hubblehome.com/hubble-products/"]];
}

#pragma mark - Methods

- (void)showDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:LocStr(@"remove_one_cam")
                                                   delegate:nil
                                          cancelButtonTitle:LocStr(@"Ok")
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)dealloc
{
    [_btnCancel release];
    [super dealloc];
}

@end

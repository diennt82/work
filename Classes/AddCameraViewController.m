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


@property (weak, nonatomic) IBOutlet UILabel *getStartedLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *model66Label;
@property (weak, nonatomic) IBOutlet UILabel *otherModelsLabel;
@property (nonatomic, weak) IBOutlet UIButton *buyCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

@end

@implementation AddCameraViewController

#define CAMERA_TAG_66 566
#define CAMERA_TAG_83 583 //83/ 836

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _getStartedLabel.text = LocStr(@"Get started");
    _instructionLabel.text = LocStr(@"Select your camera to begin the setup process.");
    _model66Label.text = LocStr(@"model 66");
    _otherModelsLabel.text = LocStr(@"All other cameras");
    [_buyCameraButton setTitle:LocStr(@"Buy camera") forState:UIControlStateNormal];
    [_cancelButton setTitle:LocStr(@"Cancel") forState:UIControlStateNormal];
    
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_btn"] forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_btn_pressed"] forState:UIControlEventTouchDown];
    
    _buyCameraButton.layer.cornerRadius = 5.0f; // set to match the L&F of the Cancel button
    _buyCameraButton.clipsToBounds = YES;
}

#pragma mark - Custom Actions

- (IBAction)btnCameraTypeTouchUpInsideAction:(UIButton *)sender
{
    NSInteger cameraType = WIFI_SETUP; // Default to Wi-Fi (Ex: Focus 66)
    
    if (sender.tag == CAMERA_TAG_83) {
        // MBP 83 / 836
        cameraType = BLUETOOTH_SETUP;
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hubbleconnected.com/hubble-products/"]];
}

@end

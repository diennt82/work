//
//  NotifViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "NotifViewController.h"

@interface NotifViewController ()

@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *playEnventBtn;
@property (retain, nonatomic) IBOutlet UIButton *goToCameraBtn;
@property (retain, nonatomic) IBOutlet UIButton *changeSettingsBtn;
@property (retain, nonatomic) IBOutlet UIButton *ignoreBtn;
@property (retain, nonatomic) IBOutlet UIButton *choosePlanBtn;
@property (retain, nonatomic) IBOutlet UIButton *learnMoreBtn;

@end

@implementation NotifViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.playEnventBtn setImage:[UIImage imageNamed:@"alert_play"] forState:UIControlStateNormal];
    [self.playEnventBtn setImage:[UIImage imageNamed:@"alert_play_pressed"] forState:UIControlEventTouchUpInside];
    
    [self layoutImageAndTextForButton:self.playEnventBtn];
    
    
    [self.goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera"] forState:UIControlStateNormal];
    [self.goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera_pressed"] forState:UIControlEventTouchUpInside];
    
    [self layoutImageAndTextForButton:self.goToCameraBtn];
    
    [self.changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings"] forState:UIControlStateNormal];
    [self.changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings_pressed"] forState:UIControlEventTouchUpInside];
    
    [self layoutImageAndTextForButton:self.changeSettingsBtn];
    
    [self.choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade"] forState:UIControlStateNormal];
    [self.choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade_pressed"] forState:UIControlEventTouchUpInside];
    
    [self layoutImageAndTextForButton:self.choosePlanBtn];
    
    [self.learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn"] forState:UIControlStateNormal];
    [self.learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn_pressed"] forState:UIControlEventTouchUpInside];
    
    [self layoutImageAndTextForButton:self.learnMoreBtn];
}

- (void)layoutImageAndTextForButton: (UIButton *)button
{
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.frame.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = button.titleLabel.frame.size;
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

- (IBAction)playEventTouchAction:(id)sender
{
    self.messageLabel.text = @"You do not have motion detected recording enabled. Please choose an option below";
    self.timeLabel.hidden = YES;
    self.playEnventBtn.hidden = YES;
    self.goToCameraBtn.hidden = YES;
    self.changeSettingsBtn.hidden = YES;
    
    self.choosePlanBtn.hidden = NO;
    self.learnMoreBtn.hidden = NO;
    
}

- (IBAction)goToCameraTouchAction:(id)sender
{
    if (sender == self.goToCameraBtn)
    {
        //[self.navigationController popToRootViewControllerAnimated:NO];
        
        // Will call dismiss eventually
        
        if (![self.presentedViewController isBeingDismissed]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_notifDelegate sendStatus:SCAN_BONJOUR_CAMERA];
            }];
        }
        
        
    }
}

- (IBAction)changeSettingsTouchAction:(id)sender
{
}

- (IBAction)choosePlanTouchAction:(id)sender
{
}

- (IBAction)leranMoreTouchAction:(id)sender
{
}

- (IBAction)ignoreTouchAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // Will call dismiss eventually
    
    if (![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [_notifDelegate sendStatus:SCAN_BONJOUR_CAMERA];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_playEnventBtn release];
    [_goToCameraBtn release];
    [_changeSettingsBtn release];
    [_ignoreBtn release];
    [_choosePlanBtn release];
    [_learnMoreBtn release];
    [_messageLabel release];
    [_timeLabel release];
    [super dealloc];
}
@end

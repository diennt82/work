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

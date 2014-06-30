//
//  AddCameraViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 3/6/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#define MAX_CAM_ALLOWED 4
#define CAMERA_TAG_66 566
#define CAMERA_TAG_83 583 //83/ 836

#import "AddCameraViewController.h"
#import "define.h"
#import "PublicDefine.h"

@interface AddCameraViewController ()

@property (retain, nonatomic) IBOutlet UIButton *btnCancel;

@end

@implementation AddCameraViewController

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
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"cancel_btn"] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"cancel_btn_pressed"] forState:UIControlEventTouchDown];
}

#pragma mark - Actions

- (IBAction)btnCameraTypeTouchUpInsideAction:(UIButton *)sender
{
    NSInteger cameraType = WIFI_SETUP;
    
    if (sender.tag == CAMERA_TAG_83)
    {
        //MBP 83/ 836
        cameraType = BLUETOOTH_SETUP;
    }
    else
    {
        // Focus 66
        cameraType = WIFI_SETUP;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:cameraType forKey:SET_UP_CAMERA];
    [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate sendActionCommand:TRUE];
        self.delegate = nil;
    }];
}

- (IBAction)btnCancelTouchUpInsideAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate sendActionCommand:FALSE];
        self.delegate = nil;
    }];
}

#pragma mark - Methods

- (void)showDialog
{
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    NSString * msg = NSLocalizedStringWithDefaultValue(@"remove_one_cam",nil, [NSBundle mainBundle],
                                                       @"Please remove one camera from the current  list before addding the new one", nil);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:msg
                          delegate:nil
                          cancelButtonTitle:ok
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnCancel release];
    [super dealloc];
}
@end

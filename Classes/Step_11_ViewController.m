//
//  Step_11_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_11_ViewController.h"
//#import "KISSMetricsAPI.h"
#import "define.h"
#import "PublicDefine.h"
#import "UIView+Custom.h"

#define GAI_CATEGORY    @"Step 11 view"
#import "Step_02_ViewController.h"

@interface Step_11_ViewController ()

@property (nonatomic, retain) IBOutlet UILabel *error_code;
@property (retain, nonatomic) IBOutlet UIButton *btnTestCamera;
@property (retain, nonatomic) IBOutlet UIButton *btnSetupWithWifi;

@end

@implementation Step_11_ViewController


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
    [self xibDefaultLocalization];
    self.navigationItem.hidesBackButton = YES;
    self.trackedViewName = GAI_CATEGORY;
    
    [self.btnTestCamera setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnTestCamera setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];

    if (_errorCode != nil)
    {
        [self.error_code setText:_errorCode];
    }
    else
    {
        self.error_code.hidden = YES;
    }
    
    //NSString *stringModel = @"";
    
    //NSInteger model = [[NSUserDefaults standardUserDefaults] integerForKey:SET_UP_CAMERA];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:SET_UP_CAMERA] == BLUETOOTH_SETUP)
    {
        [self.btnSetupWithWifi setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
        [self.btnSetupWithWifi setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
        self.btnSetupWithWifi.titleLabel.text = NSLocalizedString(@"Setup with WIFI", @"Setup with WIFI");
        self.btnSetupWithWifi.hidden = NO;
        
        self.btnTestCamera.titleLabel.text = NSLocalizedString(@"Re-try setup with Bluetooth", @"Re-try setup with Bluetooth");
        
        //stringModel = @"Mbp83";
    }
    else
    {
        //stringModel = @"Focus66";
        self.btnTestCamera.titleLabel.text = NSLocalizedString(@"Try Again", @"Try Again");
    }
    
//   NSString *fwVersion = [[NSUserDefaults standardUserDefaults] stringForKey:FW_VERSION];
//   NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
//                         stringModel,   @"Camera model",
//                         fwVersion,     @"FW",
//                          _errorCode,   @"Error",
//                         nil];
//  [[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera failed" withProperties:info];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewDidLoad"
                                                     withLabel:[NSString stringWithFormat:@"Add camera failed:%@", _errorCode]
                                                     withValue:nil];
}

- (void)xibDefaultLocalization
{
    [[self.view viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_label_camera_not_found", nil, [NSBundle mainBundle], @"Camera Not Found", nil)];
    [[self.view viewWithTag:2] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_label_restore_your_camera", nil, [NSBundle mainBundle], @"Follow these steps to restore your camera", nil)];
    [[self.view viewWithTag:3] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_label_same_wifi_network", nil, [NSBundle mainBundle], @"1. Keep your phone and camera on the same Wi-Fi network", nil)];
    [[self.view viewWithTag:4] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_label_confirm_password_correct", nil, [NSBundle mainBundle], @"2. Confirm the Wi-Fi password is correct.", nil)];
    [[self.view viewWithTag:5] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_label_connected_to_internet", nil, [NSBundle mainBundle], @"3. Check if you are connected to internet", nil)];
    [[self.view viewWithTag:6] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_button_open_setting", nil, [NSBundle mainBundle], @"Open settings", nil)];
    [[self.view viewWithTag:7] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_button_open_camera_settings", nil, [NSBundle mainBundle], @"Open camera settings", nil)];
    [[self.view viewWithTag:8] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_button_check_now", nil, [NSBundle mainBundle], @"Check now", nil)];
    [[self.view viewWithTag:9] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step11_button_try_again", nil, [NSBundle mainBundle], @"Try Again", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma  mark -
#pragma mark button handlers

-(IBAction)tryAddCameraAgain:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step11 - Touch up inside try again btn" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Touch up inside"
                                                     withLabel:@"Try Again"
                                                     withValue:nil];
    //Go back to the beginning
    
    // Disable Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)btnSetupWithWifiAction:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    id aViewController = self.navigationController.viewControllers[0];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    if ([aViewController isKindOfClass:[Step_02_ViewController class]])
    {
        [((Step_02_ViewController *)aViewController) btnContinueTouchUpInsideAction:nil];
    }
    else
    {
        NSLog(@"%s aViewController:%@", __FUNCTION__, aViewController);
    }
}

- (void)dealloc {
    [_btnTestCamera release];
    [_btnSetupWithWifi release];
    [super dealloc];
}


@end

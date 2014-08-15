//
//  Step_11_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_11_ViewController.h"
#import "KISSMetricsAPI.h"
#import "define.h"
#import "PublicDefine.h"
#define GAI_CATEGORY    @"Step 11 view"

@interface Step_11_ViewController ()

@property (nonatomic, retain) IBOutlet UILabel *error_code;
@property (retain, nonatomic) IBOutlet UIButton *btnTestCamera;

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
    
    NSString *stringModel = @"";
    
    NSInteger model = [[NSUserDefaults standardUserDefaults] integerForKey:SET_UP_CAMERA];
    
    if (model == BLUETOOTH_SETUP)
    {
        stringModel = @"Mbp83";
    }
    else if(model == WIFI_SETUP)
    {
        stringModel = @"Focus66";
    }
    
    NSString *fwVersion = [[NSUserDefaults standardUserDefaults] stringForKey:FW_VERSION];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                         stringModel,   @"Camera model",
                         fwVersion,     @"FW",
                          _errorCode,   @"Error",
                         nil];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera failed" withProperties:info];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewDidLoad"
                                                     withLabel:[NSString stringWithFormat:@"Add camera failed:%@", _errorCode]
                                                     withValue:nil];
}

- (void)xibDefaultLocalization
{
    UILabel *lable = (UILabel *)[self.view viewWithTag:1];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_step11_label_camera_not_found", nil, [NSBundle mainBundle], @"Camera Not Found", nil);
    lable = (UILabel *)[self.view viewWithTag:2];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_step11_label_restore_your_camera", nil, [NSBundle mainBundle], @"Follow these steps to restore your camera", nil);
    lable = (UILabel *)[self.view viewWithTag:3];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_step11_label_same_wifi_network", nil, [NSBundle mainBundle], @"1. Keep your phone and camera on the same Wi-Fi network", nil);
    lable = (UILabel *)[self.view viewWithTag:4];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_step11_label_confirm_password_correct", nil, [NSBundle mainBundle], @"2. Confirm the Wi-Fi password is correct.", nil);
    lable = (UILabel *)[self.view viewWithTag:5];
    lable.text = NSLocalizedStringWithDefaultValue(@"xib_step11_label_connected_to_internet", nil, [NSBundle mainBundle], @"3. Check if you are connected to internet", nil);
    UIButton *button = (UIButton *)[self.view viewWithTag:6];
    [button setTitle:NSLocalizedStringWithDefaultValue(@"xib_step11_button_open_setting", nil, [NSBundle mainBundle], @"Open settings", nil) forState:UIControlStateNormal];
    button = (UIButton *)[self.view viewWithTag:7];
    [button setTitle:NSLocalizedStringWithDefaultValue(@"xib_step11_button_open_camera_settings", nil, [NSBundle mainBundle], @"Open camera settings", nil) forState:UIControlStateNormal];
    button = (UIButton *)[self.view viewWithTag:8];
    [button setTitle:NSLocalizedStringWithDefaultValue(@"xib_step11_button_check_now", nil, [NSBundle mainBundle], @"Check now", nil) forState:UIControlStateNormal];
    button = (UIButton *)[self.view viewWithTag:9];
    [button setTitle:NSLocalizedStringWithDefaultValue(@"xib_step11_button_try_again", nil, [NSBundle mainBundle], @"Try Again", nil) forState:UIControlStateNormal];
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
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
    //NSString * msgLabel = [NSString stringWithFormat:@"Add Camera Failed with errorCode:%@", self.errorCode];
}



- (void)dealloc {
    [_btnTestCamera release];
    [super dealloc];
}
@end

//
//  Step_11_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "Step_11_ViewController.h"
#import "define.h"
#import "PublicDefine.h"

#define GAI_CATEGORY    @"Step 11 view"

@interface Step_11_ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *error_code;
@property (nonatomic, weak) IBOutlet UIButton *btnTestCamera;

@end

@implementation Step_11_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.trackedViewName = GAI_CATEGORY;
    
    [self.btnTestCamera setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnTestCamera setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];

    if ( _errorCode ) {
        [_error_code setText:_errorCode];
    }
    else {
        _error_code.hidden = YES;
    }
    
    NSString *stringModel = @"";
    NSInteger model = [[NSUserDefaults standardUserDefaults] integerForKey:SET_UP_CAMERA];
    
    if (model == BLUETOOTH_SETUP) {
        stringModel = @"Mbp83";
    }
    else if(model == WIFI_SETUP) {
        stringModel = @"Focus66";
    }
    
    //NSString *fwVersion = [[NSUserDefaults standardUserDefaults] stringForKey:FW_VERSION];
    //NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
    //                     stringModel,   @"Camera model",
    //                     fwVersion,     @"FW",
    //                      _errorCode,   @"Error",
    //                     nil];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera failed" withProperties:info];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewDidLoad"
                                                     withLabel:[NSString stringWithFormat:@"Add camera failed:%@", _errorCode]
                                                     withValue:nil];
}

#pragma mark - button handlers

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
}

@end

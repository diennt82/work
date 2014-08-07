//
//  Step_12_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "Step_12_ViewController.h"
#import "StartMonitorCallback.h"
#import "KISSMetricsAPI.h"
#import "define.h"
#import "PublicDefine.h"

#define GAI_CATEGORY @"Step 12 view"

@interface Step_12_ViewController()

@property (nonatomic, weak) IBOutlet UIButton *btnWatchLiveCamera;

@end

@implementation Step_12_ViewController

@synthesize cameraName;

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.trackedViewName = GAI_CATEGORY;
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnWatchLiveCamera setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnWatchLiveCamera setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.cameraName.text =  (NSString *) [userDefaults objectForKey:@"CameraName"];
    
    NSString *stringModel = @"";
    NSInteger model = [[NSUserDefaults standardUserDefaults] integerForKey:SET_UP_CAMERA];
    
    if (model == BLUETOOTH_SETUP) {
        stringModel = @"Mbp83";
    }
    else if(model == WIFI_SETUP) {
        stringModel = @"Focus66";
    }
    
    NSString *fwVersion = [[NSUserDefaults standardUserDefaults] stringForKey:FW_VERSION];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          stringModel,   @"Camera model",
                          fwVersion,     @"FW",
                          nil];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera success" withProperties:info];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewDidLoad"
                                                     withLabel:nil
                                                     withValue:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

#pragma mark - Btn handling 

-(IBAction)startMonitor:(id)sender
{
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Step11 - Touch up inside View Live Camera btn" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Touch up inside"
                                                     withLabel:@"View Live Camera"
                                                     withValue:nil];
    
    NSString *registrationID = [[NSUserDefaults standardUserDefaults] objectForKey:CAMERA_UDID];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:registrationID forKey:REG_ID];
    [userDefaults synchronize];
    
    NSLog(@"STEP12 START MONITOR -reg: %@", registrationID);
    
    // Disable Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    
    id<StartMonitorDelegate> delegate = (id<StartMonitorDelegate>) [[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //[initSetupController startMonitorCallBack];
    [delegate startMonitorCallBack];
}

@end

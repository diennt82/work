//
//  Step_12_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_12_ViewController.h"
#import "KISSMetricsAPI.h"
#import "define.h"
#import "PublicDefine.h"

#define GAI_CATEGORY @"Step 12 view"

@interface Step_12_ViewController()

@property (retain, nonatomic) IBOutlet UIButton *btnWatchLiveCamera;

@end

@implementation Step_12_ViewController

@synthesize cameraName;

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.trackedViewName = GAI_CATEGORY;
    
    [self.btnWatchLiveCamera setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnWatchLiveCamera setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.cameraName.text =  (NSString *) [userDefaults objectForKey:CAMERA_NAME];
    
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
                          nil];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera success" withProperties:info];
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

#pragma mark -
#pragma mark Btn handling 

-(IBAction)startMonitor:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step11 - Touch up inside View Live Camera btn" withProperties:nil];
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

- (void)dealloc {
    [_btnWatchLiveCamera release];
    [super dealloc];
}
@end

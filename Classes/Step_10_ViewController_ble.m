//
//  Step_10_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#define TAG_IMAGE_VIEW_ANIMATION 595

#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import "Step_12_ViewController.h"
#import "Step_11_ViewController.h"
#import "Step_10_ViewController_ble.h"
#import "MBP_iosViewController.h"
#import "StartMonitorCallback.h"
#import "BLEConnectionManager.h"
#import "UserAccount.h"
#include "config.h"

@interface Step_10_ViewController_ble ()

@property (nonatomic, strong) IBOutlet UIView *cameraAddedView;
@property (nonatomic, strong) IBOutlet UIView *progressView;

@property (nonatomic, weak) IBOutlet UILabel *youAreSignedUpAsLabel;
@property (nonatomic, weak) IBOutlet UILabel *userInfoLabel;
@property (nonatomic, weak) IBOutlet UILabel *instructionLabel;

@property (nonatomic, weak) IBOutlet UILabel *checkingConnectionLabel;
@property (nonatomic, weak) IBOutlet UILabel *mayTakeAMinuteLabel;

@property (nonatomic, strong) UserAccount *userAccount;
@property (nonatomic, strong) ScanForCamera *scanner;

@property (nonatomic) BOOL shouldStopScanning;
@property (nonatomic) BOOL shouldRetrySilently;

@end

@implementation Step_10_ViewController_ble

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disconnect BLE
    DLog(@"Disconnect BLE");
    BLEConnectionManager.instanceBLE.needReconnect = NO;
    [BLEConnectionManager.instanceBLE.uartPeripheral didDisconnect];
    BLEConnectionManager.instanceBLE.delegate = nil;
    
    // Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // TODO: Setup as an attributed string so that name and email are in blue
    NSString *userInfoStr = LocStr(@"\"%@\" with %@");
    userInfoStr = [NSString stringWithFormat:userInfoStr, [userDefaults objectForKey:@"PortalUsername"], [userDefaults objectForKey:@"PortalUseremail"]];
    _userInfoLabel.text = userInfoStr;
    
    _checkingConnectionLabel.text = LocStr(@"Checking connection to camera");
    _mayTakeAMinuteLabel.text = LocStr(@"This may take up to a minute");
    
    self.cameraMac = (NSString *) [userDefaults objectForKey:@"CameraMacWithQuote"];
    self.stringUDID = [userDefaults stringForKey:CAMERA_UDID];
    
    UIImageView *imageView = (UIImageView *)[self.progressView viewWithTag:595];
    imageView.animationImages = @[
                                  [UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]
                                  ];
    
    imageView.animationDuration = 1.5;
    imageView.animationRepeatCount = 0;
    
    [self.view addSubview:self.progressView];
    [imageView startAnimating];
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    
    // CameraTest: try to search for camera now..
    [NSTimer scheduledTimerWithTimeInterval: SCAN_CAM_TIMEOUT_BLE
                                     target:self
                                   selector:@selector(setStopScanning:)
                                   userInfo:nil
                                    repeats:NO];
    
    // 2 of 3. no need to schedule timer here
    [self waitForCameraToReboot:nil];
}

- (void)startAnimationWithOrientation
{
    UIImageView *animationView =  (UIImageView *)[_cameraAddedView viewWithTag:TAG_IMAGE_VIEW_ANIMATION];
    [animationView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        animationView.animationImages = @[
                                          [UIImage imageNamed:@"frame-1_update-iOS7_new"],
                                          [UIImage imageNamed:@"frame-2_update-iOS7_new"],
                                          [UIImage imageNamed:@"frame-3_update-iOS7_new"],
                                          [UIImage imageNamed:@"frame-4-2_update-iOS7_new"],
                                          [UIImage imageNamed:@"frame-5_update-iOS7_new"],
                                          [UIImage imageNamed:@"frame-6_update-iOS7_new2"]
                                          ];
    }
    else {
        animationView.animationImages = @[
                                          [UIImage imageNamed:@"frame-1_update_new"],
                                          [UIImage imageNamed:@"frame-2_update_new"],
                                          [UIImage imageNamed:@"frame-3_update_new"],
                                          [UIImage imageNamed:@"frame-4-2_update_new"],
                                          [UIImage imageNamed:@"frame-5_update_new"],
                                          [UIImage imageNamed:@"frame-6_update_new"]
                                          ];
    }
    
    animationView.animationDuration = 18;
    animationView.animationRepeatCount = 0;
    
    [_cameraAddedView bringSubviewToFront:animationView];
    
    [animationView startAnimating];
}

#pragma mark - Timer callbacks

- (void)silentRetryTimeout:(NSTimer *)expired
{
    // TIMEOUT --
    self.shouldRetrySilently = NO;
}

#pragma mark -

-(void)setStopScanning:(NSTimer *)exp
{
    self.shouldStopScanning = YES;
}

- (void)waitForCameraToReboot:(NSTimer *)exp
{
    if ( _shouldStopScanning ) {
        self.shouldStopScanning = NO;
        DLog(@"stop scanning now.. should be 4 mins");
		[self setupFailed];
		return;
    }
    else {
        DLog(@"Continue scan...");
    }
    
    if ([self checkItOnline]) {
        // Found it online
        DLog(@"Found it online");
        [self setupCompleted];
        return;
    }
	
	[NSTimer scheduledTimerWithTimeInterval:2.0
									 target:self
								   selector:@selector(waitForCameraToReboot:)
								   userInfo:nil
									repeats:NO];
}

#pragma mark - MBS_JSON communication

- (BOOL)checkItOnline
{
    DLog(@"--> Try to search IP online...");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
    
    if ( !_userAccount ) {
        self.userAccount = [[UserAccount alloc] initWithUser:userEmail
                                                    password:userPass
                                                      apiKey:userApiKey
                                             accountDelegate:nil];
    }

    if ([_userAccount checkCameraIsAvailable:self.cameraMac]) {
        self.errorCode = @"NoErr";
        return YES;
    }
    
    self.errorCode = @"NotAvail";
    
    return NO;
}

- (void)updatesBasicInfoForCamera
{
    BMS_JSON_Communication *jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                    Selector:nil
                                                                                FailSelector:nil
                                                                                   ServerErr:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *udid = [userDefaults objectForKey:CAMERA_UDID];
    NSString *hostSSID = [userDefaults objectForKey:HOST_SSID];
    
    NSDictionary *responseDict = [jsonCommBlocked updateDeviceBasicInfoBlockedWithRegistrationId:udid
                                                                                       deviceName:nil
                                                                                         timeZone:nil
                                                                                             mode:nil
                                                                                  firmwareVersion:nil
                                                                                         hostSSID:hostSSID
                                                                                       hostRouter:nil
                                                                                        andApiKey:apiKey];
    BOOL updateFailed = YES;
    
    if (responseDict) {
        if ([responseDict[@"status"] integerValue] == 200) {
            NSString *bodyKey = [responseDict[@"data"] objectForKey:@"host_ssid"];
            if (![bodyKey isEqual:[NSNull null]]) {
                if ([bodyKey isEqualToString:hostSSID]) {
                    updateFailed = NO;
                }
            }
        }
    }
    
    if (updateFailed) {
        DLog(@"Step10VC - updatesBasicInfoForCamera: %@", responseDict);
    }
    else {
        DLog(@"Step10VC - updatesBasicInforForCamera successfully!");
    }
}

- (void)setupCompleted
{
    // Try to update host ssid to server
    [self updatesBasicInfoForCamera];
    
    Step_12_ViewController *step12ViewController = [[Step_12_ViewController alloc] initWithNibName:@"Step_12_ViewController" bundle:nil];
    [self.navigationController pushViewController:step12ViewController animated:NO];
}

- (void)  setupFailed
{
 	DLog(@"Setup has failed - remove cam on server");
	// send a command to remove camera
	
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(removeCamSuccessWithResponse:)
                                                                          FailSelector:@selector(removeCamFailedWithError:)
                                                                             ServerErr:@selector(removeCamFailedServerUnreachable)];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [jsonComm deleteDeviceWithRegistrationId:_stringUDID
                                   andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
    
    Step_11_ViewController *step11ViewController = nil;
    step11ViewController = [[Step_11_ViewController alloc] initWithNibName:@"Step_11_ViewController" bundle:nil];
    step11ViewController.errorCode = self.errorCode;
    [self.navigationController pushViewController:step11ViewController animated:NO];
}

- (void)removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	DLog(@"removeCam success");
}

- (void)removeCamFailedWithError:(NSDictionary *)errorResponse
{
	DLog(@"removeCam failed Server error: %@", errorResponse[@"message"]);
}

- (void)removeCamFailedServerUnreachable
{
	DLog(@"server unreachable");
}

@end

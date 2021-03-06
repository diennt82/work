//
//  Step_06_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

#import "Util.h"
#import "Step_08_ViewController.h"
#import "Step_07_ViewController.h"
#import "GAI.h"

@interface Step_06_ViewController : GAITrackedViewController<UIAlertViewDelegate>
{
    
    IBOutlet UITableViewCell * ssidCell;
    IBOutlet UITableViewCell * securityCell;
    IBOutlet UITableViewCell * passwordCell;
    IBOutlet UITableViewCell * confPasswordCell;
    //current state of camera
    NSString *_currentStateCamera;
    NSTimer *_inputPasswordTimer;
    DeviceConfiguration *_deviceConf;
    NSTimer *_timeOut;
    BOOL _isUserMakeConnect;
    BOOL _task_cancelled;
    
}

@property (retain, nonatomic) IBOutlet UIView *otaDummyProgress;
@property (retain, nonatomic) IBOutlet UIProgressView *otaDummyProgressBar;

@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewGuide;
//
@property (retain, nonatomic) IBOutlet UIView *infoSelectCameView;
@property (nonatomic, strong) NSString *currentStateCamera;
//timeout input password
@property (nonatomic, strong) NSTimer *inputPasswordTimer;
@property (nonatomic, strong) NSTimer *timeOut;
@property (nonatomic, assign) IBOutlet UITableViewCell * ssidCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * securityCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * passwordCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * confPasswordCell;

@property (nonatomic, retain) NSString* ssid, * security, *password; 
@property (nonatomic, retain) DeviceConfiguration * deviceConf;
@property (nonatomic, assign) BOOL isOtherNetwork; 



- (IBAction)handleNextButton:(id) sender;

-(void) sendWifiInfoToCamera; 
- (BOOL) restoreDataIfPossible;
-(void) prepareWifiInfo;


@end

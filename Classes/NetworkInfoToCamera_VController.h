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
#import "BLEManageConnect.h"

@interface NetworkInfoToCamera_VController : UIViewController<BLEManageConnectDelegate>
{
    
    IBOutlet UITableViewCell * ssidCell;
    IBOutlet UITableViewCell * securityCell;
    IBOutlet UITableViewCell * passwordCell;
    IBOutlet UITableViewCell * confPasswordCell;
    NSTimer *_statusNetworkTimer;
    NSString *_statusNetworkCamString;
    
}

@property (retain, nonatomic) IBOutlet UIView *ib_dialogVerifyNetwork;
@property (nonatomic, assign) IBOutlet UITableViewCell * ssidCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * securityCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * passwordCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * confPasswordCell;

@property (nonatomic, retain) NSString* ssid, * security, *password; 
@property (nonatomic, retain) DeviceConfiguration * deviceConf;
@property (nonatomic, assign) BOOL isOtherNetwork; 




-(void) handleNextButton:(id) sender;
-(void) sendWifiInfoToCamera; 
- (BOOL) restoreDataIfPossible;
-(void) prepareWifiInfo;


@end

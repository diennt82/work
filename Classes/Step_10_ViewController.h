//
//  Step_10_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanForCamera.h"
@class ScanForCamera;

@interface Step_10_ViewController : UIViewController
{
    IBOutlet UIView * progressView; 
    IBOutlet UILabel * userNameLabel;
    IBOutlet UILabel * userEmailLabel;
    
    IBOutlet UIView * setupFailView, *setupCompleteView; 
    IBOutlet UILabel * cameraName; 
    
    IBOutlet UIView * cameraAddedView; 
    IBOutlet UILabel * homeSSID; //ONLY USED in NORMAL ADD CAM SEQUENCE
    
    int num_scan_time;

    ScanForCamera * scanner; 
    NSString *cameraMac, *master_key;
}

@property (nonatomic,assign) IBOutlet UILabel * homeSSID;
@property (nonatomic, assign) IBOutlet UIView * progressView; 
@property (nonatomic, assign) IBOutlet UILabel * userNameLabel;
@property (nonatomic, assign) IBOutlet UILabel * userEmailLabel,  * cameraName;
@property (nonatomic, assign) IBOutlet UIView * setupFailView, *setupCompleteView;

@property (nonatomic, retain) NSString *cameraMac,  *master_key; 

-(IBAction)cameraTest:(id)sender;
-(IBAction)starMonitor:(id)sender;

- (void) wait_for_camera_to_reboot:(NSTimer *)exp;
- (void) checkScanResult: (NSTimer *) expired;

- (void) setupCompleted;


- (void)  setupFailed;
@end

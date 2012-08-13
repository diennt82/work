//
//  Step_03_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"
#import "Step_04_ViewController.h"

#define OPEN_WIFI_BTN_TAG 1001

@interface Step_03_ViewController : UIViewController
{
    IBOutlet UIView * inProgress; 
    
    BOOL task_cancelled;
    NSString * homeWifiSSID; 
	NSString * cameraMac; 
	NSString * cameraName;

}

@property (nonatomic, retain) UIView * inProgress; 
@property (nonatomic, retain) NSString * cameraMac, * cameraName;

- (IBAction)handleButtonPress:(id)sender;
- (void) hideProgess;
-(void) showProgress:(NSTimer *) exp;
- (void) checkConnectionToCamera:(NSTimer *) expired;
-(void) moveToNextStep;

@end

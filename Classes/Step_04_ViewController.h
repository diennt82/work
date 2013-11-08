//
//  Setup_04_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CameraScanner/CameraScanner.h>

#import "WifiEntry.h"
#import "WifiListParser.h"
#import "Step_05_ViewController.h"
#define CONF_CAM_BTN_TAG 1002

@interface Step_04_ViewController : UIViewController<UITextViewDelegate>
{
    IBOutlet UIView * camName;
    
    NSString * homeWifiSSID; 
    NSString * cameraMac; 
	NSString * cameraName;
     HttpCommunication *  comm; 
}


@property (nonatomic, retain) NSString * cameraMac, * cameraName;


- (IBAction)handleButtonPress:(id)sender;
-(void) queryWifiList;


//callback
-(void) setWifiResult:(NSArray *) wifiList;
@end

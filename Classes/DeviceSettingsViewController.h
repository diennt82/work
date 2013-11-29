//
//  DeviceSettingsViewController.h
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 29/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

@interface DeviceSettingsViewController : UITableViewController

@property (nonatomic, assign) CamChannel *camChannel;

@end

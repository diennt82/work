//
//  Step_12_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartMonitorCallback.h"

@interface Step_12_ViewController : UIViewController
{
      IBOutlet UILabel * cameraName;
}

@property (nonatomic, assign) IBOutlet UILabel  * cameraName;


-(IBAction)startMonitor:(id)sender;

@end

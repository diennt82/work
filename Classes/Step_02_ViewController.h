//
//  Step_02_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StartMonitorCallback.h"
#import "ConnectionMethodDelegate.h"

@interface Step_02_ViewController : UIViewController <StartMonitorDelegate>
{
    IBOutlet UITableViewCell * step1_cell, * step2_cell, * step3_cell;
    id<ConnectionMethodDelegate> delegate;
    
}

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;
@property (nonatomic) NSInteger cameraType;

- (IBAction)handleButtonPress:(id)sender;
- (IBAction)goBackToFirstScreen:(id)sender;


- (void)presentModallyOn:(UIViewController *)parent;

@end

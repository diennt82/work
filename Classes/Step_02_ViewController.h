//
//  Step_02_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StartMonitorCallback.h"
#import "ConnectionMethodDelegate.h"
#import "GAI.h"

@interface Step_02_ViewController : GAITrackedViewController <StartMonitorDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell *step1_cell;
@property (nonatomic, weak) IBOutlet UITableViewCell *step2_cell;
@property (nonatomic, weak) IBOutlet UITableViewCell *step3_cell;

@property (nonatomic, weak) id<ConnectionMethodDelegate>delegate;
@property (nonatomic) NSInteger cameraType;

- (IBAction)handleButtonPress:(id)sender;
- (IBAction)goBackToFirstScreen:(id)sender;

- (void)presentModallyOn:(UIViewController *)parent;

@end

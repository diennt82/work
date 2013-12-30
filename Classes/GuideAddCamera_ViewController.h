//
//  GuideAddCamera_ViewController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_InitialSetupViewController.h"
#import "Step_03_ViewController.h"
#import "StartMonitorCallback.h"

@interface GuideAddCamera_ViewController : UIViewController <StartMonitorDelegate>
{
    IBOutlet UITableViewCell * step1_cell, * step2_cell, * step3_cell;
    id<ConnectionMethodDelegate> delegate;
    
}

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;

- (IBAction)handleButtonPress:(id)sender;
-(IBAction)handleBackButton:(id)sender;
- (IBAction)goBackToFirstScreen:(id)sender;



- (void)presentModallyOn:(UIViewController *)parent;

@end

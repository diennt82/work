//
//  MBP_InitialSetupViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/23/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"
#import "ConnectionMethodDelegate.h"
#import "Step_02_ViewController.h"



#define CONTINUE_BTN_TAG 1000

@interface MBP_InitialSetupViewController : UIViewController
{

    id<ConnectionMethodDelegate> delegate;
}

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;


- (void)presentModallyOn:(UIViewController *)parent;

- (IBAction)handleButtonPress:(id)sender;
-(void) startMonitorCallBack;

@end

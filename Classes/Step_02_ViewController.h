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
#import "GAI.h"

@interface Step_02_ViewController : GAITrackedViewController <StartMonitorDelegate>
{
    id<ConnectionMethodDelegate> delegate;
}

@property (nonatomic, assign)  id<ConnectionMethodDelegate> delegate;
@property (nonatomic) NSInteger cameraType;

- (IBAction)btnContinueTouchUpInsideAction:(id)sender;

@end

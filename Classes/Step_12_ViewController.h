//
//  Step_12_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface Step_12_ViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UILabel *cameraName;

- (IBAction)startMonitor:(id)sender;

@end

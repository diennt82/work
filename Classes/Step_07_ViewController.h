//
//  Step_07_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/6/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Step_06_ViewController.h"

@class  Step_06_ViewController;

@interface Step_07_ViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableViewCell * cellView;
@property (nonatomic, assign) Step_06_ViewController * step06;

@end

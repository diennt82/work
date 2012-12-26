//
//  Step_02_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBP_InitialSetupViewController.h"
#import "Step_03_ViewController.h"


@interface Step_02_ViewController : UIViewController
{
    IBOutlet UITableViewCell * step1_cell, * step2_cell, * step3_cell;
    
}

- (IBAction)handleButtonPress:(id)sender;
@end

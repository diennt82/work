//
//  Step_08_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBP_iosViewController.h"

@interface Step_08_ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *ssidView;
@property (nonatomic, weak) IBOutlet UILabel *ssidView_1;
@property (nonatomic, weak) IBOutlet UIButton *createAccount;

- (IBAction)handleButtonPress:(id)sender;

@end

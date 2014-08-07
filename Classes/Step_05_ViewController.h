//
//  Step_05_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/25/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WifiEntry.h"
#import "Step_06_ViewController.h"
#import "GAI.h"

@interface Step_05_ViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UITableViewCell *cellView;
@property (nonatomic, strong) NSMutableArray *listOfWifi;

@end

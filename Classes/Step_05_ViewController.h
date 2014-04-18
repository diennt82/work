//
//  Step_05_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/25/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WifiEntry.h"
#import "Step_06_ViewController.h"

@interface Step_05_ViewController : UIViewController
{
    NSMutableArray * listOfWifi; 
    IBOutlet UITableViewCell * cellView; 
    IBOutlet UITableView * mTableView; 
}

@property (nonatomic, retain) NSMutableArray * listOfWifi;
@property (nonatomic, assign) IBOutlet UITableViewCell *cellView;

@end

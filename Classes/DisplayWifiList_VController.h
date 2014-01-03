//
//  DisplayWifiList_VController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WifiEntry.h"
#import "NetworkInfoToCamera_VController.h"

@interface DisplayWifiList_VController : UIViewController
{
    NSMutableArray * listOfWifi;
    IBOutlet UITableViewCell * cellView;
    IBOutlet UITableView * mTableView;
    
    
}

@property (nonatomic, retain) NSMutableArray * listOfWifi;


@property (nonatomic, assign) IBOutlet UITableViewCell *cellView;

-(IBAction) handleButtonPressed:(id) sender;

@end

//
//  AlertSettingViewController.h
//  MBP_ios
//
//  Created by NxComm on 10/1/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "MBP_iosAppDelegate.h"

@interface AlertSettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableViewCell *soundCellView;
    IBOutlet UITableViewCell *tempHiCellView;
    IBOutlet UITableViewCell *tempLoCellView;
    IBOutlet UIView * progressView; 
    IBOutlet UILabel * f_title; 
    
    IBOutlet UITableView * alertTable; 
    
    CamProfile * camera; 
}

@property (nonatomic, assign) IBOutlet UITableViewCell *soundCellView,* tempHiCellView, * tempLoCellView;

@property (nonatomic, assign) CamProfile * camera; 


-(IBAction)soundAlertChanged   :(id)sender;
-(IBAction)tempHiAlertChanged   :(id)sender;
-(IBAction)tempLoAlertChanged   :(id)sender;
-(IBAction)donePressed:(id)sender;


@end

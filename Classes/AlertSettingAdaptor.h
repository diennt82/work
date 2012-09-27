//
//  AlertSettingAdaptor.h
//  MBP_ios
//
//  Created by NxComm on 9/14/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CamProfile.h"
#import "MBP_iosViewController.h"

@interface AlertSettingAdaptor : NSObject<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableViewCell *soundCellView;
    IBOutlet UITableViewCell *tempHiCellView;
    IBOutlet UITableViewCell *tempLoCellView;
    UIView * progressView; 
    
    CamProfile * camera; 
}

@property (nonatomic, assign) UIView * progressView; 
@property (nonatomic, assign) IBOutlet UITableViewCell *soundCellView,* tempHiCellView, * tempLoCellView;

-(id) initWithCam:(CamProfile *)cp;

-(IBAction)soundAlertChanged   :(id)sender;
-(IBAction)tempHiAlertChanged   :(id)sender;
-(IBAction)tempLoAlertChanged   :(id)sender;

@end

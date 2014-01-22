//
//  EditCameraCell.h
//  MBP_ios
//
//  Created by NxComm on 12/7/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  DashBoard_ViewController; 

@interface EditCameraCell : UITableViewCell
{

    int cameraIndex;
    
    DashBoard_ViewController* vc;
    
}

@property (nonatomic) int cameraIndex;
@property (nonatomic,assign) DashBoard_ViewController* vc;


-(IBAction)alertSettings:(id)sender;
-(IBAction)removeCamera:(id)sender;
-(IBAction)renameCamera:(id)sender;

@end

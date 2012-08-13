//
//  DashBoard_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/31/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_FirstPage.h"
#import "ConnectionMethodDelegate.h"
#import "CamChannel.h"
#import "CamProfile.h"
#import "CameraViewController.h"
#import "Account_ViewController.h"

@interface DashBoard_ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableViewCell *cellView;
    IBOutlet UITableView * cameraList; 
    IBOutlet UITabBarController *tabBarController;

    IBOutlet UIView * offlineView; 
    
    NSArray * listOfChannel; 
    
    id<ConnectionMethodDelegate> delegate; 
    
     UIToolbar * topbar; 
    
}
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) NSArray * listOfChannel; 
@property (nonatomic, assign) IBOutlet UITableViewCell *cellView;
@property (nonatomic, assign) id<ConnectionMethodDelegate> delegate;
@property (nonatomic, retain)  UIToolbar *  topbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
     withConnDelegate:(id<ConnectionMethodDelegate> ) caller;
- (void)presentModallyOn:(UIViewController *)parent;
-(void) forceRelogin;
-(void) logout; 
-(IBAction)addCamera:(id)sender;
-(IBAction)checkNow:(id)sender;


@end

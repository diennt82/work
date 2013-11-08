//
//  DashBoard_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/31/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "MBP_FirstPage.h"
#import "ConnectionMethodDelegate.h"
#import "Account_ViewController.h"
#import "AlertSettingViewController.h"

#import "EditCameraCell.h"
#import "AlertPrompt.h"
#import "GAITrackedViewController.h"
#import "PlaylistViewController.h"

@class  EditCameraCell; 

#define  MAX_CAM_ALLOWED 4
#define ALERT_DEMO_926_TAG 905

@interface DashBoard_ViewController : GAITrackedViewController<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
{
    IBOutlet EditCameraCell *cellView;
    IBOutlet UITableView * cameraList; 
    IBOutlet UITabBarController *tabBarController;

    IBOutlet UIView * offlineView;
    IBOutlet UIView * emptyCameraListView; 
    IBOutlet UIView * progressView; 
       
    NSArray * listOfChannel; 
    
    id<ConnectionMethodDelegate> delegate; 
    
    UIToolbar * topbar; 
    
    BOOL editModeEnabled; 
    int edittedChannelIndex; 
    
   
}
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) IBOutlet UITableView * cameraList;

@property (nonatomic, retain) NSArray * listOfChannel; 
@property (nonatomic, assign) IBOutlet UITableViewCell *cellView;
@property (nonatomic, assign) id<ConnectionMethodDelegate> delegate;
@property (nonatomic, retain)  UIToolbar *  topbar;
@property (nonatomic) BOOL editModeEnabled; 
@property (nonatomic) int edittedChannelIndex; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
     withConnDelegate:(id<ConnectionMethodDelegate> ) caller;
- (void)presentModallyOn:(UIViewController *)parent;
-(void) forceRelogin;
//-(void) logout;
-(IBAction)addCamera:(id)sender;
-(IBAction)checkNow:(id)sender;
-(IBAction)scanCameras:(id)sender;

-(void) setupTopBarForEditMode:(BOOL) isEditMode;


-(IBAction)editCameras:(id)sender;
-(IBAction)removeCamera:(id)sender;
-(IBAction)renameCamera:(id)sender;
-(IBAction)alertSetting:(id)sender;


- (BOOL) shouldShowEditButton;
- (BOOL) shouldShowScanButton;

-(void) changeNameSuccessWithResponse:(NSData *) responsedata;
-(void) changeNameFailedWithError:(NSHTTPURLResponse*) error_response;
-(void) changeNameFailedServerUnreachable;

@end

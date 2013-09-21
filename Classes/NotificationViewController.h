//
//  NotificationViewController.h
//  BlinkHD_ios
//
//  Created by Admin on 14/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayListViewController.h"
#import "PlaylistInfo.h"
#import "PlaylistCell.h"
#import "PlaybackViewController.h"
#import "ConnectionMethodDelegate.h"
@interface NotificationViewController : UIViewController
{
    IBOutlet UIImageView * lastest_snapshot;
    IBOutlet UIButton * btn_goto_camlist;
    IBOutlet UIButton * btn_view_recording;

    
    //IBOutlet PlayListViewController *tempPlaylist;
    IBOutlet UIActivityIndicatorView * progress;
    
    NSString * cameraMacNoColon;
    NSString * cameraName;
    NSString * alertType;
    NSString * alertVal;
    PlaylistInfo *eventInfo;
    
    id <ConnectionMethodDelegate> delegate;
    BOOL readPlayListOnce; 
   

    
}
@property (retain, nonatomic) IBOutlet UIImageView * lastest_snapshot; 
@property (retain, nonatomic) IBOutlet PlayListViewController *tempPlaylist;

@property(nonatomic, retain) NSString * cameraMacNoColon;
@property(nonatomic, retain) NSString * cameraName;
@property(nonatomic, retain) NSString * alertType;
@property(nonatomic, retain) NSString * alertVal;
@property(nonatomic, retain ) PlaylistInfo * eventInfo;
@property(nonatomic, retain) id <ConnectionMethodDelegate> delegate;
@property(nonatomic) BOOL readPlayListOnce;  



-(IBAction) gotoCameraList:(id)sender;

-(IBAction) viewRecording:(id)sender;


-(IBAction) goBack:(id)sender;
- (void)presentModallyOn:(UIViewController *)parent;

@end

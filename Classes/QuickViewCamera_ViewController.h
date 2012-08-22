//
//  QuickViewCamera_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/16/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_Streamer.h"
#import "ConnectionMethodDelegate.h"
#import "CamChannel.h"
#import "CamProfile.h"
#import "CameraViewController.h"



@interface QuickViewCamera_ViewController : UIViewController<StreamerEventHandler, StreamerFrameRateUpdater, StreamerTemperatureUpdater>
{
    IBOutlet UILabel * temperature_label; 
    IBOutlet UIImageView * temperature_bg; 
    IBOutlet UIImageView * videoView; 
    
    IBOutlet UIView *progressView; 
    
    IBOutlet UIBarButtonItem * cameraNameBarBtn;
    IBOutlet UIBarButtonItem * cameraListBarBtn;
    IBOutlet UIToolbar * topBar; 
    
    
    MBP_Streamer * streamer; 
	//CamChannel * selected_channel;
    NSArray * listOfChannel; 
    int currentChannelIndex;
    
    NSTimer * flipTimer; 
    
    UIAlertView * alert;
	NSTimer * alertTimer;
    

}

@property (nonatomic, retain) MBP_Streamer * streamer;
//@property (nonatomic, retain) CamChannel * selected_channel;
@property (nonatomic, retain) NSArray * listOfChannel; 
@property (nonatomic) int currentChannelIndex; 
@property (nonatomic, retain) NSTimer * flipTimer, *alertTimer; 


-(void) viewOneChannel:(CamChannel *) ch;
-(void) channelFlip: (NSTimer*) exp;


@end

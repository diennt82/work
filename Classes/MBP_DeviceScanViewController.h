//
//  MBP_DeviceScanViewController.h
//  MBP_ios
//
//  Created by NxComm on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamProfile.h"



#define SCAN_MENU_BACK_BTN_TAG 800
#define SCAN_MENU_SCAN_BTN_TAG 801
#define SCAN_MENU_CHANN1_BTN_TAG 802
#define SCAN_MENU_CHANN2_BTN_TAG 803
#define SCAN_MENU_CHANN3_BTN_TAG 804
#define SCAN_MENU_CHANN4_BTN_TAG 805


#define SCAN_MENU_CAM1_VIEW_TAG 806
#define SCAN_MENU_CAM2_VIEW_TAG 807
#define SCAN_MENU_CAM3_VIEW_TAG 808
#define SCAN_MENU_CAM4_VIEW_TAG 809

#define SCAN_MENU_SAVE_BTN_TAG 810


#define DATA_BARKER 0xdeadbeef

@class CamProfile;


@interface MBP_DeviceScanViewController : UIViewController {

	IBOutlet UIButton * channel1_btn;
	IBOutlet UIButton * channel2_btn;
	IBOutlet UIButton * channel3_btn;
	IBOutlet UIButton * channel4_btn;
	
	IBOutlet UIImageView * camera1_view;
	IBOutlet UIImageView * camera2_view;
	IBOutlet UIImageView * camera3_view;
	IBOutlet UIImageView * camera4_view;
	IBOutlet UIImageView * scan_done_view;

	
	IBOutlet UIActivityIndicatorView * scan_progress;
	
	NSMutableArray * scan_results ;
	
	int next_profile_index;
	int scan_index;
	NSString * bc_addr;
	NSString * own_addr;
	int initialFlag;
	NSMutableData *responseData;
	
	CamChannel * channel1, * channel2, * channel3, *channel4;
}

@property (nonatomic,retain) IBOutlet UIButton * channel1_btn;
@property (nonatomic,retain) IBOutlet UIButton * channel2_btn;
@property (nonatomic,retain) IBOutlet UIButton * channel3_btn;
@property (nonatomic,retain) IBOutlet UIButton * channel4_btn;

@property (nonatomic,retain) IBOutlet UIImageView * camera1_view;
@property (nonatomic,retain) IBOutlet UIImageView * camera2_view;
@property (nonatomic,retain) IBOutlet UIImageView * camera3_view;
@property (nonatomic,retain) IBOutlet UIImageView * camera4_view;
@property (nonatomic,retain) IBOutlet UIImageView * scan_done_view;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * scan_progress;
@property (nonatomic,retain) NSMutableArray * scan_results;

@property (nonatomic, retain) CamChannel * channel1, * channel2, * channel3, *channel4;

- (IBAction) handleButtonPressed:(id) sender;

- (void) scan_for_devices;
-(NSString*)getBroadcastAddress;
-(NSString*)getAddress;
- (void) showAvailableCameras ;

- (void) saveData;

@end

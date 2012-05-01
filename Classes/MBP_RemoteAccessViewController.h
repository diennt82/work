//
//  MBP_RemoteAccessViewController.h
//  MBP_ios
//
//  Created by NxComm on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



#define RA_MENU_BACK_BTN_TAG 900
#define RA_MENU_CAM1_URL_TAG 901
#define RA_MENU_CAM1_PRT_TAG 902

#define RA_MENU_CAM2_URL_TAG 903
#define RA_MENU_CAM2_PRT_TAG 904
#define RA_MENU_CAM3_URL_TAG 905
#define RA_MENU_CAM3_PRT_TAG 906
#define RA_MENU_CAM4_URL_TAG 907
#define RA_MENU_CAM4_PRT_TAG 908

#define RA_MENU_SAVE_BTN_TAG 909


#define RA_DATA_BARKER 0xdeadcafe


@interface MBP_RemoteAccessViewController : UIViewController {

	
	IBOutlet UITextField * cam1_url_txt;
	IBOutlet UITextField * cam1_prt_txt;

	IBOutlet UITextField * cam2_url_txt;
	IBOutlet UITextField * cam2_prt_txt;

	IBOutlet UITextField * cam3_url_txt;
	IBOutlet UITextField * cam3_prt_txt;
	IBOutlet UITextField * cam4_url_txt;
	IBOutlet UITextField * cam4_prt_txt;
	
	
	NSString * cam1_url, * cam1_port; 
	NSString * cam2_url, * cam2_port;
	NSString * cam3_url, * cam3_port;
	NSString * cam4_url, * cam4_port;
}

@property (nonatomic,retain)  NSString * cam1_url, * cam1_port; 
@property (nonatomic,retain)  NSString * cam2_url, * cam2_port;
@property (nonatomic,retain)  NSString * cam3_url, * cam3_port;
@property (nonatomic,retain)  NSString * cam4_url, * cam4_port;





- (IBAction) handleButtonPressed:(id) sender;

- (void) saveData;
- (void) restoreData;

@end

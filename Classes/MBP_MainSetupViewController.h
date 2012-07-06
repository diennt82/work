//
//  MBP_SetupViewController.h
//  MBP_ios
//
//  Created by NxComm on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupHttpDelegate.h"
//#import "DeviceConfiguration.h"
//#import "MBP_DeviceConfigureViewController.h"


#define CONFIGURE_BUTTON_TAG 700
#define SCAN_BUTTON_TAG      701
#define MENU_SETUP_BACK_KEY_TAG   702
#define ADV_BUTTON_TAG 703
#define BRIGHTNESS_1_BUTTON_TAG 704
#define BRIGHTNESS_2_BUTTON_TAG 705
#define BRIGHTNESS_3_BUTTON_TAG 706
#define BRIGHTNESS_4_BUTTON_TAG 707
#define ASPECT_RATIO_43_BUTTON_TAG 708
#define ASPECT_RATIO_AUTO_BUTTON_TAG 709

@interface MBP_MainSetupViewController : UIViewController {

	id <SetupHttpDelegate> httpDelegate;
	
	int brightness;
	int contrast;
}

- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout;
- (void ) requestURLSync_bg:(NSString*)url;

-(IBAction) _handleButtonPressed:(id) sender;



- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
		 withDelegate:(id<SetupHttpDelegate>) delegate;



- (int)  setVideoContrast:(int) newValue;
- (int)  setVideoBrightness:(int) newValue;

- (void) setContrast_bg;
- (void) setBrightness_bg;

@end

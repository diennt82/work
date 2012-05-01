//
//  MBP_MainMenuView.h
//  MBP_ios
//
//  Created by NxComm on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define MENU_SETUP_TAG    301
#define MENU_PLAYLIST_TAG 302
#define MENU_MELODY_TAG 303
#define MENU_TEMPERATURE_TAG 304
#define MENU_VQUALITY_TAG 305
#define MENU_VOX_TAG 306
#define MENU_LED_TAG 307
#define MENU_PAIRING_TAG 308
#define MENU_BACK_TAG 309
#define MENU_INFO_TAG 310

@interface MBP_MainMenuView : UIView {

	IBOutlet UIButton * setupButton; 
	IBOutlet UIButton * playlistButton;
	IBOutlet UIButton * melodyButton;
	IBOutlet UIButton * temperatureButton;
	IBOutlet UIButton * picQualityButton;
	IBOutlet UIButton * voxButton;
	IBOutlet UIButton * ledButton; 
	IBOutlet UIButton * statusButton;
	
}

@property (nonatomic,retain) IBOutlet UIButton * melodyButton;

- (void) hideSingleCameraButtons:(BOOL) shouldHide;


@end

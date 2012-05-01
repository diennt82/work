//
//  MBP_setupViewController.h
//  MBP_ios
//
//  Created by NxComm on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupHttpDelegate.h"
//#import "DeviceConfiguration.h"

@class DeviceConfiguration;



/* Define TAG */

#define SETUP_SEC_TYPE_IMG_TAG  601
#define SETUP_KEY_IDX_IMG_TAG   603
#define SETUP_ADDR_MODE_IMG_TAG 604



#define SETUP_SEC_TYPE_CHANGE_TAG   607
#define SETUP_KEY_IDX_CHANGE_TAG    608
#define SETUP_ADDR_MODE_CHANGE_TAG 609
#define SETUP_BACK_KEY_TAG         610

#define SETUP_SSID_TXT_TAG 600
#define SETUP_KEY_TXT_TAG  602
#define SETUP_USRNAME_TXT_TAG 605
#define SETUP_PSSWD_TXT_TAG  606



#define SETUP_SAVE_CONFIGURATION_TAG 611
#define SETUP_SEND_CONFIGURATION_TAG 612




@interface MBP_DeviceConfigureViewController : UIViewController <UIActionSheetDelegate>
{
	id <SetupHttpDelegate> httpDelegate;

	IBOutlet UIScrollView * scrollView;

	IBOutlet UIImageView * securityTypeImg;
	IBOutlet UIImageView * keyIndexImg;
	IBOutlet UIImageView * addressingModeImg;
	
	IBOutlet UIButton * keyIndexButton;
	IBOutlet UITextField * ssidField;
	IBOutlet UITextField * securityKeyField;
	IBOutlet UITextField * usrNameField;
	IBOutlet UITextField * passWdField;
	
	
	/* DataSources */
	NSArray * securityTypeData;
	NSArray * keyIndexData;
	NSArray * addressingModeData;
	
	NSArray * securityTypeIcons;
	NSArray * keyIndexIcons;
	NSArray * addressingModeIcons;
	
	/* Storage object */
	DeviceConfiguration * deviceConf;
	
}
@property (nonatomic,retain) IBOutlet IBOutlet UIButton * keyIndexButton;
@property (nonatomic,retain) IBOutlet UIImageView * securityTypeImg;
@property (nonatomic,retain) IBOutlet UIImageView * keyIndexImg;
@property (nonatomic,retain) IBOutlet UIImageView * addressingModeImg;
@property (nonatomic,retain) IBOutlet UIScrollView * scrollView;
@property (nonatomic,retain) DeviceConfiguration * deviceConf;

@property (nonatomic,retain) IBOutlet UITextField * ssidField;
@property (nonatomic,retain) IBOutlet UITextField * securityKeyField;
@property (nonatomic,retain) IBOutlet UITextField * usrNameField;
@property (nonatomic,retain) IBOutlet UITextField * passWdField;


- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
		 withDelegate:(id<SetupHttpDelegate>) delegate;
- (BOOL) restoreDataIfPossible;

- (IBAction) handleButtonPressed:(id)sender;


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;


#if 0
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet;


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet;  // before animation and showing view
- (void)didPresentActionSheet:(UIActionSheet *)actionSheet;  // after animation

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
#endif 

@end

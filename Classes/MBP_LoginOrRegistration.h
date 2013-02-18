//
//  MBP_LoginOrRegistration.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosAppDelegate.h"
#import "BMS_Communication.h"
#import	"UserAccount.h"
#import "ConnectionMethodDelegate.h"
#import "ForgotPwdViewController.h"
#import "MBPNavController.h"
#import "Reachability.h"

#define LOGIN_BUTTON_TAG 200
#define CREATE_NEW_BUTTON_TAG 201
#define REMEMBER_PASS_TAG 202
#define USER_NAME_TXT_TAG 203
#define PASSWORD_TXT_TAG 204
#define BACK_BUTTON_TAG 205


#define REG_USER_NAME_TAG 206
#define REG_USER_PASS_TAG 207
#define REG_USER_EMAIL_TAG 208
#define REG_CANCEL_BUTTON_TAG 209
#define REG_CREATE_BUTTON_TAG 210

#define _AutoLogin @"shouldAutoLoginIfPossible"
#define _OfflineMode @"offlineMode"

#define _Use3G @"use3GToConnect"


@interface MBP_LoginOrRegistration : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate> {

	IBOutlet UITextField * userName; 
	IBOutlet UITextField * password; 

	IBOutlet UIView * progressView; 
	IBOutlet UILabel * progressLabel; 
	
	
	IBOutlet UIView * registraionView; 
	IBOutlet UITextField * regUserName;
	IBOutlet UITextField * regUserPass;
	IBOutlet UITextField * regUserEmail; 
	IBOutlet UIView * regProgress; 
	IBOutlet UIView * regComplete; 
	
	
	IBOutlet UITableViewCell * userNameCell;
    IBOutlet UITableViewCell * userPassCell;
    IBOutlet UITableViewCell * forgotPassCell;
    
    		
	
	NSString * temp_user_str; 
	NSString * temp_pass_str; 
	NSString * temp_user_email  ; 
	
	id <ConnectionMethodDelegate> delegate; 

    UserAccount * account ; 
	
}

@property (nonatomic, retain) IBOutlet UITableViewCell * userNameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell * userPassCell;
@property (nonatomic, retain) IBOutlet UITableViewCell * forgotPassCell;

@property (nonatomic,retain) IBOutlet UITextField * userName; 
@property (nonatomic,retain) IBOutlet UITextField * password; 


@property (nonatomic,retain) IBOutlet UIView * progressView; 
@property (nonatomic,retain) IBOutlet UILabel * progressLabel; 


@property (nonatomic,retain) IBOutlet UITextField * regUserName;
@property (nonatomic,retain) IBOutlet UITextField * regUserPass;
@property (nonatomic,retain) IBOutlet UITextField * regUserEmail; 
@property (nonatomic,retain) IBOutlet UIView * regProgress, *regComplete, *registraionView; 

@property (nonatomic, retain) 	NSString * temp_user_str, * temp_pass_str, * temp_user_email  ; 

@property (nonatomic, retain) UserAccount *account; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) delegate;

- (IBAction) handleButtonPressed:(id) sender;
- (IBAction) createNewAccount:(id)sender;

//LOGIN callbacks;
- (void) loginSuccessWithResponse:(NSData*) responseData;
- (void) loginFailedWithError:(NSHTTPURLResponse*) error_response; 
- (void) loginFailedServerUnreachable; 

- (void)presentModallyOn:(UIViewController *)parent;

@end

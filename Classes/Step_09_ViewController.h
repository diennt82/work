//
//  Step_09_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMS_Communication.h"
#import "Reachability.h"
#import "ToUViewController.h"
#import "Step_10_ViewController.h"


@interface Step_09_ViewController : UIViewController
{
    IBOutlet UITableViewCell * userName;
    IBOutlet UITableViewCell * userPass;
    IBOutlet UITableViewCell * userCPass;
    IBOutlet UITableViewCell * userEmail;
  

    IBOutlet UITableView * myTable; 
    
     NSString * tmp_user_str,* tmp_pass_str,* tmp_user_email;
}

@property (nonatomic, assign)   IBOutlet UITableViewCell * userName;
@property (nonatomic, assign)  IBOutlet UITableViewCell * userPass;
@property (nonatomic, assign)  IBOutlet UITableViewCell * userCPass;
@property (nonatomic, assign)  IBOutlet UITableViewCell * userEmail;

@property (nonatomic, retain)  NSString * tmp_user_str,* tmp_pass_str,* tmp_user_email;

-(IBAction) showTermOfUse_:(id) sender;
-(IBAction) handleNextButton:(id) sender;
+(BOOL) isWifiConnectionAvailable;



//REG callbacks;
- (void) regSuccessWithResponse:(NSData*) responseData;
- (void) regFailedWithError:(NSHTTPURLResponse*) error_response; 
- (void) regFailedServerUnreachable; 

@end

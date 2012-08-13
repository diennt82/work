//
//  Step_06_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_FirstPage.h"
#import "DeviceConfiguration.h"
#import "Util.h"
#import "HttpCommunication.h"
#import "Step_08_ViewController.h"
#import "Step_07_ViewController.h"

@interface Step_06_ViewController : UIViewController
{
    
    NSString * ssid, * security; 
    NSString * password;
    
    IBOutlet UITableViewCell * ssidCell;
    IBOutlet UITableViewCell * securityCell;
    IBOutlet UITableViewCell * passwordCell;
    IBOutlet UITableViewCell * confPasswordCell;
    

    BOOL isOtherNetwork; 

    
    /* Storage object */
	DeviceConfiguration * deviceConf;
    
}

@property (nonatomic, assign) IBOutlet UITableViewCell * ssidCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * securityCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * passwordCell;
@property (nonatomic, assign) IBOutlet UITableViewCell * confPasswordCell;
@property (nonatomic, retain) NSString* ssid, * security, *password; 
@property (nonatomic, retain) DeviceConfiguration * deviceConf;
@property (nonatomic, assign) BOOL isOtherNetwork; 




-(void) handleNextButton:(id) sender;
-(void) sendWifiInfoToCamera; 
- (BOOL) restoreDataIfPossible;
-(void) prepareWifiInfo;


@end

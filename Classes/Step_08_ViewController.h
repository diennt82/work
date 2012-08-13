//
//  Step_08_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Step_09_ViewController.h"
@interface Step_08_ViewController : UIViewController
{
    NSString * ssid; 
    IBOutlet UILabel * ssidView; 
    
}
@property (nonatomic, retain) NSString * ssid;


-(IBAction)handleButtonPress:(id)sender;
@end

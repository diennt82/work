//
//  Step_07_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/6/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Step_06_ViewController.h"

@protocol SecurityChangingDelegate <NSObject>
- (void)changeSecurityType:(NSString *)security;
@end

@interface Step_07_ViewController : UIViewController
{
    NSArray * securityTypes;
    
    IBOutlet UITableViewCell * cellView;
    int sec_index; 
}
@property (nonatomic, assign) int sec_index;
@property (nonatomic, assign) id <SecurityChangingDelegate> securityDelegate;
@property (nonatomic, retain) IBOutlet UITableViewCell * cellView;
@property (nonatomic, retain)  NSArray * securityTypes;
@end

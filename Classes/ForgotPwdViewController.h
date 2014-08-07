//
//  ForgotPwdViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/10/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPwdViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *passwordLinkSent;
@property (nonatomic, weak) IBOutlet UILabel *toEmail;
@property (nonatomic, weak) IBOutlet UITextField *userEmailTF;

@end

//
//  ForgotPwdViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/10/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPwdViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIView *passwordLinkSent;
@property (nonatomic, assign) IBOutlet UILabel *toEmail;
@property (nonatomic, assign) IBOutlet UITextField *userEmailTF;

@end

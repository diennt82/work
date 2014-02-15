//
//  ForgotPwdViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/10/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPwdViewController : UIViewController
{
    IBOutlet UIView * passwordLinkSent; 
    IBOutlet UILabel * toEmail; 
    IBOutlet UITextField * userEmailTF; 
}

@end

//
//  Account_ViewController.h
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionMethodDelegate.h"

@interface Account_ViewController : UIViewController
{
   IBOutlet UITableViewCell * userNameCell, * userCPassCell, * userEmailCell;
    UIToolbar * mtopbar; 
    
    id<ConnectionMethodDelegate> mdelegate; 
    
}
@property (nonatomic, retain)  UIToolbar *  mtopbar;
@property (nonatomic, assign) id<ConnectionMethodDelegate> mdelegate;

@end

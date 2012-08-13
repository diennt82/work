//
//  MBP_iosAppDelegate.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"


@interface MBP_iosAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MBP_iosViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MBP_iosViewController *viewController;

@end


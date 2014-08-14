/*
 *  ConnectionMethodDelegate.h
 *  MBP_ios
 *
 *  Created by NxComm on 4/24/12.
 *  Copyright 2012 Hubble Connected Ltd. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

/// sendStatus:
#define SETUP_CAMERA            1
#define LOGIN                   2
#define SCAN_CAMERA             3
#define AFTER_ADD_RELOGIN       4
#define AFTER_DEL_RELOGIN       5
#define BACK_FROM_MENU_NOLOAD    6
#define LOGGING_IN              7
#define LOGIN_FAILED_OR_LOGOUT  8
#define SCAN_BONJOUR_CAMERA     9
#define SHOW_CAMERA_LIST        10

@protocol ConnectionMethodDelegate

- (void)sendStatus:(int)status;

@end

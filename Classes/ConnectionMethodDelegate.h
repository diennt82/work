/*
 *  ConnectionMethodDelegate.h
 *  MBP_ios
 *
 *  Created by NxComm on 4/24/12.
 *  Copyright 2012 Smart Panda Ltd. All rights reserved.
 *
 */


#import <UIKit/UIKit.h>



@protocol ConnectionMethodDelegate
- (void)sendStatus:(int) status;
@end

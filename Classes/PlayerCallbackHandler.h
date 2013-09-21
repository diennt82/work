//
//  PlayerCallbackHandler.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 18/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerCallbackHandler <NSObject>


-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2;

@end



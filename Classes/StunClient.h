//
//  ViewController.h
//  TestPjnath
//
//  Created by Jason Lee on 30/9/13.
//  Copyright (c) 2013 Cvision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CameraScanner/CameraScanner.h>

#include "client_main.h"

#define APP_IS_ON_SYMMETRIC_NAT @"app_is_on_sym_nat"
#define TYPE_UNKNOWN            -1  //checking
#define TYPE_SYMMETRIC_NAT       1
#define TYPE_NON_SYMMETRIC_NAT   0

@protocol StunClientDelegate <NSObject>

- (void)symmetric_check_result:(BOOL)isBehindSymNat;

@end

@interface StunClient : NSObject

@property (nonatomic, strong) NSThread *natCheckThread;
@property (nonatomic, weak) id<StunClientDelegate> mcallback;

@property (nonatomic) BOOL waiting_for_result, running;
@property (nonatomic) pj_stun_nat_type nat_type;
@property (nonatomic) pj_status_t nat_status;

- (BOOL)test_start_;
- (BOOL)isCheckingForSymmetrictNat;
- (int)create_stun_forwarder:(CamChannel*)channel;

- (void)sendVideoProbesToIp:(NSString *)ip andPort:(int)port;
- (void)sendAudioProbesToIp:(NSString *)ip andPort:(int)port;
- (void)shutdown;
- (BOOL)test_start_async:(id<StunClientDelegate>)callback;

@end

//
//  ViewController.h
//  TestPjnath
//
//  Created by Jason Lee on 30/9/13.
//  Copyright (c) 2013 Cvision. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "client_main.h"
#import "CamChannel.h"

//NSDefault
#define APP_IS_ON_SYMMETRIC_NAT @"app_is_on_sym_nat"

@protocol StunClientDelegate <NSObject>

-(void)symmetric_check_result: (BOOL) isBehindSymNat;

@end


@interface StunClient : NSObject
{
    
}


@property(nonatomic) BOOL waiting_for_result, running ;
@property(nonatomic, retain) NSThread* natCheckThread; 
@property(nonatomic) pj_stun_nat_type nat_type;
@property (nonatomic) pj_status_t nat_status;
@property (nonatomic) id<StunClientDelegate> mcallback;

-(BOOL) test_start_;

-(int) create_stun_forwarder:(CamChannel*) channel;



-(void) sendVideoProbesToIp:(NSString *) ip andPort:(int) port;
-(void) sendAudioProbesToIp:(NSString *) ip andPort:(int) port;
-(void) shutdown;



-(BOOL) test_start_async: (id<StunClientDelegate>) callback;
@end

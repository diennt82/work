//
//  HoldOnCamWifi.m
//  BlinkHD_ios
//
//  Created by Developer on 30/6/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "HoldOnCamWifi.h"
#import "HttpCom.h"

@interface HoldOnCamWifi() {
    NSTimer *timer;
}

@end
@implementation HoldOnCamWifi
+ (HoldOnCamWifi *)shareInstance {
    static HoldOnCamWifi *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[HoldOnCamWifi alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startHolder {
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }
}

- (void)stopHolder {
    [timer invalidate];
    timer = nil;
}

- (void)onTimer:(NSTimer *)timer {
    [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_VERSION];
}
@end

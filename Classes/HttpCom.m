//
//  HttpCommunication.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 9/1/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "HttpCom.h"

@implementation HttpCom
@synthesize comWithDevice = _comWithDevice;

+ (HttpCom *) instance
{
    static HttpCom *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[HttpCom alloc] init];
    });
    return _sharedInstance;
}

-(id) init

{
    self = [super init];
    if (self) {
        _comWithDevice = [[HttpCommunication alloc] init];
    }
    return self;
}
@end

//
//  WifiEntry.m
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "WifiEntry.h"


@implementation WifiEntry


@synthesize ssid_w_quote, bssid, auth_mode; 
@synthesize encrypt_type;//version 1.1
@synthesize quality; 
@synthesize signal_level, noise_level , channel; 


-(id) initWithSSID:(NSString *) ssid
{
	self = [super init];
	self.ssid_w_quote = ssid; 
	return self;
}

-(void) dealloc
{
	[ssid_w_quote release]; 
	[bssid release]; 
	[auth_mode release]; 
	[quality release]; 
	[super dealloc];
}



@end

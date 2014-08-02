//
//  WifiEntry.m
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#import "WifiEntry.h"

@implementation WifiEntry

- (id)initWithSSID:(NSString *)ssid
{
	self = [super init];
	self.ssidWithQuotes = ssid;
	return self;
}

- (void)dealloc
{
	[_ssidWithQuotes release];
	[_bssid release];
	[_authMode release];
    [_encryptType release];
	[_quality release];
	[super dealloc];
}

@end

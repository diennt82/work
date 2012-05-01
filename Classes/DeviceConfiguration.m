//
//  DeviceConfiguration.m
//  MBP_ios
//
//  Created by NxComm on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DeviceConfiguration.h"


@implementation DeviceConfiguration

@synthesize ssid , securityMode,
keyIndex ,key, addressMode, usrName, passWd, wepType;


-(id) init
{
	ssid = @"default";
	securityMode = @"OPEN";
	keyIndex = @"1";
	wepType = @"OPEN";
	key = @"";
	addressMode = @"DHCP";
	usrName = @"";
	passWd = @"";
	
	return self;
}

- (void) dealloc
{
	[wepType release];
	[ssid release];
	[securityMode release];
	[keyIndex release];
	[key release];
	[addressMode release];
	[usrName	 release];
	[passWd release];
	[super dealloc];
}


- (BOOL) isDataReadyForStoring 
{
	if ( [ssid isEqualToString:@""] ||
		 ( ![securityMode isEqualToString:@"Open"] && [key isEqualToString:@""])
		 )
	
	{
		return NO;
	}
	
	
	
	
	return YES;
}

- (NSMutableDictionary *) getWritableConfiguration 
{
	
	
	
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]  init];
	[dict setObject:ssid forKey:@"SSID"];
	[dict setObject:securityMode forKey:@"SecMode"];
	[dict setObject:keyIndex forKey:@"KeyIndx"];
	[dict setObject:wepType forKey:@"WepType"];
	[dict setObject:key forKey:@"Key"];
	[dict setObject:addressMode forKey:@"AddrMode"];
	[dict setObject:usrName forKey:@"UsrName"];
	[dict setObject:passWd forKey:@"PassWd"];
	
	NSLog(@" SAVE sec: %@, key:%@, addrmode: %@", securityMode, key, addressMode);
	
	return dict;
}


- (void) restoreConfigurationData:  (NSDictionary *) dict
{
	
	ssid = (NSString *) [dict objectForKey:@"SSID"];
	securityMode = (NSString *) [dict objectForKey:@"SecMode"];
	keyIndex = (NSString *) [dict objectForKey:@"KeyIndx"];
	wepType = (NSString *) [dict objectForKey:@"WepType"];
	key = (NSString *) [dict objectForKey:@"Key"];
	addressMode = (NSString *) [dict objectForKey:@"AddrMode"];
	usrName = (NSString *) [dict objectForKey:@"UsrName"];
	passWd = (NSString *) [dict objectForKey:@"PassWd"];
	
	
	NSLog(@"RESTORE sec: %@, key:%@, addrmode: %@", securityMode, key, addressMode);
}
- (NSString *) getDeviceConfString
{
	NSString * conf_str  = @"";
	
	NSString * wifi_mode = @"1"; //infra mode
	
	conf_str = [conf_str stringByAppendingString:wifi_mode];
	
	NSString * adhoc_chann = @"00";
	
	conf_str = [conf_str stringByAppendingString:adhoc_chann];
	
	
	NSString * auth_mode, * key_index; 
	
	
	if ( [securityMode isEqualToString:@"WEP"])
	{
		NSLog(@"sec - wep : %@",wepType);
		
		auth_mode = ([wepType isEqualToString:@"OPEN"])?@"0":@"1";
		key_index = [NSString stringWithFormat:@"%1d",[keyIndex intValue] -1] ;
	}
	else
	{
		/* WPA/ WPA2 */
		auth_mode = @"2";
		key_index = @"0";

	}

	conf_str = [conf_str stringByAppendingString:auth_mode];
	conf_str = [conf_str stringByAppendingString:key_index];
	
	NSString * address_mode = @"0"; //assuming DHCP
	conf_str = [conf_str stringByAppendingString:address_mode];
	
	NSString * ssid_len = [NSString stringWithFormat:@"%03d",[ssid length]];
	conf_str = [conf_str stringByAppendingString:ssid_len];
	
	NSString * sec_key_len = [NSString stringWithFormat:@"%02d",[key length]];
	conf_str = [conf_str stringByAppendingString:sec_key_len];
	
	NSString * static_ip_len = @"00";
	conf_str = [conf_str stringByAppendingString:static_ip_len];

	NSString * static_ip_mask = @"00";
	conf_str = [conf_str stringByAppendingString:static_ip_mask];
	
	NSString * static_ip_gw_len = @"00";
	conf_str = [conf_str stringByAppendingString:static_ip_gw_len];
	
	NSString * port= @"0";
	conf_str = [conf_str stringByAppendingString:port];
	
	
	NSString * usr_name_len=  [NSString stringWithFormat:@"%02d",[usrName length]];
	conf_str = [conf_str stringByAppendingString:usr_name_len];
	
	NSString * passwd_len = [NSString stringWithFormat:@"%02d",[passWd  length]];
	conf_str = [conf_str stringByAppendingString:passwd_len];
	
	/* appending data */
	conf_str =[conf_str stringByAppendingString:ssid];
	conf_str =[conf_str stringByAppendingString:key];
	conf_str =[conf_str stringByAppendingString:usrName];
	conf_str =[conf_str stringByAppendingString:passWd];
	

	NSLog(@"conf: %@", conf_str);
	
	return conf_str;
	
}

@end

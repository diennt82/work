//
//  DeviceConfiguration.h
//  MBP_ios
//
//  Created by NxComm on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//




@interface DeviceConfiguration : NSObject {

	NSString * ssid; 
	NSString * securityMode; 
	NSString * keyIndex; /* Incase security is "WEP"*/
	NSString * wepType; /* open or shared */
	NSString * key; 
	NSString * addressMode; 
	NSString * usrName;
	NSString * passWd;
}

@property (nonatomic,retain)  NSString * ssid ,* securityMode,
		 * keyIndex ,* key,* addressMode, * usrName, *passWd, * wepType;

- (BOOL) isDataReadyForStoring;
- (NSMutableDictionary *) getWritableConfiguration;
- (void) restoreConfigurationData:  (NSDictionary *) dict;
- (NSString *) getDeviceConfString;
- (NSString *) getDeviceEncodedConfString;
@end

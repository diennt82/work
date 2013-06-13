//
//  WifiEntry.h
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//




#define VERSION_1 @"1.0"
#define VERSION_1_1 @"1.1"


@interface WifiEntry : NSObject {

	NSString * ssid_w_quote; 
	NSString * bssid; 
	NSString * auth_mode; 
	
	NSString* encrypt_type;//version 1.1
	
	NSString * quality; 
	int        signal_level; 
	int        noise_level; 
	
	int        channel; 
}


@property (nonatomic, retain) NSString * ssid_w_quote; 
@property (nonatomic, retain) NSString * bssid; 
@property (nonatomic, retain) NSString * auth_mode; 

@property (nonatomic, retain) NSString* encrypt_type;//version 1.1

@property (nonatomic, retain) NSString * quality; 
@property (nonatomic) int        signal_level; 
@property (nonatomic) int        noise_level; 

@property (nonatomic) int        channel; 

-(id) initWithSSID:(NSString *) ssid;


@end

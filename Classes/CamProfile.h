//
//  CamProfile.h
//  MBP_ios
//
//  Created by NxComm on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamChannel.h"

@class CamChannel;

@interface CamProfile : NSObject {

	NSString * scan_response;
	NSString * ip_address;
	NSString * mac_address;
	int port;
	int ptt_port; 
	
	UIImage * profileImage;
	
	NSData * profileImageData;
	
	BOOL isSelected;
	
	CamChannel * channel;
	
	BOOL isRemoteAccess;
	
	NSString * name; 
	NSString * last_comm; 
	int minuteSinceLastComm;
	
	BOOL isInLocal; 
    BOOL soundAlertEnabled;
    BOOL tempHiAlertEnabled;
    BOOL tempLoAlertEnabled;
}

@property (nonatomic,retain) NSString* scan_response, *ip_address, * mac_address;
@property (nonatomic) int port, minuteSinceLastComm, ptt_port;
@property (nonatomic) BOOL isSelected, isRemoteAccess,isInLocal;
@property (nonatomic,retain) UIImage * profileImage;
@property (nonatomic,retain) CamChannel * channel;
@property (nonatomic, retain) NSData * profileImageData;

@property (nonatomic,retain) NSString * name, *last_comm; 
@property (nonatomic) BOOL soundAlertEnabled,tempHiAlertEnabled,tempLoAlertEnabled;


-(void) initWithResponse:(NSString*) response andHost:(NSString *) host;
- (id) initWithMacAddr:(NSString *) mac;
- (NSMutableData *) getBytes; 

+ (CamProfile *) restoreFromData: (NSData *) data;

@end

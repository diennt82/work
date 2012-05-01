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
	
	UIImage * profileImage;
	
	NSData * profileImageData;
	
	BOOL isSelected;
	
	CamChannel * channel;
	
	BOOL isRemoteAccess;
	
	NSString * name; 
	NSString * last_comm; 
	int minuteSinceLastComm;
	
	BOOL isInLocal; 
}

@property (nonatomic,retain) NSString* scan_response, *ip_address, * mac_address;
@property (nonatomic) int port, minuteSinceLastComm;
@property (nonatomic) BOOL isSelected, isRemoteAccess,isInLocal;
@property (nonatomic,retain) UIImage * profileImage;
@property (nonatomic,retain) CamChannel * channel;
@property (nonatomic, retain) NSData * profileImageData;

@property (nonatomic,retain) NSString * name, *last_comm; 


-(void) initWithResponse:(NSString*) response andHost:(NSString *) host;
- (id) initWithMacAddr:(NSString *) mac;
- (NSMutableData *) getBytes; 

+ (CamProfile *) restoreFromData: (NSData *) data;

@end

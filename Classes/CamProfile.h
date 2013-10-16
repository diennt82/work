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
    BOOL hasUpdateLocalStatus;
    
    NSString * fw_version ,  * codecs;
}
@property (nonatomic,retain) NSString * fw_version, *codecs;
@property (nonatomic,retain) NSString* scan_response, *ip_address, * mac_address;
@property (nonatomic) int port, minuteSinceLastComm, ptt_port;
@property (nonatomic) BOOL isSelected, isRemoteAccess,isInLocal;
@property (nonatomic,retain) UIImage * profileImage;
@property (nonatomic,retain) CamChannel * channel;
@property (nonatomic, retain) NSData * profileImageData;

@property (nonatomic,retain) NSString * name, *last_comm; 
@property (nonatomic) BOOL soundAlertEnabled,tempHiAlertEnabled,tempLoAlertEnabled, hasUpdateLocalStatus;

@property (nonatomic,retain) NSString * camera_mapped_address; //camera mapped address
@property (nonatomic) int camera_stun_audio_port;
@property (nonatomic) int camera_stun_video_port;





-(void) initWithResponse:(NSString*) response andHost:(NSString *) host;
- (id) initWithMacAddr:(NSString *) mac;
- (NSMutableData *) getBytes; 

+ (CamProfile *) restoreFromData: (NSData *) data;
-(BOOL) isNewerThan08_038;
-(BOOL) isFW_version_08_xxx;

@end

//
//  CamChannel.h
//  MBP_ios
//
//  Created by NxComm on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamProfile.h"



#define CONFIGURE_STATUS_NOT_ASSIGNED 0x100
#define CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT 0x101
#define CONFIGURE_STATUS_ASSIGNED 0x102

@class CamProfile;
@interface CamChannel : NSObject {

	int channel_index;
	UIImageView * channel_view;
	CamProfile * profile;
	int channel_configure_status;
}

@property (nonatomic, retain) CamProfile * profile;
@property (nonatomic) int channel_configure_status, channel_index;


+(CamChannel *) restoreFromData: (NSData *) data;

- (id) initWithChannelIndex:(int) index;
- (BOOL) setCamProfile:(CamProfile *) cp;

- (BOOL) setConfigure;
- (void) setUnConfigure;
- (void) reset;

- (NSMutableData *) getBytes;

@end

//
//  SetupData.h
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <CameraScanner/CameraScanner.h>

/* Change this every time the setup data changed -- 
 */ 
#define DATA_BARKER  0xbeef0006
#define DEBUG_RESTORE_DATA 0

@interface SetupData : NSObject {

	NSMutableArray * channels; 
	NSMutableArray * configured_cams;
}

@property (nonatomic,retain) NSMutableArray* channels, *configured_cams; 

-(id) init;
-(id) initWithChannels:(NSMutableArray*)channs AndProfiles:(NSMutableArray*) cps;

-(BOOL) save_session_data;
-(BOOL) restore_session_data;


@end

//
//  SetupData.h
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 eBuyNow eCommerce Limited. All rights reserved.
//

#import <CameraScanner/CameraScanner.h>

/* 
 Change this every time the setup data is changed
 */ 
#define DATA_BARKER  0xbeef0009
#define DEBUG_RESTORE_DATA 0

@interface SetupData : NSObject

@property (nonatomic, retain) NSMutableArray *channels;
@property (nonatomic, retain) NSMutableArray *configuredCams;

- (id)initWithChannels:(NSMutableArray *)channs andProfiles:(NSMutableArray *)cps;
- (BOOL)saveSessionData;
- (BOOL)restoreSessionData;

@end

//
//  ScanForCamera.h
//  MBP_ios
//
//  Created by NxComm on 5/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//
#import "PublicDefine.h"
#import "Util.h"
#import "MBP_iosViewController.h"
#import "CamProfile.h"
#import "AsyncUDPSocket.h"

#import "ScanForCameraProtocol.h"



@interface ScanForCamera : NSObject {

	NSString * bc_addr; 
	NSString * own_addr; 
	
	int next_profile_index; 
	NSMutableArray * scan_results; 
	BOOL deviceScanInProgress; 
    id<ScanForCameraNotifier> notifier;
    int mode;
}



@property (nonatomic,retain) NSString * bc_addr; 
@property (nonatomic,retain) NSString * own_addr; 

@property (nonatomic) int next_profile_index;
@property (nonatomic) BOOL deviceScanInProgress; 
@property (nonatomic,retain) NSMutableArray * scan_results; 

@property (nonatomic, assign) id<ScanForCameraNotifier> notifier;

-(id) initWithNotifier:(id<ScanForCameraNotifier>) caller withMode:(int) scanMode;
-(id) initWithNotifier:(id<ScanForCameraNotifier>) caller;

- (void) scan_for_devices;
- (BOOL) getResults:(NSArray **) out_Array;

- (void) scan_for_device:(NSString*) mac;
- (NSArray *) scan_for_some_devices:(NSArray *) profiles;

-(void) scan_done_notify;
-(void) cancel;

@end

//
//  CameraPassword.h
//  MBP_ios
//
//  Created by NxComm on 4/23/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

@interface CameraPassword : NSObject {

	NSString * cameraUser; 
	NSString * cameraMacId;
	NSString * cameraPassword; 
}

@property (nonatomic,retain) NSString * cameraUser, *cameraMacId, *cameraPassword;


+ (NSString* )fetchBSSIDInfo;


+ (NSString*) getPasswordForCam:(NSString*) mac_address; 
//+ (bool) removePasswordForCam:(NSString*) mac_address;

+(BOOL) saveCameraPassword:(CameraPassword *) cp ;
+(int) loadPasswordFromStore:(NSMutableArray ** )camera_array;
+(int) savePasswordToStore:(NSMutableArray * )camera_array nextSlot:(int) next;

- (id) initWithMac:(NSString*) mac User:(NSString *) user Pass:(NSString*) pass;

@end

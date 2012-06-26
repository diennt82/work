//
//  Util.h
//  AiBallRecorder
//
//  Created by NxComm on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraPassword.h"

@interface Util : NSObject {

	NSString * transient_ip;
	int transient_port;
}

+ (int)offsetOfBytes:(Byte*)buffer bufferLength:(int)blen searchPattern:(const Byte*)searchPattern patternLength:(int)plen;
+ (int)offsetOfBytes:(NSData*)buffer searchPattern:(NSData*)searchPattern;
+ (NSString*) getRecordDirectory;
+ (NSString*) getRecordFileName;
+ (NSString*) getDebugFileName;
+ (NSString*) getSnapshotFileName;
+ (int) getMaxRecordSize;
+ (NSString*) getDefaultURL;
+ (void) setDefaultURL:(NSString*)ip;
+ (NSString*) getSnapshotURL;
+ (NSString*) getContrastPlusURL;
+ (NSString*) getContrastMinusURL;
+ (NSString*) getBrightnessPlusURL;
+ (NSString*) getBrightnessMinusURL;
+ (NSString*) getContrastValueURL;
+ (NSString*) getBrightnessValueURL;
+ (NSString*) getMotorControlURL:(NSString*)direction wDutyCycle:(float)cycle;
+ (NSString*) getEarLedURL:(int)led_status ;
+ (NSString*) getWalkieTalkieURL:(NSString *) status;
+ (NSString*) getBatteryLevelURL;
+ (NSString*) getWifiLevelURL;
+ (NSString *) getMelodyURL:(NSString *) status;
+ (NSString *) getMelodyStopURL;
+ (NSString *) getMelodyValueURL;

+(NSString *) getVideoModeURL:(int) mode;

+ (void) writeDeviceConfigurationData: (NSDictionary *) dict;
+ (NSDictionary *) readDeviceConfiguration ;
+ (NSString * ) getDataFileName;

+ (void)IntToByteArray_LSB:(int)val des:(unsigned char*)des;
+ (void) ShortToByteArray_LSB:(short)word0 des:(unsigned char*)des;
+ (UITabBarController*) getTabBarController;
+ (void) setTabBarController:(UITabBarController*)tbc;
+ (NSString*) getIPFromURL:(NSString*)url;
+ (int) getPortFromURL:(NSString*)url;
+ (NSString*) getUsername;
+ (NSString*) getPassword;
+ (NSString*) getDFCredentials;
+ (NSString*) getCredentials;
+ (int) getSocketFlag;
+ (void) setSocketFlag:(int)flag;
+ (BOOL) validateIP: (NSString *) candidate;

+(void) setHttpUsr:(NSString *) usr;
+(void) setHttpPass:(NSString *) pass;

+ (NSString *) strip_colon_fr_mac:(NSString *) cam;
+ (NSString *) add_colon_to_mac:(NSString *) cam;
+(void) setHomeSSID:(NSString *) ssid;
+(NSString *) getHomeSSID;
+ (NSString*) getCameraCredentials: (NSString *) camMac;
+(NSString *)  get_error_description:(int) bms_error_code;
@end

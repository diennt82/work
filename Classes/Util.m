//
//  Util.m
//  AiBallRecorder
//
//  Created by NxComm on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PublicDefine.h"
#import "Util.h"
#import "AiBallBase64Encoding.h"

static UITabBarController* tabBarController;
static int socketFlag = 0;

@implementation Util

+ (int) getSocketFlag {
	return socketFlag;
}

+ (void) setSocketFlag:(int)flag {
	socketFlag = flag;
}


+ (int)offsetOfBytes:(NSData*)buffer searchPattern:(NSData*)searchPattern
{
	return [Util offsetOfBytes:(Byte *)[buffer bytes] 
					bufferLength:[buffer length] 
					searchPattern:[searchPattern bytes] 
					patternLength:[searchPattern length]
			];
}

+ (int)offsetOfBytes:(Byte*)buffer bufferLength:(int)blen searchPattern:(const Byte*)searchPattern patternLength:(int)plen
{
    Byte *cp = buffer;
    Byte *s1, *s2;
	
    if ( !*searchPattern )
        return 0;
	
	if( blen < plen)
		return -1;
	
    int i = 0;
    for (i=0; i <= blen - plen; i++)
    {
        s1 = cp;
        s2 = (Byte*)searchPattern;
		
		int matched = 1;
		for(int j = 0; j < plen; j++) {
			if(*s1 != *s2) {
				matched = 0;
				break;
			}
            s1++, s2++;
		}
		
		if(matched) {
			return i;
		}
		
        cp++;
    }
	
    return -1;
}

+ (NSString*) getRecordDirectory
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
	NSString* docsPath = [paths objectAtIndex:0];
	return docsPath;
}

+ (NSString*) getRecordFileName
{
	// get current date/time
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	// display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
	[dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
	NSString *currentTime = [dateFormatter stringFromDate:today];
	[dateFormatter release];
	return [NSString stringWithFormat:@"%@%@%@%@", [Util getRecordDirectory], @"/", currentTime, @".avi"];
}

+ (NSString*) getDebugFileName
{
	// get current date/time
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	// display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
	[dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
	NSString *currentTime = [dateFormatter stringFromDate:today];
	[dateFormatter release];
	return [NSString stringWithFormat:@"%@%@%@%@", [Util getRecordDirectory], @"/", currentTime, @".dbg"];
}

+ (NSString*) getSnapshotFileName
{
	// get current date/time
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	// display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
	[dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
	NSString *currentTime = [dateFormatter stringFromDate:today];
	[dateFormatter release];
	return [NSString stringWithFormat:@"%@%@%@%@", [Util getRecordDirectory], @"/", currentTime, @".jpg"];	
}

+ (int) getMaxRecordSize
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int size = [userDefaults integerForKey:@"maxAiBallRecordSize"];
	if(size <= 0) {
		size = DEFAULT_MAX_RECORD_SIZE;
		[userDefaults setInteger:size forKey:@"maxAiBallRecordSize"];
	}
	return size;
}

+ (NSString*) getDefaultURL
{

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* defaultIP = [userDefaults stringForKey:@"defaultIPAddress"];
	if(defaultIP == nil || ![self validateIP:defaultIP]) {
		[userDefaults setObject:DEFAULT_AIBALL_SERVER forKey:@"defaultIPAddress"];
		return DEFAULT_AIBALL_SERVER;
	}
	
	//NSLog(@"default IP: %@", defaultIP);
	
	return defaultIP;	
	//return DEFAULT_AIBALL_SERVER;
}

+ (NSString*) getUsername
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults stringForKey:@"Username"];
}

+ (NSString*) getPassword
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults stringForKey:@"password"];
}

+ (NSString*) getIPFromURL:(NSString*)url
{
	NSArray* components = [[url substringFromIndex:7] componentsSeparatedByString:@":"];
	return [components objectAtIndex:0];
}

+ (int) getPortFromURL:(NSString*)url
{
	NSArray* components = [[url substringFromIndex:7] componentsSeparatedByString:@":"];
	return [[components objectAtIndex:1] intValue];
}

+ (void) setDefaultURL:(NSString*)ip
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:ip forKey:@"defaultIPAddress"];
	
	//transient_ip = ip;

	NSLog(@"Set default ip: %@", ip);

}

+(void) setHttpUsr:(NSString *) usr
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:usr forKey:@"Username"];
	
}

+(void) setHttpPass:(NSString *) pass
{

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:pass forKey:@"password"];
	
}


+ (NSString*) getSnapshotURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL], @"/?action=snapshot"];
}

+ (NSString*) getContrastPlusURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL], @"/?action=command&command=contrast_plus"];
}

+ (NSString*) getContrastMinusURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL], @"/?action=command&command=contrast_minus"];
}

+ (NSString*) getBrightnessPlusURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL], @"/?action=command&command=brightness_plus"];
}

+ (NSString*) getBrightnessMinusURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL], @"/?action=command&command=brightness_minus"];
}


+ (NSString*) getContrastValueURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL], @"/?action=command&command=value_contract"];
}

+ (NSString*) getBrightnessValueURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL], @"/?action=command&command=value_brightness"];
}

//20110728: phung: add URL to set speed
+ (NSString*) getMotorControlURL:(NSString*)direction wDutyCycle:(float)cycle
{
	if ([direction isEqualToString:@"lr_stop"] || [direction isEqualToString:@"fb_stop"])
	{
		return [NSString stringWithFormat:@"%@%@%@", [Util getDefaultURL], @"/?action=command&command=",
			   direction];
	}
	
#if REVERT_LEFT_RIGHT_DIRECTION
	
	
	
	
	if ([direction isEqualToString:@"move_left"])
	{
		return [NSString stringWithFormat:@"%@%@%@%.1f", [Util getDefaultURL], @"/?action=command&command=",
				@"move_right",cycle];
	}
	
	if ([direction isEqualToString:@"move_right"])
	{
		return [NSString stringWithFormat:@"%@%@%@%.1f", [Util getDefaultURL], @"/?action=command&command=",
				@"move_left",cycle];
	}
	
	
	return [NSString stringWithFormat:@"%@%@%@%.1f", [Util getDefaultURL], @"/?action=command&command=",
			direction,cycle];
#elif REVERT_UP_DOWN_DIRECTION
	
	
	if ([direction isEqualToString:@"move_forward"])
	{
		return [NSString stringWithFormat:@"%@%@%@%.1f", [Util getDefaultURL], @"/?action=command&command=",
				@"move_backward",cycle];
	}
	
	if ([direction isEqualToString:@"move_backward"])
	{
		return [NSString stringWithFormat:@"%@%@%@%.1f", [Util getDefaultURL], @"/?action=command&command=",
				@"move_forward",cycle];
	}
	
	
	return [NSString stringWithFormat:@"%@%@%@%.1f", [Util getDefaultURL], @"/?action=command&command=",
			direction,cycle];
#else 
	
	return [NSString stringWithFormat:@"%@%@%@%.1f", [Util getDefaultURL], @"/?action=command&command=",
			direction,cycle];
#endif
	
	
	
}

+ (NSString*) getEarLedURL:(int)led_status 
{
	return [NSString stringWithFormat:@"%@%@%d", [Util getDefaultURL], @"/?action=command&command=ear_led",
			led_status];
}


+ (NSString*) getWalkieTalkieURL:(NSString *) status
{
	return [NSString stringWithFormat:@"%@%@%@", [Util getDefaultURL],
			@"/?action=command&command=audio_out",
			status];
}

/* return value: [1,2,3,4] */
+ (NSString*) getBatteryLevelURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
			@"/?action=command&command=value_battery"];
}

/* Return value: [4,3,2,1,0].. */
+ (NSString*) getWifiLevelURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
			@"/?action=command&command=value_wifi"];
}



+ (NSString *) getMelodyURL:(NSString *) status
{
	if ( [status isEqualToString:@"0"])
	{
		return [self getMelodyStopURL];
	}
	
	return [NSString stringWithFormat:@"%@%@%@", [Util getDefaultURL],
			@"/?action=command&command=melody",
			status];
}


+ (NSString *) getMelodyStopURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
			@"/?action=command&command=melodystop"];
}

+ (NSString *) getMelodyValueURL
{
	return [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
			@"/?action=command&command=value_melody"];
}



+ (NSString * ) getDataFileName
{
	return [NSString stringWithFormat:@"%@%@%@", [Util getRecordDirectory], @"/", @".cam.dat"];

}

+ (NSString * ) getCPFileName
{
	return [NSString stringWithFormat:@"%@%@%@", [Util getRecordDirectory], @"/", @"cam_pwd.dat"];
	
}


+(NSString *) getVideoModeURL:(int) mode 
{
	
	NSString * video_mode = [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
							   @"/?action=command&command=QVGA320_240"];
	
	
	switch (mode) {
		case 0: //QQVGA
			video_mode = [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
						  @"/?action=command&command=QQVGA160_120"];

			break;
		case 1://QVGA
			video_mode = [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
						  @"/?action=command&command=QVGA320_240"];

			break;
		case 2://VGA
			video_mode = [NSString stringWithFormat:@"%@%@", [Util getDefaultURL],
						  @"/?action=command&command=VGA640_480"];

			break;
		default:
			break;
	}
	return video_mode;
}





+ (void) writeDeviceConfigurationData: (NSDictionary *) dict
{
	
	NSString *  filePath= [NSString stringWithFormat:@"%@%@%@", [Util getRecordDirectory], @"/",@"device_conf.dat"];
	
	[dict writeToFile:filePath atomically:NO];
	
}

+ (NSDictionary *) readDeviceConfiguration 
{
	
	NSString *  filePath= [NSString stringWithFormat:@"%@%@%@", [Util getRecordDirectory], @"/",@"device_conf.dat"];

	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	
	return dict;
}



+ (BOOL) validateIP: (NSString *) candidate {
	if(candidate == nil) return NO;
	
	if([candidate length] <= 10) return NO;
	
	NSString* sub = [candidate substringFromIndex:7];
	NSRange range = [sub rangeOfString:@":"];
	// there must be a ':'
	if(range.length <= 0) return NO;
	// the ':' can't be at the beginning
	if(range.location < 1) return NO;
	// the ':' can't be at the end
	if(range.location == [sub length] - 1) return NO;
	/*
    NSString *ipRegEx = @"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$";
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegEx]; 
    return [ipTest evaluateWithObject:candidate];
	 */
	return YES;
}

+ (void) IntToByteArray_LSB:(int)val des:(unsigned char*)des 
{
	des[3] = (unsigned char)(val / 0x1000000);
    val %= 0x1000000;
    des[2] = (unsigned char)(val / 0x10000);
    val %= 0x10000;
    des[1] = (unsigned char)(val / 256);
    val %= 256;
    des[0] = (unsigned char)val;
}

+ (void) ShortToByteArray_LSB:(short)word0 des:(unsigned char*)des 
{
	des[1] = (unsigned char)(word0 >> 8);
	des[0] = (unsigned char)(word0 & 0xff);
}

+ (UITabBarController*) getTabBarController
{
	return tabBarController;
}

+ (void) setTabBarController:(UITabBarController*)tbc
{
	tabBarController = tbc;
}

+ (NSString*) getCredentials
{
	NSString* plain = [NSString stringWithFormat:@"%@:%@", [Util getUsername], [Util getPassword]];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	return [NSString base64StringFromData:plainData length:[plainData length]];
}

+ (NSString*) getDFCredentials
{
	NSString* plain = [NSString stringWithFormat:@"%@:%@", @"camera", @"000000"];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	return [NSString base64StringFromData:plainData length:[plainData length]];
}

+ (NSString*) getCameraCredentials: (NSString *) camMac
{
	NSString * camPass = [CameraPassword getPasswordForCam:camMac];
	
	if (camPass == nil)
	{
		camPass = @"000000"; //set to default; 
	}
	
	NSString* plain = [NSString stringWithFormat:@"%@:%@", @"camera", camPass];
	NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
	return [NSString base64StringFromData:plainData length:[plainData length]];
}

+ (NSString *) add_colon_to_mac:(NSString *) cam
{
	NSString * res;
	NSString * substr;
	NSRange range;
	int i = 0; 
	
	res = @"";
	while (i< 12)
	{
		range= NSMakeRange(i,2);
		substr = [cam substringWithRange:range];

		if (i == 0)
		{
			res = substr; 
		}
		else {
			res =[res stringByAppendingFormat:@":%@",substr];
		}

		i+=2;
	}
	
	return res; 
}

+ (NSString *) strip_colon_fr_mac:(NSString *) cam
{
	NSString * res;
	NSArray * cam_toks; 
	cam_toks = [cam	componentsSeparatedByString:@":"];
	
	res = @"";
	for(int i =0; i< [cam_toks count]; i++)
	{
		res =[res stringByAppendingString:[cam_toks objectAtIndex:i]];
	}
	return res; 
}

+(void) setHomeSSID:(NSString *) ssid
{
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:ssid forKey:@"homeSSID"];
	
}


+(NSString *) getHomeSSID
{
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * ssid = (NSString*) [userDefaults objectForKey:@"homeSSID"];
	return ssid;
	
}

+(NSString *)  get_error_description:(int) bms_error_code
{
    NSString * result = nil;
    result = @"Unknown error";
    switch(bms_error_code)
    {
        case 601:
            result = @"Invalid command passed. Please check the query.";
            break;
        case 602:
            result = @"Required parameter(s) are missing.";
            break;
        case 603:
            result = @"Length of the parameter is out of expected boundaries.";
            break;
        case 611:
            result = @"Camera does not exist.";
            break;
        case 612:
            result =@"Unable to communicate with the camera.";
            break;
        case 613:
            result = @"Unable to communicate with the camera.";
            break;
        case 614:
            result = @"Camera is not ready for streaming";
            break;
        case 621:
            result =@"Email Id is not registered.";
            break;
        case 622:
            result =@"Email Id registed but not activated.";
            break;
        case 623:
            result =@"Email Id is already activated.";
            break;
        case 624:
            result =@"Activation failed. Either user is not registered or the activation period is expired. Please register again.";
            break;
        case 625:
            result =@"Activation failed. Invalid activation key.";
            break;
        case 626:
            result =@"Authentication failed, either Email Id or Password is invalid.";
            break;
        case 627:
            result =@"Camera is not associated with any user (email id).";
            break;
        case 628:
            result =@"Email is already registered";
            break;
        case 699:
            result =@"Unhandled exception occured, please contact administrator.";
            break;
        default:
            result = [NSString stringWithFormat:@"%@%d",@"Unknown error - ", bms_error_code];
            break;

    }   


    return result;  

}


@end

//
//  BMS_Communication.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "BMS_Communication.h"
#import "Util.h"

#define BMS_DEFAULT_TIME_OUT 5000
#define BMS_PHONESERVICE @"https://monitoreverywhere.com/BMS/phoneservice?"
#define BMS_CMD_PART     @"action=command&command="


#define USR_LOGIN_CMD    @"user_login"
#define USR_LOGIN_PARAM_1 @"&email="
#define USR_LOGIN_PARAM_2 @"&pass="
#define USR_LOGIN_PARAM_3 @"&device="
#define USR_LOGIN_PARAM_4 @"&app_type="
#define USR_LOGIN_PARAM_5 @"&pass_len="


#define GET_CAM_LIST_CMD @"camera_list"
#define GET_CAM_LIST_PARAM_1 @"&email="

#define ADD_CAM_CMD @"add_cam"
#define ADD_CAM_PARAM_1 @"&email="
#define ADD_CAM_PARAM_2 @"&pass="
#define ADD_CAM_PARAM_3 @"&macaddress="
#define ADD_CAM_PARAM_4 @"&cam_name="
#define ADD_CAM_PARAM_5 @"&pass_len="

#define UPDATE_CAM_CMD @"update_user_cam"
#define UPDATE_CAM_PARAM_1 @"&email="
#define UPDATE_CAM_PARAM_2 @"&macaddress="
#define UPDATE_CAM_PARAM_3 @"&cam_name="


@interface BMS_Communication : NSObject {

	id obj;
	SEL selIfSuccess; 
	SEL selIfFailure; 
	SEL selIfServerFail; 
	
	
	NSURLConnection * url_connection; 
	NSMutableData *responseData;
	NSHTTPURLResponse* httpResponse ;
	
	
}
- (id) initWithObject: (id) caller Selector: (SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr;



- (BOOL)BMS_loginWithUser:(NSString*) user_email AndPass:(NSString*) user_pass;
- (BOOL)BMS_getCameraListWithUser:(NSString *) user_email AndPass:(NSString*) user_pass;

- (BOOL)BMS_addCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name;


- (BOOL)BMS_camNameWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name;

@end

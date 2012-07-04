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


#define USR_REG_CMD @"user_registration"
#define USR_REG_PARAM_1 @"&email="
#define USR_REG_PARAM_2 @"&pass="
#define USR_REG_PARAM_3 @"&username="


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


#define DEL_CAM_CMD  @"delete_cam"
#define DEL_CAM_PARAM_1 @"&email="
#define DEL_CAM_PARAM_2 @"&macaddress="

#define GET_STREAM_MODE_CMD @"get_stream_mode"
#define GET_STREAM_MODE_PARAM_1 @"&mac="



#define GET_PORT_CMD @"get_port_info"
#define GET_PORT_PARAM_1 @"&macaddress="

#define VIEW_CAM_CMD @"view_cam"
#define VIEW_CAM_PARAM_1 @"&email="
#define VIEW_CAM_PARAM_2 @"&macaddress="

#define IS_CAM_AVAIL @"is_cam_available"
#define IS_CAM_AVAIL_PARAM_1 @"&macaddress="

#define GET_SECURITY_INFO @"get_security_info"
#define GET_SECURITY_INFO_PARAM_1 @"&email="
#define GET_SECURITY_INFO_PARAM_2 @"&pass="

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
- (BOOL)BMS_registerWithUserId:(NSString*) user_id AndPass:(NSString*) user_pass AndEmail:(NSString *) usr_email;

- (BOOL)BMS_getCameraListWithUser:(NSString *) user_email AndPass:(NSString*) user_pass;

- (BOOL)BMS_addCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name;

- (BOOL)BMS_delCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac;

- (BOOL)BMS_camNameWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name;


- (BOOL)BMS_getStreamModeWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;

- (BOOL)BMS_getHTTPRmtPortWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;

- (BOOL)BMS_viewRmtCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;

- (BOOL)BMS_isCamAvailableWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;
- (BOOL)BMS_getSecInfoWithUser:(NSString*) user_email AndPass:(NSString*) user_pass ;

@end

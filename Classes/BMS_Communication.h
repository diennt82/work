//
//  BMS_Communication.h
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "BMS_Communication.h"
#import "Util.h"

#define BMS_DEFAULT_TIME_OUT 30
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

#define GET_IMG_CMD @"get_image"
#define GET_IMG_PARAM_1 @"&macaddress="

#define RESET_USER_PASSWORD_CMD @"reset_password"
#define RESET_USER_PASSWORD_PARAM_1 @"&email="


#define GET_RELAY_KEY @"get_relaysec_info"
#define GET_RELAY_KEY_PARAM_1 @"&macaddress="


#define SEND_CTRL_CMD @"send_control_command"
#define SEND_CTRL_CMD_PARAM_1 @"&macaddress="
#define SEND_CTRL_CMD_PARAM_2 @"&channelid="
#define SEND_CTRL_CMD_PARAM_3 @"&query="


#define PUSH_REG_CMD @"register_ios_device"
#define PUSH_REG_CMD_PARAM_1 @"&email="
#define PUSH_REG_CMD_PARAM_2 @"&registrationId="

#define PUSH_UNREG_CMD @"unregister_ios_device"
#define PUSH_UNREG_CMD_PARAM_1 @"&registrationId="


#define GET_DISABLED_ALERTS_CMD @"get_disabled_alerts_ios"
#define GET_DISABLED_ALERTS_CMD_PARAM_1 @"&registrationId="
#define GET_DISABLED_ALERTS_CMD_PARAM_2 @"&mac="

#define ENABLE_ALERTS_CMD @"enable_notifications_ios"
#define ENABLE_ALERTS_CMD_PARAM_1 @"&registrationId="
#define ENABLE_ALERTS_CMD_PARAM_2 @"&mac="
#define ENABLE_ALERTS_CMD_PARAM_3 @"&alert="

#define DISABLE_ALERTS_CMD @"disable_notifications_ios"
#define DISABLE_ALERTS_CMD_PARAM_1 @"&registrationId="
#define DISABLE_ALERTS_CMD_PARAM_2 @"&mac="
#define DISABLE_ALERTS_CMD_PARAM_3 @"&alert="


//// NEW SET of PUSH NOTIFICATION 

#define ENABLE_ALERTS_U_CMD @"enable_notifications"
#define ENABLE_ALERTS_U_CMD_PARAM_1 @"&username="
#define ENABLE_ALERTS_U_CMD_PARAM_2 @"&mac="
#define ENABLE_ALERTS_U_CMD_PARAM_3 @"&alert="


#define DISABLE_ALERTS_U_CMD @"disable_notifications"
#define DISABLE_ALERTS_U_CMD_PARAM_1 @"&username="
#define DISABLE_ALERTS_U_CMD_PARAM_2 @"&mac="
#define DISABLE_ALERTS_U_CMD_PARAM_3 @"&alert="


#define GET_DISABLED_ALERTS_U_CMD @"get_disabled_alerts"
#define GET_DISABLED_ALERTS_U_CMD_PARAM_1 @"&username="
#define GET_DISABLED_ALERTS_U_CMD_PARAM_2 @"&mac="



@interface BMS_Communication : NSObject {

	id obj;
	SEL selIfSuccess; 
	SEL selIfFailure; 
	SEL selIfServerFail; 
	
	
	NSURLConnection * url_connection; 
	NSMutableData *responseData;
	NSHTTPURLResponse* httpResponse ;
    NSString * basicAuthenUser, * basicAuthenPass;
	
	
}

@property (nonatomic, assign) id obj; 


+(NSString*) getLocalizedMessageForError:(int) err;

- (id) initWithObject: (id) caller Selector: (SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr;



- (BOOL)BMS_loginWithUser:(NSString*) user_email AndPass:(NSString*) user_pass;
- (BOOL)BMS_registerWithUserId:(NSString*) user_id AndPass:(NSString*) user_pass AndEmail:(NSString *) usr_email;

- (BOOL)BMS_getCameraListWithUser:(NSString *) user_email AndPass:(NSString*) user_pass;

- (NSData *)BMS_getCameraListBlockedWithUser:(NSString *) user_email AndPass:(NSString*) user_pass;

- (BOOL)BMS_addCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name;

- (BOOL)BMS_delCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac;

- (BOOL)BMS_camNameWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac camName:(NSString*) name;


- (BOOL)BMS_getStreamModeWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;

- (BOOL)BMS_getHTTPRmtPortWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;

- (BOOL)BMS_viewRmtCamWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;

- (BOOL)BMS_isCamAvailableWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;
- (BOOL)BMS_getSecInfoWithUser:(NSString*) user_email AndPass:(NSString*) user_pass ;


- (NSData *)BMS_getCameraSnapshotBlockedWithUser:(NSString *) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) mac ;
- (BOOL)BMS_resetUserPassword:(NSString*) user_email;

-(BOOL) BMS_getRelaySecWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) macWithColon ;



-(BOOL) BMS_sendCmdViaServeNonBlockedWithUser:(NSString*) user_email
                                      AndPass:(NSString*) user_pass
                                      macAddr:(NSString *) macWithColon
                                      channId:(NSString*) channelId
                                      command:(NSString *)udt_command;

- (NSData *) BMS_getRelaySecBlockedWithUser:(NSString*) user_email AndPass:(NSString*) user_pass macAddr:(NSString *) macWithColon ;

- (NSData *) BMS_sendCmdViaServeBlockedWithUser:(NSString*) user_email 
                                        AndPass:(NSString*) user_pass 
                                        macAddr:(NSString *) macWithColon channId:(NSString*) channelId command:(NSString *)udt_command;

- (NSData *) BMS_sendPushRegistrationBlockWithUser:(NSString*) user_email 
                                           AndPass:(NSString*) user_pass 
                                             regId:(NSString *) regId;



- (NSData *) BMS_sendPushUnRegistrationBlockWithUser:(NSString*) user_email 
                                           AndPass:(NSString*) user_pass 
                                             regId:(NSString *) regId;



- (NSData *) BMS_getDisabledAlertBlockWithUser:(NSString*) user_email 
                                       AndPass:(NSString*) user_pass 
                                         regId:(NSString *) regId
                                         ofMac:(NSString *) macWColon;
- (NSData *) BMS_enabledAlertBlockWithUser:(NSString*) user_email 
                                   AndPass:(NSString*) user_pass 
                                     regId:(NSString *) regId
                                     ofMac:(NSString *) macWColon
                                 alertType:(NSString *) alertType;



- (NSData *) BMS_getDisabledAlertBlockWithUser_1:(NSString*) user_email 
                                         AndPass:(NSString*) user_pass 
                                           ofMac:(NSString *) macWColon;

- (NSData *) BMS_enabledAlertBlockWithUser_1:(NSString*) user_email 
                                     AndPass:(NSString*) user_pass 
                                       ofMac:(NSString *) macWColon
                                   alertType:(NSString *) alertType;



- (NSData *) BMS_disabledAlertBlockWithUser_1:(NSString*) user_email 
                                      AndPass:(NSString*) user_pass 
                                        ofMac:(NSString *) macWColon
                                    alertType:(NSString *) alertType;


@end

//
//  MyMBS_Communication.h
//  MBP_ios
//
//  Created by NxComm on 6/8/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BMS_DEFAULT_TIME_OUT 30.0f

#define BMS_PHONESERVICE @"http://api.simplimonitor.com"

//~USER
#define USR_REG_CMD @"/v1/users/register.json"
#define USR_REG_PARAM_1 @"\"name\""
#define USR_REG_PARAM_2 @"\"email\""
#define USR_REG_PARAM_3 @"\"password\""
#define USR_REG_PARAM_4 @"\"password_confirmation\""
//{"name":"luan3","email":"luan3@com.vn","password":"qwe","password_confirmation":"qwe"}

#define USR_LOGIN_CMD    @"/v1/users/create_token.json"
#define USR_LOGIN_PARAM_1 @"\"login\""
#define USR_LOGIN_PARAM_2 @"\"password\""
//{"login":"luan9","password":"qwe"}

#define USR_LOGOUT_CMD @"v1/users/remove_token.json?suppress_response_codes=1&api_key="
//~/v1/users/remove_token.json?suppress_response_codes=1&api_key=uMsu5fkfSH9wJmLYznex

#define USR_ME_CMD @"/v1/users/me.json?suppress_response_codes=1&api_key="

#define USR_UPDATE_CMD @"/v1/users/me.json?suppress_response_codes=1"
#define USR_UPDATE_PARAM_1 @"&name="
#define USR_UPDATE_PARAM_2 @"&email="
#define USR_UPDATE_PARAM_3 @"&api_key="
//~/v1/users/me.json?suppress_response_codes=1&name=luan3&email=luan32%40com.vn&api_key=oZYNNw8ykhyVQYMNLRep

#define USR_CHANGE_PASS_CMD @"/v1/users/me/change_password.json?suppress_response_codes=1"
#define USR_CHANGE_PASS_PARAM_1 @"&password="
#define USR_CHANGE_PASS_PARAM_2 @"&password_confirmation="
#define USR_CHANGE_PASS_PARAM_3 @"&api_key="
//~/v1/users/me/change_password.json?suppress_response_codes=1&password=qwe&password_confirmation=qwe&api_key=4xyVHYPshznDSN1q5PYU

#define USR_RESET_PASS_CMD @"/v1/users/reset_password.json?api_key="
#define USR_RESET_PASS_PARAM_1 @"\"login\""
//~/v1/users/reset_password.json?api_key=4xyVHYPshznDSN1q5PYU

//~End USER
// ~DEVICES
#define DEV_REG_CMD @"/v1/devices/register.json?api_key="
#define DEV_REG_PARAM_1 @"\"name\""
#define DEV_REG_PARAM_2 @"\"registration_id\""
#define DEV_REG_PARAM_3 @"\"device_type\""
#define DEV_REG_PARAM_4 @"\"model\""
#define DEV_REG_PARAM_5 @"\"mode\""
#define DEV_REG_PARAM_6 @"\"firmware_version\""
#define DEV_REG_PARAM_7 @"\"time_zone\""
//~/v1/devices/register.json?api_key=mLz2THpyXyAWFVD2Tqsm
//{"name":"luan01", "registration_id":"asasasasas12","device_type":"camera", "model":"blink1","mode":"stun","firmware_version":"08_045","time_zone":"+0530"}

#define DEV_OWN_CMD @"/v1/devices/own.json?suppress_response_codes=1&api_key="

#define DEV_SHARED_CMD @"/v1/devices/shared.json?suppress_response_codes=1&api_key="

#define DEV_PUBLIC_CMD @"/v1/devices/public.json?suppress_response_codes=1&api_key="

#define DEV_BASIC_CMD @"/v1/devices/"
#define DEV_BASIC_CMD_1 @".json?suppress_response_codes=1&api_key="

#define DEV_CAPABILTY_CDM @"/v1/devices/"
#define DEV_CAPABILTY_CDM_1 @"/capability.json?suppress_response_codes=1&api_key="

#define DEV_SEND_COMMAND_CMD @"/v1/devices/"
#define DEV_SEND_COMMAND_CMD_1 @"/send_command.json?api_key="
#define DEV_SEND_COMMAND_PARAM_1 @"\"registration_id\""
#define DEV_SEND_COMMAND_PARAM_2 @"\"command\""
//{"registration_id":"asasasasas03", "command":"action=command&command=melody1"}

#define DEV_CREATE_SES_CMD @"/v1/devices/"
#define DEV_CREATE_SES_CMD_1 @"/send_command.json?api_key="
#define DEV_CREATE_SES_PARAM_1 @"\"registration_id\""
#define DEV_CREATE_SES_PARAM_2 @"\"client_type\""
#define CLIENT_TYPE @"IOS"
//~/v1/devices/asasasasas04/create_session.json?api_key=ghybzPaxVQ3HtcqH3eMy
//{"registration_id":"asasasasas04", "client_type":"browser"}

#define DEV_CLOSE_SES_CMD @"/v1/devices/"
#define DEV_CLOSE_SES_CMD_1 @"/close_session.json?suppress_response_codes=1"
#define DEV_CLOSE_SES_PARAM_1 @"&channed_id="
#define DEV_CLOSE_SES_PARAM_2 @"&api_key="
//~/v1/devices/asasasasas04/close_session.json?suppress_response_codes=1&channed_id=asd&api_key=ghybzPaxVQ3HtcqH3eMy

#define DEV_DEL_CMD @"/v1/devices/"
#define DEV_DEL_CMD_1 @".json?suppress_response_codes=1&api_key="
// ~/v1/devices/asasasasas04.json?suppress_response_codes=1&api_key=ghybzPaxVQ3HtcqH3eMy

#define DEV_UPDATE_BASIC_CMD @"/v1/devices/"
#define DEV_UPDATE_BASIC_CMD_1 @"/close_session.json?suppress_response_codes=1"
#define DEV_UPDATE_BASIC_PARAM_1 @"&name="
#define DEV_UPDATE_BASIC_PARAM_2 @"&access_token="
#define DEV_UPDATE_BASIC_PARAM_3 @"&api_key="
//~/v1/devices/asasasasas04/basic.json?suppress_response_codes=1&name=a12345&access_token=ghybzPaxVQ3HtcqH3eMy&api_key=ghybzPaxVQ3HtcqH3eMy

#define DEV_AVAILABLE_CMD @"/v1/devices/"
#define DEV_AVAILABLE_CMD_1 @"/is_available.json?api_key="
//~/v1/devices/asasasasas04/is_available.json?api_key=kCBb6pxjE5fRbpxHYUEa

#define DEV_REQUEST_RECOVERY_CMD @"/v1/devices/"
#define DEV_REQUEST_RECOVERY_CMD_1 @"/request_recovery.json?api_key="
#define DEV_REQUEST_RECOVERY_PARAM_1 @"\"recovery_type\""
#define DEV_REQUEST_RECOVERY_PARAM_2 @"\"status\""
//~/v1/devices/asasasasas04/request_recovery.json?api_key=kCBb6pxjE5fRbpxHYUEa
//{"recovery_type":"upnp","status":"recoverable"}

#define DEV_PLAYBACK_CMD @"/v1/devices/"
#define DEV_PLAYBACK_CMD_1 @"/playback.json?suppress_response_codes=1&api_key="
//~/v1/devices/asasasasas04/playback.json?suppress_response_codes=1&api_key=kCBb6pxjE5fRbpxHYUEa

#define DEV_PORT_OPEN_CMD @"/v1/devices/"
#define DEV_PORT_OPEN_CMD_1 @"/is_port_open.json?api_key="
//~/v1/devices/asasasasas04/is_port_open.json?api_key=kCBb6pxjE5fRbpxHYUEa
//{"port":"1000"}
// ~End DEVICES


@interface MyMBS_Communication : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (retain, nonatomic) NSMutableData *responseDict;
@property (retain, nonatomic) NSURLConnection *urlConnection;
@property (retain, nonatomic) NSString *apiKey;

@property (nonatomic, assign) id obj;

- (id) initWithObject: (id) caller Selector: (SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr;

//User
- (BOOL)registerAccount: (NSString *)name andEmail: (NSString *)email andPassword: (NSString *)password andPasswordConfirmation: (NSString *)passwordConfirm;

- (BOOL)loginWithUsername: (NSString *)login andPassword: (NSString *)passwrod;

- (BOOL)logout;

- (BOOL)getUserInfo;

- (BOOL)updateUserInfoWithNewUsername: (NSString *)newName andNewEmail: (NSString *)newEmail;

- (BOOL)changePasswordWithNewPassword: (NSString *)newPassword andPasswordConfirm: (NSString *)passwordConfirm;

- (BOOL)resetPasswordWithLogin: (NSString *)login;

//Device
- (BOOL)registerDeviceWithUsername: (NSString *)name andRegId: (NSString *)registrationId andDeviceType: (NSString *)deviceType andModel: (NSString *)model andMode: (NSString *)mode andFwVersion: (NSString *)fwVersion andTimeZone: (NSString *)timeZone;

- (BOOL)getAllDevices;

- (BOOL)getAllSharedDevices;

- (BOOL)getAllPublicDevices;

- (BOOL)getDeviceBasicInfoWithRegistrationId: (NSString *)registrationId;

- (BOOL)getDeviceCapabilityInfoWithRegistrationId: (NSString *)registrationId;

- (BOOL)sendCommandWithRegistrationId: (NSString *)registrationId andCommand: (NSString *)command;

- (BOOL)createSessionWithRegistrationId: (NSString *)registrationId andClientType: (NSString *)clientType;

- (BOOL)closeSessionWithRegistrationId: (NSString *)registrationId;

- (BOOL)closeSessionWithRegistrationId:(NSString *)registrationId andChannedId: (NSString *)channedId;

- (BOOL)deleteDeviceWithRegistrationId: (NSString *)registrationId;

- (BOOL)updateDeviceBasicInfoWithRegistrationId: (NSString *)registrationId andName: (NSString *)newName andAccessToken: (NSString *)accessToken;

- (BOOL)checkDeviceIsAvailableWithRegistrationId: (NSString *)registrationId;

- (BOOL)requestRecoveryForDeviceWith:(NSString *)registrationId andRecoveryType: (NSString *)recoveryType andStatus: (NSString *)status;

- (BOOL)getAllRecordedFilesWithRegistrationId: (NSString *)registrationId;

- (BOOL)checkDevicePortIsOpenWithRegistration: (NSString *)registrationId;

@end

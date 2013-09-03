//
//  MyMBS_Communication.h
//  MBP_ios
//
//  Created by NxComm on 6/8/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JSON_FLAG 1
#define BMS_JSON_DEFAULT_TIME_OUT 30.0f

//#define BMS_JSON_PHONESERVICE @"http://api.simplimonitor.com"
//#define BMS_JSON_PHONESERVICE @"http://dev.simplimonitor.com"
#define BMS_JSON_PHONESERVICE @"http://demo.simplimonitor.com"

//~USER
#define USER_REG_CMD @"/v1/users/register.json"
#define USER_REG_PARAM_1 @"name"
#define USER_REG_PARAM_2 @"email"
#define USER_REG_PARAM_3 @"password"
#define USER_REG_PARAM_4 @"password_confirmation"
//{"name":"luan3","email":"luan3@com.vn","password":"qwe","password_confirmation":"qwe"}

#define USER_AUTHENTICATION_TOKEN_CMD @"/v1/users/authentication_token.json?"
#define USER_AUTHENTICATION_TOKEN_PARAM_1 @"login=%@"
#define USER_AUTHENTICATION_TOKEN_PARAM_2 @"&password=%@"
//~/v1/users/authentication_token.json?login=luan00&password=qwe

#define USER_ME_CMD @"/v1/users/me.json?api_key="

#define USER_UPDATE_CMD @"/v1/users/me.json?"
#define USER_UPDATE_PARAM_1 @"name=%@"
#define USER_UPDATE_PARAM_2 @"&email=%@"
#define USER_UPDATE_PARAM_3 @"&api_key=%@"
//~/v1/users/me.json?name=luan3&email=luan32%40com.vn&api_key=oZYNNw8ykhyVQYMNLRep

#define USER_CHANGE_PASS_CMD @"/v1/users/me/change_password.json?"
#define USER_CHANGE_PASS_PARAM_1 @"password=%@"
#define USER_CHANGE_PASS_PARAM_2 @"&password_confirmation=%@"
#define USER_CHANGE_PASS_PARAM_3 @"&api_key=%@"
//~/v1/users/me/change_password.json?password=qwe&password_confirmation=qwe&api_key=4xyVHYPshznDSN1q5PYU

#define USER_RESET_PASS_CMD @"/v1/users/reset_password.json"
#define USER_RESET_PASS_PARAM_1 @"login"
//~/v1/users/reset_password.json?api_key=4xyVHYPshznDSN1q5PYU

//~End USER
// ~DEVICES
#define DEV_REG_CMD @"/v1/devices/register.json?api_key=%@"
#define DEV_REG_PARAM_1 @"name"
#define DEV_REG_PARAM_2 @"registration_id"
#define DEV_REG_PARAM_3 @"device_type"
#define DEV_REG_PARAM_4 @"model"
#define DEV_REG_PARAM_5 @"mode"
#define DEV_REG_PARAM_6 @"firmware_version"
#define DEV_REG_PARAM_7 @"time_zone"
//~/v1/devices/register.json?api_key=mLz2THpyXyAWFVD2Tqsm
//{"name":"luan01", "registration_id":"asasasasas12","device_type":"camera", "model":"blink1","mode":"stun","firmware_version":"08_045","time_zone":"+0530"}

#define DEV_OWN_CMD @"/v1/devices/own.json?api_key="

#define DEV_BASIC_CMD @"/v1/devices/%@.json?api_key=%@"

#define DEV_SEND_COMMAND_CMD @"/v1/devices/%@/send_command.json?api_key=%@"
#define DEV_SEND_COMMAND_PARAM_1 @"registration_id"
#define DEV_SEND_COMMAND_PARAM_2 @"command"
//{"registration_id":"asasasasas03", "command":"action=command&command=melody1"}

#define DEV_CREATE_SESSION_CMD @"/v1/devices/%@/create_session.json?api_key=%@"
#define DEV_CREATE_SESSION_PARAM_1 @"registration_id"
#define DEV_CREATE_SESSION_PARAM_2 @"client_type"
//~/v1/devices/asasasasas04/create_session.json?api_key=ghybzPaxVQ3HtcqH3eMy
//{"registration_id":"asasasasas04", "client_type":"browser"}

#define DEV_DEL_CMD @"/v1/devices/%@.json?api_key=%@"
// ~/v1/devices/asasasasas04.json?api_key=ghybzPaxVQ3HtcqH3eMy

#define DEV_UPDATE_BASIC_CMD @"/v1/devices/%@/basic.json?"
#define DEV_UPDATE_BASIC_PARAM_1 @"name=%@"
#define DEV_UPDATE_BASIC_PARAM_2 @"&access_token=%@"
#define DEV_UPDATE_BASIC_PARAM_3 @"&api_key=%@"
//~/v1/devices/asasasasas04/basic.json?suppress_response_codes=1&name=a12345&access_token=ghybzPaxVQ3HtcqH3eMy&api_key=ghybzPaxVQ3HtcqH3eMy

#define DEV_SETTINGS_CMD @"/v1/devices/%@/settings.json?api_key=%@"
#define DEV_SETTINGS_PARAM_1 @"api_key"
#define DEV_SETTINGS_PARAM_2 @"settings"
//~/v1/devices/asasasasas05/settings.json?api_key=MxpdLxwnSeShxqidCw8h

#define DEV_AVAILABLE_CMD @"/v1/devices/%@/is_available.json?api_key=%@"
//~/v1/devices/asasasasas04/is_available.json?api_key=kCBb6pxjE5fRbpxHYUEa

#define DEV_REQUEST_RECOVERY_CMD @"/v1/devices/%@/request_recovery.json?api_key=%@"
#define DEV_REQUEST_RECOVERY_PARAM_1 @"recovery_type"
#define DEV_REQUEST_RECOVERY_PARAM_2 @"status"
//~/v1/devices/asasasasas04/request_recovery.json?api_key=kCBb6pxjE5fRbpxHYUEa
//{"recovery_type":"upnp","status":"recoverable"}

#define DEV_PLAYLIST_CMD @"/v1/devices/%@/playlist.json?api_key=%@"
//~/v1/devices/asasasasas04/playlist.json?api_key=kCBb6pxjE5fRbpxHYUEa

// ~End DEVICES

// §APP
#define APP_REG_CMD @"/v1/apps/register.json?api_key=%@"
#define APP_REG_PARAM_1 @"name"
#define APP_REG_PARAM_2 @"device_code"
//~/v1/apps/register.json?api_key=6zzxoJDas9cigxgrU89Q
//{"name":"somethingL","device_code":"jalkjkjlksjljsalkjflajflajla"}

#define APP_REG_NOTIFICATIONS_CMD @"/v1/apps/%@/register_notifications.json?api_key=%@"
#define APP_REG_NOTIFICATIONS_PARAM_1 @"id"
#define APP_REG_NOTIFICATIONS_PARAM_2 @"notification_type"
#define APP_REG_NOTIFICATIONS_PARAM_3 @"registration_id"
// {"id":"265","notification_type":"apns", "registration_id":"dadafafafafafaaf"}
// §/v1/apps/264/register_notifications.json?api_key=6zzxoJDas9cigxgrU89Q

#define APP_UNREG_NOTIFICATIONS_CMD @"/v1/apps/%@/unregister_notifications.json?api_key=%@"
//§/v1/apps/264/unregister_notifications.json?api_key=6zzxoJDas9cigxgrU89Q

#define APP_UPDATE_CMD @"/v1/apps/%@.json?"
#define APP_UPDATE_PARAM_1 @"name=%@"
#define APP_UPDATE_PARAM_2 @"&api_key=%@"
// §/v1/apps/264.json?name=abcnd&api_key=6zzxoJDas9cigxgrU89Q

#define APP_DEL_CMD @"/v1/apps/%@/unregister.json?api_key=%@"
// § /v1/apps/268/unregister.json?api_key=6zzxoJDas9cigxgrU89Q

#define APP_SETTINGS_CMD @"/v1/apps/%@/notification_settings.json?api_key=%@"
#define APP_SETTINGS_PARAM_1 @"api_key"
#define APP_SETTINGS_PARAM_2 @"settings"
// §/v1/apps/{id}/notification_settings.json
// §End APP


@interface BMS_JSON_Communication : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (retain, nonatomic) NSMutableDictionary *responseDict;
@property (retain, nonatomic) NSURLConnection *urlConnection;
//@property (retain, nonatomic) NSString *apiKey;

@property (nonatomic, assign) id obj;

- (id) initWithObject: (id) caller Selector: (SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr;

//User
- (BOOL)registerAccountWithUsername: (NSString *)name andEmail: (NSString *)email andPassword: (NSString *)password andPasswordConfirmation: (NSString *)passwordConfirm;

- (BOOL)loginWithLogin: (NSString *)login andPassword: (NSString *)pass;

- (BOOL)getUserInfoWithApiKey: (NSString *)apiKey;

- (BOOL)updateUserInfoWithNewUsername: (NSString *)newName andNewEmail: (NSString *)newEmail andApiKey: (NSString *)apiKey;

- (BOOL)changePasswordWithNewPassword: (NSString *)newPassword andPasswordConfirm: (NSString *)passwordConfirm andApiKey: (NSString *)apiKey;

- (BOOL)resetPasswordWithLogin: (NSString *)login;

//Device
- (BOOL)registerDeviceWithDeviceName: (NSString *)deviceName andRegId: (NSString *)registrationId andDeviceType: (NSString *)deviceType andModel: (NSString *)model andMode: (NSString *)mode andFwVersion: (NSString *)fwVersion andTimeZone: (NSString *)timeZone andApiKey: (NSString *)apiKey;

- (BOOL)getAllDevicesWithApiKey: (NSString *)apiKey;

- (NSDictionary *)getAllDevicesBlockedWithApiKey: (NSString *)apiKey;

- (BOOL)getDeviceBasicInfoWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey;

- (BOOL)sendCommandWithRegistrationId: (NSString *)registrationId andCommand: (NSString *)command andApiKey: (NSString *)apiKey;

- (BOOL)createSessionWithRegistrationId: (NSString *)registrationId andClientType: (NSString *)clientType andApiKey: (NSString *)apiKey;

- (BOOL)deleteDeviceWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey;

- (BOOL)updateDeviceBasicInfoWithRegistrationId: (NSString *)registrationId andName: (NSString *)newName andAccessToken: (NSString *)accessToken andApiKey: (NSString *)apiKey;

- (BOOL)settingDeviceWithRegistrationId: (NSString *)regId andApiKey: (NSString *)apiKey andSettings: (NSArray *)settingsArr;

- (BOOL)checkDeviceIsAvailableWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey;

- (BOOL)requestRecoveryForDeviceWithRegistrationId:(NSString *)registrationId andRecoveryType: (NSString *)recoveryType andStatus: (NSString *)status andApiKey: (NSString *)apiKey;

- (BOOL)getAllRecordedFilesWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey;

// App
- (BOOL)registerAppWithName: (NSString *)appName andDeviceCode: (NSString *)deviceCode andApiKey: (NSString *)apiKey;

- (NSDictionary *)registerAppBlockedWithName: (NSString *)appName andDeviceCode: (NSString *)deviceCode andApiKey: (NSString *)apiKey;

- (BOOL)registerPushNotificationsWithAppId: (NSString *)appId andNotificationType: (NSString *)notificationType andDeviceToken: (NSString *)deviceToken andApiKey: (NSString *)apiKey;

- (NSDictionary *)registerPushNotificationsBlockedWithAppId: (NSString *)appId andNotificationType: (NSString *)notificationType andDeviceToken: (NSString *)deviceToken andApiKey: (NSString *)apiKey;

- (BOOL)unregisterNotificationsWithAppId: (NSString *)appId andApiKey: (NSString *)apiKey;

- (BOOL)updateAppWithAppId: (NSString *)appId andAppName: (NSString *)appName andApiKey: (NSString *)apiKey;

- (BOOL)deleteAppWithAppId: (NSString *)appId andApiKey: (NSString *)apiKey;

- (NSDictionary *)deleteAppBlockedWithAppId: (NSString *)appId andApiKey: (NSString *)apiKey;

- (BOOL)settingAppWithAppId: (NSString *)appId andApiKey: (NSString *)apiKey andSettings: (NSArray *)settingsArr;
@end

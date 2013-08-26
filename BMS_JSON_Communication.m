//
//  MyMBS_Communication.m
//  MBP_ios
//
//  Created by NxComm on 6/8/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "BMS_JSON_Communication.h"

@interface BMS_JSON_Communication ()
{
    SEL selIfSuccess;
	SEL selIfFailure;
	SEL selIfServerFail;
}

@property (retain, nonatomic) NSHTTPURLResponse* httpResponse;
@property (retain, nonatomic) NSMutableData *responseData;
//@property (retain, nonatomic) NSString *username;
//@property (retain, nonatomic) NSString *password;

@end

@implementation BMS_JSON_Communication

- (id)  initWithObject: (id) caller Selector:(SEL) success FailSelector: (SEL) fail ServerErr:(SEL) serverErr
{
	[super init];
	_obj = caller;
	selIfSuccess = success;
	selIfFailure = fail;
	selIfServerFail = serverErr;
	
	return self;
}

#pragma mark - User
- (BOOL)registerAccount: (NSString *)name andEmail: (NSString *)email andPassword: (NSString *)password andPasswordConfirmation: (NSString *)passwordConfirm
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BMS_JSON_PHONESERVICE, USER_REG_CMD]]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        //{"name":"luan3","email":"luan3@com.vn","password":"qwe","password_confirmation":"qwe"}
        NSDictionary *jsonDictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      name,     USER_REG_PARAM_1,
                                      email,    USER_REG_PARAM_2,
                                      password, USER_REG_PARAM_3,
                                      passwordConfirm, USER_REG_PARAM_4,
                                      nil];
        
        NSLog(@"jsonDict = %@", jsonDictInfo);
        // convert to data
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:jsonDictInfo
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:nil];
        request.HTTPBody = requestBodyData;
        
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)loginWithLogin: (NSString *)login andPassword: (NSString *)pass
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_JSON_PHONESERVICE, USER_AUTHENTICATION_TOKEN_CMD];
        requestString = [requestString stringByAppendingFormat:USER_AUTHENTICATION_TOKEN_PARAM_1, login];
        requestString = [requestString stringByAppendingFormat:USER_AUTHENTICATION_TOKEN_PARAM_2, pass];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)getUserInfoWithApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", BMS_JSON_PHONESERVICE, USER_ME_CMD, apiKey]]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)updateUserInfoWithNewUsername: (NSString *)newName andNewEmail: (NSString *)newEmail andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_JSON_PHONESERVICE, USER_UPDATE_CMD];
        requestString = [requestString stringByAppendingFormat:USER_UPDATE_PARAM_1, newName];
        requestString = [requestString stringByAppendingFormat:USER_UPDATE_PARAM_2, newEmail];
        requestString = [requestString stringByAppendingFormat:USER_UPDATE_PARAM_3, apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"PUT";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)changePasswordWithNewPassword: (NSString *)newPassword andPasswordConfirm: (NSString *)passwordConfirm andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_JSON_PHONESERVICE, USER_CHANGE_PASS_CMD];
        requestString = [requestString stringByAppendingFormat:USER_CHANGE_PASS_PARAM_1, newPassword];
        requestString = [requestString stringByAppendingFormat:USER_CHANGE_PASS_PARAM_2, passwordConfirm];
        requestString = [requestString stringByAppendingFormat:USER_CHANGE_PASS_PARAM_3, apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"PUT";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)resetPasswordWithLogin: (NSString *)login andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_JSON_PHONESERVICE, USER_RESET_PASS_CMD];
        requestString = [requestString stringByAppendingFormat:@"%@", apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        //{"login":"luan"}
        NSDictionary *jsonDictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      login, USER_RESET_PASS_PARAM_1,
                                      nil];
        
        NSLog(@"jsonDict = %@", jsonDictInfo);
        // convert to data
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:jsonDictInfo
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:nil];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return  TRUE;
}

#pragma mark - Device

- (BOOL)registerDeviceWithDeviceName: (NSString *)deviceName andRegId: (NSString *)registrationId andDeviceType: (NSString *)deviceType andModel: (NSString *)model andMode: (NSString *)mode andFwVersion: (NSString *)fwVersion andTimeZone: (NSString *)timeZone andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_REG_CMD, apiKey];
        NSLog(@"request = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        //{"name":"luan01", "registration_id":"asasasasas12","device_type":"camera", "model":"blink1","mode":"stun","firmware_version":"08_045","time_zone":"+0530"}
        NSDictionary *jsonDictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      deviceName,       DEV_REG_PARAM_1,
                                      registrationId,   DEV_REG_PARAM_2,
                                      deviceType,       DEV_REG_PARAM_3,
                                      model,            DEV_REG_PARAM_4,
                                      mode,             DEV_REG_PARAM_5,
                                      fwVersion,        DEV_REG_PARAM_6,
                                      timeZone,         DEV_REG_PARAM_7,
                                      nil];
        
        NSLog(@"jsonDict = %@", jsonDictInfo);
        // convert to data
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:jsonDictInfo
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:nil];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)getAllDevicesWithApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", BMS_JSON_PHONESERVICE, DEV_OWN_CMD, apiKey]]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)getDeviceBasicInfoWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_BASIC_CMD, registrationId, apiKey];
        
        NSLog(@"%@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)sendCommandWithRegistrationId: (NSString *)registrationId andCommand: (NSString *)command andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_SEND_COMMAND_CMD, registrationId, apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        //{"registration_id":"asasasasas03", "command":"action=command&command=melody1"}
        NSDictionary *jsonDictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      registrationId, DEV_SEND_COMMAND_PARAM_1,
                                      command,        DEV_SEND_COMMAND_PARAM_2,
                                      nil];
        
        NSLog(@"jsonDict = %@", jsonDictInfo);
        // convert to data
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:jsonDictInfo
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:nil];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)createSessionWithRegistrationId: (NSString *)registrationId andClientType: (NSString *)clientType andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_CREATE_SESSION_CMD, registrationId, apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        //{"registration_id":"asasasasas04", "client_type":"browser"}
        NSDictionary *jsonDictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      registrationId, DEV_CREATE_SESSION_PARAM_1,
                                      clientType,     DEV_CREATE_SESSION_PARAM_2,
                                      nil];
        
        NSLog(@"jsonDict = %@", jsonDictInfo);
        // convert to data
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:jsonDictInfo
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:nil];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)deleteDeviceWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_DEL_CMD, registrationId, apiKey];
        
        NSLog(@"request string = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"DELETE";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)updateDeviceBasicInfoWithRegistrationId: (NSString *)registrationId andName: (NSString *)newName andAccessToken: (NSString *)accessToken andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_UPDATE_BASIC_CMD, registrationId];
        requestString = [requestString stringByAppendingFormat:DEV_UPDATE_BASIC_PARAM_1, newName];
        requestString = [requestString stringByAppendingFormat:DEV_UPDATE_BASIC_PARAM_2, accessToken];
        requestString = [requestString stringByAppendingFormat:DEV_UPDATE_BASIC_PARAM_3, apiKey];
        
        NSLog(@"request string = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"PUT";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)settingDeviceWithRegistrationId: (NSString *)regId andApiKey: (NSString *)apiKey andSettings: (NSArray *)settingsArr
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_SETTINGS_CMD, regId, apiKey];
        
        NSLog(@"request = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"PUT";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        /*NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\",%@:\"%@\"}", DEV_CREATE_SESSION_PARAM_1, registrationId, DEV_CREATE_SESSION_PARAM_2, clientType];
         NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
         request.HTTPBody = requestBodyData;
         */
        NSDictionary *jsonDictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      apiKey, DEV_SETTINGS_PARAM_1,
                                      settingsArr, DEV_SETTINGS_PARAM_2,
                                      nil];
        NSLog(@"jsonDict = %@", jsonDictInfo);
        // convert to data
        NSError *error = nil;
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:jsonDictInfo
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:&error];
        request.HTTPBody = requestBodyData;
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)checkDeviceIsAvailableWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_AVAILABLE_CMD, registrationId, apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //BodyRequest is empty?
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)requestRecoveryForDeviceWithRegistrationId:(NSString *)registrationId andRecoveryType: (NSString *)recoveryType andStatus: (NSString *)status andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_REQUEST_RECOVERY_CMD, registrationId, apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        //{"recovery_type":"upnp","status":"recoverable"}
        NSDictionary *jsonDictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      recoveryType, DEV_REQUEST_RECOVERY_PARAM_1,
                                      status,       DEV_REQUEST_RECOVERY_PARAM_2,
                                      nil];
        NSLog(@"jsonDict = %@", jsonDictInfo);
        // convert to data
        NSError *error = nil;
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:jsonDictInfo
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:&error];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)getAllRecordedFilesWithRegistrationId: (NSString *)registrationId andApiKey: (NSString *)apiKey
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@", BMS_JSON_PHONESERVICE];
        requestString = [requestString stringByAppendingFormat:DEV_PLAYLIST_CMD, registrationId, apiKey];
        
        NSLog(@"%@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_JSON_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

#pragma mark - NSURLContectionDelegate, NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    NSLog(@"failed with error: %@", error);
	
	if ([self.obj respondsToSelector:selIfServerFail])
    {
        [self.obj performSelector:selIfServerFail withObject:nil ];
    }
    else
    {
        NSLog(@"Failed to call selIfServerFail..silence return");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"httpResponse.statusCode = %d", self.httpResponse.statusCode);
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.responseData != nil) {
        [self.responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.responseData != nil)
	{
		//NSString *txt = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
        //NSLog(@"%@", txt);
        
		if (self.obj == nil)
        {
            NSLog(@"obj = nil ");
            return;
            
        }
        
        if (0 < self.httpResponse.statusCode && self.httpResponse.statusCode < 400)
        {
            if ([self.obj respondsToSelector:selIfSuccess])
            {
                NSError *error = nil;
                self.responseDict = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:self.responseData
                                                                                                           options:kNilOptions
                                                                                                             error:&error]];
                if (nil == error) {
                    [self.obj performSelector:selIfSuccess withObject:self.responseDict];
                }
            }
            else
            {
                NSLog(@"Failed to call selIfSuccess...silence return");
            }
        }
        else if (400 <= self.httpResponse.statusCode && self.httpResponse.statusCode < 500)
        {
            if ([self.obj respondsToSelector:selIfFailure])
            {
                NSError *error = nil;
                self.responseDict = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:self.responseData
                                                                                                           options:kNilOptions
                                                                                                             error:&error]];
                if (nil == error) {
                    [self.obj performSelector:selIfFailure withObject:self.responseDict];
                }
            }
            else
            {
                NSLog(@"Failed to call selfIfFailure...silence return");
            }
        }
	}
}

- (void)fetchedData:(NSData *)responseData
{
    NSError *error = nil;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
    NSDictionary *data = nil;
    
    NSInteger statusCode = [[jsonData objectForKey:@"status"] intValue];
    if (statusCode == 200) {
        data = [NSDictionary dictionary];
        data = [jsonData objectForKey:@"data"];
        
        //self.username = [data objectForKey:@"name"];
    }
    
    NSLog(@"data: %@", data);
}

@end

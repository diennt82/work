//
//  MyMBS_Communication.m
//  MBP_ios
//
//  Created by NxComm on 6/8/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "MyMBS_Communication.h"

@interface MyMBS_Communication ()
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

@implementation MyMBS_Communication

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
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, USR_REG_CMD]]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\",%@:\"%@\",%@:\"%@\",%@:\"%@\"}", USR_REG_PARAM_1, name, USR_REG_PARAM_2, email, USR_REG_PARAM_3, password, USR_REG_PARAM_4, passwordConfirm];
        NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)loginWithUsername: (NSString *)login andPassword: (NSString *)passwrod
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, USR_LOGIN_CMD]]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\",%@:\"%@\"}", USR_LOGIN_PARAM_1, login, USR_LOGIN_PARAM_2, passwrod];
        NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)logout
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, USR_LOGOUT_CMD];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"DELETE";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)getUserInfo
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", BMS_PHONESERVICE, USR_ME_CMD, self.apiKey]]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)updateUserInfoWithNewUsername: (NSString *)newName andNewEmail: (NSString *)newEmail
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, USR_UPDATE_CMD];
        requestString = [requestString stringByAppendingFormat:@"%@%@", USR_UPDATE_PARAM_1, newName];
        requestString = [requestString stringByAppendingFormat:@"%@%@", USR_UPDATE_PARAM_2, newEmail];
        requestString = [requestString stringByAppendingFormat:@"%@%@", USR_UPDATE_PARAM_3, self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"PUT";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)changePasswordWithNewPassword:(NSString *)newPassword andPasswordConfirm:(NSString *)passwordConfirm
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, USR_CHANGE_PASS_CMD];
        requestString = [requestString stringByAppendingFormat:@"%@%@", USR_CHANGE_PASS_PARAM_1, newPassword];
        requestString = [requestString stringByAppendingFormat:@"%@%@", USR_CHANGE_PASS_PARAM_2, passwordConfirm];
        requestString = [requestString stringByAppendingFormat:@"%@%@", USR_CHANGE_PASS_PARAM_3, self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"PUT";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)resetPasswordWithLogin: (NSString *)login
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, USR_RESET_PASS_CMD];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\"}", USR_RESET_PASS_PARAM_1, login];
        NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return  TRUE;
}

#pragma mark - Device

- (BOOL)registerDeviceWithUsername:(NSString *)name andRegId:(NSString *)registrationId andDeviceType:(NSString *)deviceType andModel:(NSString *)model andMode:(NSString *)mode andFwVersion:(NSString *)fwVersion andTimeZone:(NSString *)timeZone
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_REG_CMD];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\",%@:\"%@\",%@:\"%@\",%@:\"%@\"%@:\"%@\",%@:\"%@\",%@:\"%@\"}", DEV_REG_PARAM_1, name, DEV_REG_PARAM_2, registrationId, DEV_REG_PARAM_3, deviceType, DEV_REG_PARAM_4, model, DEV_REG_PARAM_5, mode, DEV_REG_PARAM_6, fwVersion, DEV_REG_PARAM_7, timeZone];
        NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)getAllDevices
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", BMS_PHONESERVICE, DEV_OWN_CMD, self.apiKey]]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)getAllSharedDevices
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", BMS_PHONESERVICE, DEV_SHARED_CMD, self.apiKey]]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }

    return TRUE;
}

- (BOOL)getAllPublicDevices
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", BMS_PHONESERVICE, DEV_PUBLIC_CMD, self.apiKey]]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)getDeviceBasicInfoWithRegistrationId:(NSString *)registrationId
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_BASIC_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_BASIC_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSLog(@"%@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)getDeviceCapabilityInfoWithRegistrationId:(NSString *)registrationId
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_CAPABILTY_CDM];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_CAPABILTY_CDM_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSLog(@"%@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)sendCommandWithRegistrationId:(NSString *)registrationId andCommand:(NSString *)command
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_SEND_COMMAND_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_SEND_COMMAND_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\",%@:\"%@\"}", DEV_SEND_COMMAND_PARAM_1, registrationId, DEV_SEND_COMMAND_PARAM_2, command];
        NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)createSessionWithRegistrationId:(NSString *)registrationId andClientType:(NSString *)clientType
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_CREATE_SES_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_CREATE_SES_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\",%@:\"%@\"}", DEV_CREATE_SES_PARAM_1, registrationId, DEV_CREATE_SES_PARAM_2, clientType];
        NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return TRUE;
}

- (BOOL)closeSessionWithRegistrationId: (NSString *)registrationId
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_CLOSE_SES_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_CLOSE_SES_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@%@", DEV_CLOSE_SES_PARAM_2, self.apiKey];
        
        NSLog(@"request string = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"DELETE";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)closeSessionWithRegistrationId:(NSString *)registrationId andChannedId: (NSString *)channedId
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_CLOSE_SES_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_CLOSE_SES_CMD_1];
                requestString = [requestString stringByAppendingFormat:@"%@%@", DEV_CLOSE_SES_PARAM_1, channedId];
        requestString = [requestString stringByAppendingFormat:@"%@%@", DEV_CLOSE_SES_PARAM_2, self.apiKey];
        
        NSLog(@"request string = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"DELETE";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)deleteDeviceWithRegistrationId:(NSString *)registrationId
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_DEL_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_DEL_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSLog(@"request string = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"DELETE";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)updateDeviceBasicInfoWithRegistrationId: (NSString *)registrationId andName: (NSString *)newName andAccessToken: (NSString *)accessToken
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_UPDATE_BASIC_CMD];
        requestString = [requestString stringByAppendingFormat:@"%@", registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_UPDATE_BASIC_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@%@", DEV_UPDATE_BASIC_PARAM_1, newName];
        requestString = [requestString stringByAppendingFormat:@"%@%@", DEV_UPDATE_BASIC_PARAM_2, accessToken];
        requestString = [requestString stringByAppendingFormat:@"%@%@", DEV_UPDATE_BASIC_PARAM_3, self.apiKey];
        
        NSLog(@"request string = %@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"PUT";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)checkDeviceIsAvailableWithRegistrationId:(NSString *)registrationId
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_AVAILABLE_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_AVAILABLE_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
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

- (BOOL)requestRecoveryForDeviceWith:(NSString *)registrationId andRecoveryType:(NSString *)recoveryType andStatus:(NSString *)status
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
	
	@synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_REQUEST_RECOVERY_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_REQUEST_RECOVERY_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        //Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody properties
        NSString *dataString = [NSString stringWithFormat:@"{%@:\"%@\",%@:\"%@\"}", DEV_REQUEST_RECOVERY_PARAM_1, recoveryType, DEV_REQUEST_RECOVERY_PARAM_2, status];
        NSData *requestBodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        //Create url connection and fire request
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)getAllRecordedFilesWithRegistrationId:(NSString *)registrationId
{
    if (selIfSuccess == nil ||selIfFailure == nil|| selIfServerFail ==nil)
	{
		NSLog(@"ERR: selector is not set");
		return FALSE;
	}
    
    @synchronized(self)
	{
        NSString *requestString = [NSString stringWithFormat:@"%@%@", BMS_PHONESERVICE, DEV_PLAYBACK_CMD];
        requestString = [requestString stringByAppendingString:registrationId];
        requestString = [requestString stringByAppendingFormat:@"%@", DEV_PLAYBACK_CMD_1];
        requestString = [requestString stringByAppendingFormat:@"%@", self.apiKey];
        
        NSLog(@"%@", requestString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
        request.timeoutInterval = BMS_DEFAULT_TIME_OUT;
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return TRUE;
}

- (BOOL)checkDevicePortIsOpenWithRegistration:(NSString *)registrationId
{
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
    int responseStatusCode = [self.httpResponse statusCode];
    NSLog(@"responseStatusCode = %d", responseStatusCode);
    
	if (0 < responseStatusCode && responseStatusCode < 400)
	{
		self.responseData = [[NSMutableData alloc] init];
        //[self.responseData setLength:0];
	}
    else {
        
        if ([self.obj respondsToSelector:selIfFailure])
        {
            [self.obj performSelector:selIfFailure withObject:self.httpResponse];
        }
        else
        {
            NSLog(@"Failed to call selIfFailure..silence return");
        }
		
		self.responseData = nil;
	}

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
            
        }
        if ([self.obj respondsToSelector:selIfSuccess])
        {
            NSError *error = nil;
            self.responseDict = [NSDictionary dictionary];
            self.responseDict = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                     options:kNilOptions
                                                                       error:&error];
            if (nil == error) {
                [self.obj performSelector:selIfSuccess withObject:self.responseDict];
            }
        }
        else
        {
            NSLog(@"Failed to call selIfSuccess..silence return");
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

//
//  HttpCommunication.m
//  MBP_ios
//
//  Created by NxComm on 4/23/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "HttpCommunication.h"
#import "Util.h"

@implementation HttpCommunication

@synthesize device_ip, device_port;
@synthesize url_connection,authInProgress;

@synthesize responseData, credential;

- (id) init
{
	[super init];
	device_ip = @"192.168.2.1";//make a default  
	device_port = 80; 
	
	//url_connection = [[NSURLConnection alloc]init]; 
	credential = nil; 
	return self; 
}



- (void) dealloc
{

	[device_ip release];
	
	if (url_connection != nil)
		[url_connection release];
	
	if(credential == nil)
	{
	}
	else
	{
		[credential release]; 
		credential = nil; 
	}

	[super	dealloc];
}


// NOT USED .. 
- (void) askForNewUserPass
{
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:@"Please enter new password for this camera" 
                                          message:@" \n\n" 
                                         delegate:self 
                                cancelButtonTitle:@"Cancel"
                                otherButtonTitles:@"Ok", 
                nil];
    
    _myAlert.tag = ALERT_ASK_FOR_NEW_PASSWD; 
    
    //_myAlert.frame = CGRectMake( 0, 0, 300, 260);
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 75.0, 220.0, 25.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.placeholder = @"Password";
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.backgroundColor = [UIColor whiteColor];
    myTextField.delegate = self;
    myTextField.secureTextEntry = YES;
    myTextField.textColor = [UIColor blackColor];
    myTextField.tag = 10;
    [myTextField becomeFirstResponder];
    [_myAlert addSubview:myTextField];
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
    
	
	
	
}

/// NOT USED ... 
- (void) askForUserPass
{
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:@"Please enter password for this camera" 
                                          message:@" \n\n"
                                         delegate:self 
                                cancelButtonTitle:@"Cancel"
                                otherButtonTitles:@"Ok", 
                nil];
    
    _myAlert.tag = ALERT_ASK_FOR_PASSWD; 
            
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 75.0, 220.0, 25.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.placeholder = @"Password";
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.backgroundColor = [UIColor whiteColor];
    myTextField.textColor = [UIColor blackColor];
    myTextField.secureTextEntry = YES;
    myTextField.delegate = self;
    myTextField.tag = 10;
    [myTextField becomeFirstResponder];
    [_myAlert addSubview:myTextField];
    //[_myAlert insertSubview:myTextField atIndex:0];
    
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
                                                                                 
	
	
	
}

- (void) timeoutAskForRetry
{
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"comm_with_camera_timeout",nil, [NSBundle mainBundle],
                                                       @"Communication with camera has timeout.", nil);
    
    NSString * msg1 = NSLocalizedStringWithDefaultValue(@"comm_with_camera_timeout_msg",nil, [NSBundle mainBundle],
                                                       @"Please retry.", nil);
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:msg
                                          message:msg1
                                         delegate:self
                                cancelButtonTitle:ok
                                otherButtonTitles: nil];
    
    _myAlert.tag = ALERT_ASK_FOR_RETRY;
    
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
    	
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"Dismiss Return");
	//[self alertView:(UIAlertView *)[textField  superview] clickedButtonAtIndex:1];
	//[(UIAlertView *)[textField  superview] dismissWithClickedButtonIndex:1 animated:NO];
	
	return NO;
}
 
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == ALERT_ASK_FOR_PASSWD)
    {
        
        switch(buttonIndex) {
            case 0:
                NSLog(@"Cancel button pressed");
                break;
            case 1:
            {
                UITextField *myTextField = (UITextField *)[alertView viewWithTag:10];
                NSString * pwd = [myTextField text];
                
                
                
                //Store user/pass
                NSString * macc = [CameraPassword fetchBSSIDInfo];
                if (macc != nil)
                {
                    CameraPassword * cp = [[CameraPassword alloc] initWithMac:macc 
                                                                         User:BASIC_AUTH_DEFAULT_USER 
                                                                         Pass:pwd];
                    
                    NSLog(@"saving password: %@ for %@",pwd, macc);
                    [CameraPassword saveCameraPassword:cp];
                    [cp	release];
                    
                    [self babymonitorAuthentication];
                }
                
            }
                break;
        }
    }
    else if (alertView.tag == ALERT_ASK_FOR_NEW_PASSWD)
    {
        switch(buttonIndex) {
            case 0:
                NSLog(@"Cancel button pressed");
                break;
            case 1:
            {
                UITextField *myTextField = (UITextField *)[alertView viewWithTag:10];
                NSString * pwd = [myTextField text];
                
                
                [self babymonitorSetNewPass:pwd];
                
               
                break;
            }
                
        }
    }
    else if (alertView.tag == ALERT_ASK_FOR_RETRY)
    {
        switch(buttonIndex) {
            case 0:
                NSLog(@"OK button pressed");
                break;
            case 1:
                break;
                
        }

    }

}


- (int) tryAuthenticate
{
	NSData * dataReply;
	NSURLResponse * response;
	NSError* error = nil;
	NSString * http_cmd = [NSString stringWithFormat:@"http://%@:%d/%@%@",
						   device_ip, device_port,
						   HTTP_COMMAND_PART,GET_VERSION]; 
	
	NSLog(@"http ---------------> %@", http_cmd);
	@synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:DEFAULT_TIME_OUT];
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [Util getDFCredentials]];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		
        
        if ( (dataReply == nil)||  (error != nil))
		{
			NSLog(@"error: %@\n", error);
			if ([error code] ==  NSURLErrorTimedOut)
            {
                //[self timeoutAskForRetry];
                
            }
			
			
		}
		else
		{
            
			NSString * response = [NSString stringWithUTF8String:[dataReply bytes]];
			NSLog(@"pass with default. - dataReply: %@", response);
			
		}

#if 0
        /* HTTP Status Codes
         200 OK
         400 Bad Request
         401 Unauthorized (bad username or password)
         403 Forbidden
         404 Not Found
         502 Bad Gateway
         503 Service Unavailable
         */
        if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
            int statusCode = [(NSHTTPURLResponse*) response statusCode];
            
            if (statusCode == 401)
            {
                
                
                NSString * macc = [CameraPassword fetchBSSIDInfo];
                if (macc == nil)
                {
                    NSLog(@"failed NO MAC");
                    return -1;
                }
                NSString * cam_pass = [CameraPassword getPasswordForCam:macc];
                NSLog(@"cam_pass:%@ for %@",cam_pass, macc);
                if (cam_pass == nil)
                {
                    //no password
                    NSLog(@"failed NO password");
                    return -1;
                }
                
                
                NSLog(@"resend cmd to authenticate");
                NSString* plain = [NSString stringWithFormat:@"%@:%@",
                                   BASIC_AUTH_DEFAULT_USER, cam_pass];
                NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
                NSString * newCred = [NSString base64StringFromData:plainData length:[plainData length]];
                
                NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", newCred];
                theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
                                                   cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                               timeoutInterval:DEFAULT_TIME_OUT];
                [theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
                error = nil;
                dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
                
                if (error != nil)
                {
                    NSLog(@"failed with stored pass");
                    return -1;
                }
                else {
                    NSLog(@"pass with stored password - save to preference ");
                    [Util setHttpUsr:BASIC_AUTH_DEFAULT_USER];
                    [Util setHttpPass:cam_pass];
                    return 0;
                }
                
            }
			else
            {
                NSLog(@"Status code is: %@ ", error);
            }
			
            
        }
#endif 
        
        
       
		
	}
	
    
    return 0; // Dont ask for new password
}




- (void) babymonitorSetNewPass:(NSString * )newPass
{
    //Store user/pass
    NSString * macc = [CameraPassword fetchBSSIDInfo];
    //Make sure overwrite the passwort with default; 
    CameraPassword * cp = [[CameraPassword alloc] initWithMac:macc 
                                                         User:BASIC_AUTH_DEFAULT_USER 
                                                         Pass:BASIC_AUTH_DEFAULT_PASS];
    [CameraPassword saveCameraPassword:cp];
    
    NSString * userPass  = [NSString stringWithFormat:@"%@:%@", 
                            BASIC_AUTH_DEFAULT_USER,newPass];
    
    NSString * setup_cmd = [NSString stringWithFormat:@"%@%@%@", 
                            BASIC_AUTH_USR_PWD_CHANGE,
                            BASIC_AUTH_USR_PWD_CHANGE_PARAM,
                            userPass];
        
	NSLog(@"before send: %@", setup_cmd);
	
	NSString * response = [self sendCommandAndBlock:setup_cmd ];
    NSLog(@"after res: %@", response);
    
   
    if (macc != nil)
    {
        cp = [[CameraPassword alloc] initWithMac:macc 
                                            User:BASIC_AUTH_DEFAULT_USER 
                                            Pass:newPass];
        
        NSLog(@"saving NEW password: %@ for %@",newPass, macc);
        [CameraPassword saveCameraPassword:cp];
        [cp	release];
        
        [self babymonitorAuthentication];
    }
}

- (void) babymonitorAuthentication
{
	self.authInProgress = TRUE;
	int authStatus = [self tryAuthenticate ];
    
	if (authStatus == -1)
	{
		[self askForUserPass]; 
	}
	else  if (authStatus == -2)
	{
		[self askForNewUserPass]; 
	}
    else 
    {
		self.authInProgress = FALSE;
	}
}



-(BOOL) checkFWLaterorEqual_08_023:(NSString *) device_version
{
    
    if (device_version != nil) {
        
        NSRange range = [device_version rangeOfString:@"_"];
        
        if (range.location != NSNotFound) {
            NSArray * versionArray = [device_version componentsSeparatedByString:@"_"];
            NSString * version_value1 = [versionArray objectAtIndex:0];
            NSString * version_value2 = [versionArray objectAtIndex:1];
            
            if ( [version_value1 intValue] > 8 ||
                ([version_value1 intValue] == 8 && [version_value2 intValue] >= 23)
                )
            {
                // check version > 08_020 ?
                return  TRUE;
                
            }
        }
    }
    
    return FALSE;
}


- (void)sendConfiguration:(DeviceConfiguration *) conf
{
    //20130123: check fw version before encoding the url
    
    NSString * deviceVersion = nil;
    
    deviceVersion = [self sendCommandAndBlock:GET_VERSION];

    if (deviceVersion != nil)
	{
        deviceVersion = [deviceVersion substringFromIndex:([GET_VERSION length] + 2)];
        
    }
    
    //get configuration string from conf and send over HTTP with default IP
	NSString * device_configuration = nil;  
    if ([self checkFWLaterorEqual_08_023:deviceVersion]  == TRUE)
    {
        NSLog(@"encode url now..");
        //ENCODE URL now
        device_configuration = [conf getDeviceEncodedConfString];
    }
    else
    {
        device_configuration = [conf getDeviceConfString];
    }
    
	
	
	NSString * setup_cmd = [NSString stringWithFormat:@"%@%@", 
							 SETUP_HTTP_CMD,device_configuration];

	NSLog(@"before send: %@", setup_cmd);
    

	
	NSString * response = [self sendCommandAndBlock:setup_cmd ];

	response = [self sendCommandAndBlock:RESTART_HTTP_CMD ];
	
}

- (NSString *) sendCommandAndBlock:(NSString *)command
{
    NSString * stringReply;
    NSData * dataReply = [self sendCommandAndBlock_raw:command];
    
    // Interpret the response
    stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
    [stringReply autorelease];
    
    return stringReply;
    
}


- (NSData *) sendCommandAndBlock_raw:(NSString *)command
{
    return  [self sendCommandAndBlock_raw:command withTimeout:DEFAULT_TIME_OUT];
	
}

- (NSString *) sendCommandAndBlock:(NSString *)command withTimeout:(float) timeout
{
    NSString * stringReply;
    NSData * dataReply = [self sendCommandAndBlock_raw:command withTimeout:timeout];
    
    // Interpret the response
    stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
    [stringReply autorelease];
    
    return stringReply;
    
}



- (NSData *) sendCommandAndBlock_raw:(NSString *)command withTimeout:(NSTimeInterval) newTimeout
{
    //NSLog(@"send request: %@", url);
	NSURLResponse* response;
	NSError* error = nil;
	NSData *dataReply = nil;
    
	
	NSTimeInterval timeout = newTimeout ;
    
    NSString * http_cmd;
    
    http_cmd = [NSString stringWithFormat:@"http://%@:%d/%@%@",
                device_ip, device_port,
                HTTP_COMMAND_PART,command];
    
    
	NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [Util getDFCredentials]];
	@synchronized(self)
	{
		
		// Create the request.
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:timeout];
        
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		
		dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		
		
		if (error != nil)
		{
			NSLog(@"sendCommandAndBlock_raw error: %@\n", error);
            dataReply = nil;
            
            if ([error code ] == NSURLErrorTimedOut)
            {

                //[self timeoutAskForRetry];
            }
            
		}
		else {
			
			
		}
		
		
	}
	
	return dataReply ;
}




-(NSString *) getUpgradeProgress:(NSError **)error
{
    NSData * dataReply;
    NSURLResponse* response;
	
    NSString * stringReply = nil;
    
    NSTimeInterval timeout = DEFAULT_TIME_OUT ; 
    
    NSString * http_cmd = [NSString stringWithFormat:@"http://%@:8080/cgi-bin/fullupgrade",device_ip]; 
    
    
    // Create the request.
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
                                                            cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:timeout];
    

    
    
    dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:error];
    
    
    if (*error != nil)
    {
       
        dataReply = nil; 
    }
    else
    {  
        // Interpret the response
        stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
        
        *error = nil;
    }
    
    return stringReply;

}

- (NSData *) getSnapshot
{
	//NSLog(@"send request: %@", url);
	NSURLResponse* response;
	NSError* error = nil;
	NSData *dataReply = nil;
    
	
	NSTimeInterval timeout = DEFAULT_TIME_OUT ; 
	
	NSString * http_cmd = [NSString stringWithFormat:@"http://%@:%d/%@",
						   device_ip, device_port,
						   SNAPSHOT_REQUEST]; 
	

	
	NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [Util getDFCredentials]];  
	
	NSString * macc = [CameraPassword fetchBSSIDInfo];
	if (macc != nil)
	{
		NSString * cam_pass = [CameraPassword getPasswordForCam:macc];

		if (cam_pass == nil)
		{
			//no password 
			NSLog(@"failed NO password: use defautl;"); 
			cam_pass =@"000000";
		}
        
		NSString* plain = [NSString stringWithFormat:@"%@:%@",
						   BASIC_AUTH_DEFAULT_USER, cam_pass];
		NSData* plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
		NSString * newCred = [NSString base64StringFromData:plainData length:[plainData length]];
		
		authHeader = [@"Basic " stringByAppendingFormat:@"%@", newCred];  
		
	}
	
	@synchronized(self)
	{
		
		// Create the request.
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:timeout];
        
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		
		dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		
		
		if (error != nil)
		{
			//NSLog(@"error: %@\n", error);
            dataReply = nil; 
		}
		else {
			
			
		}
		
		
	}
	
	return dataReply ;
}




//Non-block
- (void) sendCommand:(NSString *) command
{
	
	NSTimeInterval timeout = DEFAULT_TIME_OUT ; 
	
	NSString * http_cmd = [NSString stringWithFormat:@"http://%@:%d/%@%@",
						   device_ip, device_port,
						   HTTP_COMMAND_PART,command]; 

	@synchronized(self)
	{
		
		// Create the request.
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:http_cmd]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:timeout];
		
		url_connection = [[NSURLConnection alloc] initWithRequest:theRequest 
														 delegate:self
												 startImmediately:TRUE];
		
	}
	
	
	
}


#pragma mark NSURLConnection Delegate functions
/****** NSURLConnection Delegate functions ******/



- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"did recv auth challenge: %@", challenge);
	
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
//	NSLog(@"did recv response");
	int statusCode = [((NSHTTPURLResponse*) response) statusCode];
	NSLog(@"did recv response: code: %d", statusCode);

	responseData = [[NSMutableData alloc] init];
	

	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    NSLog(@"Succeeded! Received %d bytes of data",[responseData
                                                   length]);
    NSString *txt = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	


	NSLog(@"response: %@", txt); 
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed with error: %@", error); 

}




@end

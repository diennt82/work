//
//  HttpCommunication.h
//  MBP_ios
//
//  Created by NxComm on 4/23/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraPassword.h"
#import "DeviceConfiguration.h"
#import "PublicDefine.h"

#define DEFAULT_TIME_OUT 5000

#define BASIC_AUTH_DEFAULT_USER @"camera"
#define BASIC_AUTH_DEFAULT_PASS @"000000"

#define AVSTREAM_REQUEST @"GET /?action=appletvastream"
#define AVSTREAM_UDT_REQ @"action=appletvastream"
#define AVSTREAM_PARAM_1 @"&remote_session="
#define AVSTREAM_PARAM_2 @" HTTP/1.1\r\n"

#define SNAPSHOT_REQUEST @"?action=snapshot"



#define HTTP_COMMAND_PART @"?action=command&command="

#define GET_VERSION @"get_version"

#define SET_RESOLUTION_VGA @"VGA640_480"
#define SET_RESOLUTION_QVGA @"QVGA320_240"
#define SET_RESOLUTION_QQVGA @"QQVGA160_120"


#define SETUP_HTTP_CMD @"setup_wireless_save&setup="
#define RESTART_HTTP_CMD @"restart_system"

#define SET_MASTER_KEY @"set_master_key&setup="

#define SET_MELODY_OFF @"melodystop"
#define SET_MELODY @"melody"
#define GET_MELODY @"value_melody"

#define SET_PTT @"audio_out"

#define VOX_STATUS @"vox_get_status"
#define VOX_ENABLE @"vox_enable"
#define VOX_DISABLE @"vox_disable"
#define VOX_GET_THRESHOLD @"vox_get_threshold"
#define VOX_SET_THRESHOLD @"vox_set_threshold"
#define VOX_SET_THRESHOLD_VALUE @"&setup="

#define SET_VOLUME @"spk_volume"
#define GET_VOLUME @"get_spk_volume"
#define SET_VOLUME_PARAM @"&setup="

#define FLIP_IMAGE @"flipup"

#define GET_BRIGHTNESS_VALUE @"value_brightness"
#define GET_BRIGHTNESS_PLUS @"brightness_plus"
#define GET_BRIGHTNESS_MINUS @"brightness_minus"


#define BASIC_AUTH_USR_PWD_CHANGE @"save_http_usr_passwd"
#define BASIC_AUTH_USR_PWD_CHANGE_PARAM @"&setup="

//#define SWITCH_TO_DIRECT_MODE @"switch_to_uap"
#define SWITCH_TO_DIRECT_MODE @"reset_factory"

#define LR_STOP @"lr_stop"
#define FB_STOP @"fb_stop"
#define MOVE_RIGHT @"move_right"//add speed
#define MOVE_LEFT @"move_left"


#if REVERT_UP_DOWN_DIRECTION

#define MOVE_UP   @"move_backward"
#define MOVE_DOWN @"move_forward"

#else
#define MOVE_UP   @"move_forward"
#define MOVE_DOWN @"move_backward"
#endif


#define GET_UPNP_PORT @"get_upnp_port"
#define SET_UPNP_PORT @"set_upnp_port"
#define SET_UPNP_PORT_PARAM_1 @"&setup="

#define CHECK_UPNP @"check_upnp"
#define RESET_UPNP @"reset_upnp"

#define GET_ROUTER_LIST @"get_routers_list"




#define ALERT_ASK_FOR_PASSWD 1
#define ALERT_ASK_FOR_NEW_PASSWD 2


@interface HttpCommunication : NSObject <UITextFieldDelegate> {
	NSString * device_ip; 
	int device_port;
	NSURLConnection * url_connection; 
	NSMutableData *responseData;
	
	NSURLCredential * credential; 
	NSURLAuthenticationChallenge * current_challenge;

	BOOL authInProgress;
	
}

@property (nonatomic,retain) NSURLCredential *credential; 
@property (nonatomic,retain) NSURLConnection * url_connection; 
@property (nonatomic,retain) NSMutableData * responseData; 
@property (nonatomic,retain) NSString * device_ip; 
@property (nonatomic) int device_port; 
@property (nonatomic) BOOL authInProgress; 

- (void) sendCommand:(NSString *) command;
- (NSString *) sendCommandAndBlock:(NSString *)command;
- (int) tryAuthenticate;
- (void) babymonitorAuthentication;

- (void)sendConfiguration:(DeviceConfiguration *) conf;
- (NSData *) sendCommandAndBlock_raw:(NSString *)command;

-(NSData * ) getSnapshot;
- (void) askForUserPass;
- (void) askForNewUserPass;




#pragma mark NSURLConnection Delegate functions
/****** NSURLConnection Delegate functions ******/
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

/*! 
 @method connection:needNewBodyStream:  
 @abstract This method is called whenever an NSURLConnection
 determines that it the client needs to provide a new, unopened
 body stream.  This can occur if the request had a body stream
 set on it and requires retransmission.
 @discussion This method gives the delegate an opportunity to
 attach a new, unopened body stream to the connection to handle
 situations where the stream data needs to be retransmitted.  In the
 past on Mac OS X the stream data was spooled to disk in case retransmission
 was required, which may not be desirable for large data sets.  By
 implementing this delegate method the client is opting in to no longer
 having the data spooled to disk - for each retransmission a new stream
 needs to be provided.  Returning NULL from this delegate method will cause
 the connection to fail.
 @param connection an NSURLConnection that has determined that it
 required a new body stream to continue.
 @param request The current NSURLRequest object associated with the connection.
 @result The new unopened body stream to use (see setHTTPBodyStream).
 */
- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request NS_AVAILABLE(10_6, 3_0);

/*!
 @method connection:canAuthenticateAgainstProtectionSpace:
 @abstract This method gives the delegate an opportunity to inspect an NSURLProtectionSpace before an authentication attempt is made.
 @discussion If implemented, will be called before connection:didReceiveAuthenticationChallenge 
 to give the delegate a chance to inspect the protection space that will be authenticated against.  Delegates should determine
 if they are prepared to respond to the authentication method of the protection space and if so, return YES, or NO to
 allow default processing to handle the authentication.  If this delegate is not implemented, then default 
 processing will occur (typically, consulting
 the user's keychain and/or failing the connection attempt.
 @param connection an NSURLConnection that has an NSURLProtectionSpace ready for inspection
 @param protectionSpace an NSURLProtectionSpace that will be used to generate an authentication challenge
 @result a boolean value that indicates the willingness of the delegate to handle the authentication
 */
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace NS_AVAILABLE(10_6, 3_0);

/*!
 @method connection:didReceiveAuthenticationChallenge:
 @abstract Start authentication for a given challenge
 @discussion Call useCredential:forAuthenticationChallenge:,
 continueWithoutCredentialForAuthenticationChallenge: or cancelAuthenticationChallenge: on
 the challenge sender when done.
 @param connection the connection for which authentication is needed
 @param challenge The NSURLAuthenticationChallenge to start authentication for
 */
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/*!
 @method connection:didCancelAuthenticationChallenge:
 @abstract Cancel authentication for a given request
 @param connection the connection for which authentication was cancelled
 @param challenge The NSURLAuthenticationChallenge for which to cancel authentication
 */
- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/*! 
 @method connectionShouldUseCredentialStorage   
 @abstract This method allows the delegate to inform the url loader that it
 should not consult the credential storage for the connection.
 @discussion This method will be called before any attempt to authenticate is
 attempted on a connection.  By returning NO the delegate is telling the
 connection to not consult the credential storage and taking responsiblity
 for providing any credentials for authentication challenges.  Not implementing
 this method is the same as returing YES.  The delegate is free to consult the
 credential storage itself when it receives a didReceiveAuthenticationChallenge
 message.
 @param connection  the NSURLConnection object asking if it should consult the credential storage.
 @result NO if the connection should not consult the credential storage, Yes if it should.
 */
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection NS_AVAILABLE(10_6, 3_0);

/*! 
 @method connection:didReceiveResponse:   
 @abstract This method is called when the URL loading system has
 received sufficient load data to construct a NSURLResponse object.
 @discussion The given NSURLResponse is immutable and
 will not be modified by the URL loading system once it is
 presented to the NSURLConnectionDelegate by this method.
 <p>See the category description for information regarding
 the contract associated with the delivery of this delegate 
 callback.
 @param connection an NSURLConnection instance for which the
 NSURLResponse is now available.
 @param response the NSURLResponse object for the given
 NSURLConnection.
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

/*! 
 @method connection:didReceiveData:   
 @abstract This method is called to deliver the content of a URL
 load.
 @discussion Load data is delivered incrementally. Clients can
 concatenate each successive NSData object delivered through this
 method over the course of an asynchronous load to build up the
 complete data for a URL load. It is also important to note that this
 method provides the only way for an ansynchronous delegate to find
 out about load data. In other words, it is the responsibility of the
 delegate to retain or copy this data as it is delivered through this
 method.
 <p>See the category description for information regarding
 the contract associated with the delivery of this delegate 
 callback.
 @param connection  NSURLConnection that has received data.
 @param data A chunk of URL load data.
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

/*! 
 @method connection:didSendBodyData:   
 @abstract This method is called to deliver progress information
 for a url upload.  The bytes refer to bytes of the body
 associated with the url request.
 @discussion This method is called as the body (message data) of a request 
 is transmitted (as during an http POST).  It provides the number of bytes 
 written for the latest write, the total number of bytes written and the 
 total number of bytes the connection expects to write (for HTTP this is 
 based on the content length). The total number of expected bytes may change
 if the request needs to be retransmitted (underlying connection lost, authentication
 challenge from the server, etc.).
 @param connection  NSURLConnection that has written data.
 @param bytesWritten number of bytes written 
 @param totalBytesWritten total number of bytes written for this connection
 @param totalBytesExpectedToWrite the number of bytes the connection expects to write (can change due to retransmission of body content)
 */
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite NS_AVAILABLE(10_6, 3_0);

/*! 
 @method connectionDidFinishLoading:   
 @abstract This method is called when an NSURLConnection has
 finished loading successfully.
 @discussion See the category description for information regarding
 the contract associated with the delivery of this delegate
 callback.
 @param connection an NSURLConnection that has finished loading
 successfully.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

/*! 
 @method connection:didFailWithError:   
 @abstract This method is called when an NSURLConnection has
 failed to load successfully.
 @discussion See the category description for information regarding
 the contract associated with the delivery of this delegate
 callback.
 @param connection an NSURLConnection that has failed to load.
 @param error The error that encapsulates information about what
 caused the load to fail.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

/*!
 @method connection:willCacheResponse:
 @abstract This method gives the delegate an opportunity to inspect
 the NSCachedURLResponse that will be stored in the cache, and modify
 it if necessary.
 @discussion See the category description for information regarding
 the contract associated with the delivery of this delegate
 callback.
 @param connection an NSURLConnection that has a NSCachedURLResponse
 ready for inspection.
 @result a NSCachedURLResponse that will be written to the cache. The
 delegate need not perform any customization and may return the
 NSCachedURLResponse passed to it. The delegate may replace the
 NSCachedURLResponse with a completely new one. The delegate may also
 return nil to indicate that no NSCachedURLResponse should be stored
 for this connection.
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;



@end

//
//  MBP_Streamer.h
//  MBP_ios
//
//  Created by NxComm on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PCMPlayer.h"
#import "AsyncSocket.h"
#import "ADPCMDecoder.h"
#import "AviRecord.h"
#import "CameraPassword.h"
#import "HttpCommunication.h"
#import "RemoteConnection.h"
#import "UdtSocketWrapper.h"

@protocol StreamerOrientationAdapter

-(void) switchToOrientation:(UIInterfaceOrientation)orientation;


@end

@protocol StreamerEventHandler


#define STREAM_STARTED              1
#define STREAM_STOPPED_UNEXPECTEDLY 2
#define STREAM_RESTARTED            3
#define STREAM_STOPPED              4
#define REMOTE_STREAM_STOPPED_UNEXPECTEDLY 5

#define CONNECTED_TO_CAMERA         6

-(void) statusReport:(int) status andObj:(NSObject*) obj; 

@end


@protocol StreamerTemperatureUpdater 

-(void) updateTemperature:(int) temp;

@end

@protocol StreamerFrameRateUpdater 

-(void) updateFrameRate:(int) frameRate;

@end

@interface MBP_Streamer : NSObject <StreamerOrientationAdapter> {

	UIImageView * videoImage;

    UILabel * recTimeLabel; 
	
	AsyncSocket * listenSocket;
	NSMutableData * responseData;
	int initialFlag ;
	NSString * device_ip;
	int device_port;
	
	PCMPlayer * pcmPlayer;
	
	BOOL takeSnapshot;
	
	int iMaxRecordSize;
	NSString * iFileName;
	AviRecord * iRecorder; 
	BOOL recordInProgress;
	
	CGFloat currentZoomLevel ;
	
	BOOL remoteView; 
	int communication_mode; 
	
	NSString * remoteViewKey; 
	
	int reconnectLimits; 
	
	id<StreamerEventHandler> mHandler; 
    
	
	BOOL hasStoppedByCaller; 
	
	UdtSocketWrapper * udtSocket; 
	int local_port; 
	
	NSThread * udtStreamerThd; 
    BOOL disableAudio; 
    NSTimer * recTimer; 
    
    id<StreamerFrameRateUpdater> mFrameUpdater;
    id<StreamerTemperatureUpdater> mTempUpdater; 
    
    
    UIInterfaceOrientation currentOrientation; 
    
    CamChannel * streamingChannel; 
    BOOL stillReading;
    
     NSThread * readTimeoutThrd ;
	
}
@property (nonatomic) int device_port,communication_mode, local_port;
@property (nonatomic,retain) NSString * device_ip, *remoteViewKey;
@property (nonatomic,retain) UIImageView * videoImage;
@property (nonatomic, retain) AsyncSocket * listenSocket;
@property (nonatomic, retain) NSMutableData * responseData;
@property (nonatomic, retain) PCMPlayer * pcmPlayer; 
@property (nonatomic, retain) UILabel  *recTimeLabel; 

@property (nonatomic) BOOL takeSnapshot, recordInProgress, remoteView, hasStoppedByCaller;
@property (nonatomic) CGFloat currentZoomLevel;
@property (nonatomic, retain) UdtSocketWrapper * udtSocket;

@property (nonatomic, retain) NSTimer * recTimer;

@property (nonatomic) BOOL disableAudio,stillReading; 
@property (nonatomic, assign) id<StreamerFrameRateUpdater> mFrameUpdater;
@property (nonatomic, assign) id<StreamerTemperatureUpdater> mTempUpdater; 
@property (nonatomic) UIInterfaceOrientation currentOrientation; 

@property (nonatomic, retain)CamChannel *  streamingChannel; 




- (id) initWithIp:(NSString *) ip andPort:(int) port handler:(id<StreamerEventHandler>) handler;
 

- (void) setVideoView:(UIImageView *) view;
- (void) startStreaming;
- (void) stopStreaming;
-(void) startUdtStream;

-(void) switchToUdtRelayServer; 
- (void) startUdtRelayStream;


- (void) PlayPCM:(NSData*)pcm ;

- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout;
- (void ) requestURLSync_bg:(NSString*)url;
- (void) saveSnapShot:(UIImage *) image ;
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (void) startRecording;
- (void) stopRecording;
-(void) toggleRecording;
- (UIImage*)imageWithImage:(UIImage*)image scaledToRect:(CGRect)newRect;




-(void) switchToOrientation:(UIInterfaceOrientation)orientation;
-(UIImage *) adaptToCurrentOrientation:(UIImage *) orig;
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;

@end

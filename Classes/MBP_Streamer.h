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

@protocol StreamerEventHandler


#define STREAM_STARTED              1
#define STREAM_STOPPED_UNEXPECTEDLY 2
#define STREAM_RESTARTED            3
#define STREAM_STOPPED              4
#define REMOTE_STREAM_STOPPED_UNEXPECTEDLY 5

-(void) statusReport:(int) status andObj:(NSObject*) obj; 

@end


@interface MBP_Streamer : NSObject {

	UIImageView * videoImage;
	UILabel * temperatureLabel; 
	
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
	NSString * remoteViewKey; 
	
	int reconnectLimits; 
	
	id<StreamerEventHandler> mHandler; 
	
	BOOL hasStoppedByCaller; 
	
}
@property (nonatomic) int device_port;
@property (nonatomic,retain) NSString * device_ip, *remoteViewKey;
@property (nonatomic,retain) UIImageView * videoImage;
@property (nonatomic, retain) AsyncSocket * listenSocket;
@property (nonatomic, retain) NSMutableData * responseData;
@property (nonatomic, retain) PCMPlayer * pcmPlayer; 
@property (nonatomic, retain) UILabel * temperatureLabel; 

@property (nonatomic) BOOL takeSnapshot, recordInProgress, remoteView, hasStoppedByCaller;
@property (nonatomic) CGFloat currentZoomLevel;

- (id) initWithIp:(NSString *) ip andPort:(int) port handler:(id<StreamerEventHandler>) handler;
 

- (void) setVideoView:(UIImageView *) view;
- (void) startStreaming;
- (void) stopStreaming;


- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout;
- (void ) requestURLSync_bg:(NSString*)url;
- (void) saveSnapShot:(UIImage *) image ;
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (void) startRecording;
- (void) stopRecording;
-(void) toggleRecording;
- (UIImage*)imageWithImage:(UIImage*)image scaledToRect:(CGRect)newRect;

@end

//
//  Bonjour.h
//  MBP_ios
//
//  Created by nxcomm on 06/05/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSNetServices.h>
#include <arpa/inet.h>
#include "CamProfile.h"
#include "HttpCommunication.h"
#include "CamProfile.h"

#define BONJOUR_STATUS_DEFAULT 0
#define BONJOUR_STATUS_OK 1
#define BONJOUR_STATUS_TIMEOUT 2
#define BONJOUR_STATUS_ERROR 3

@protocol BonjourDelegate
-(void) bonjourReturnCameraListAvailable:(NSMutableArray *) cameraList;
@end


@interface Bonjour : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    NSNetServiceBrowser * _browserService;
    NSNetService * _lastService;
    NSURLConnection * url_connection;
    
    int nextIndex;
    NSArray * _cameras;
}

@property (nonatomic, retain) NSMutableArray * camera_profiles;
@property (nonatomic, retain) NSTimer * timer;
@property (assign, nonatomic) id<BonjourDelegate> delegate;
@property (assign, nonatomic) BOOL isSearching;
@property (nonatomic, retain) NSMutableArray * serviceArray;
@property (nonatomic, retain) NSMutableArray * cameraList;
@property (nonatomic, retain) NSArray * camera;

@property (nonatomic, assign) int bonjourStatus;

-(void) startScanLocalWiFi;
-(BOOL) isCameraIP:(NSString *) ip availableWith:(NSString *) macAddress;
-(id) initSetupWith:(NSMutableArray *) cameras;
@end

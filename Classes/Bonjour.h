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

@protocol BonjourDelegate
-(void) bonjourReturnCameraList:(NSMutableArray *) cameraList;
@end


@interface Bonjour : UIViewController <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    NSNetServiceBrowser * _browserService;
    NSNetService * _currentService;
}

@property (nonatomic, retain) NSTimer * timer;
@property (assign, nonatomic) id<BonjourDelegate> delegate;
@property (assign, nonatomic) BOOL isSearching;
@property (nonatomic, retain) NSMutableArray * serviceArray;
@property (nonatomic, retain) NSMutableArray * cameraList;

- (void) startScanLocalWiFi;
@end

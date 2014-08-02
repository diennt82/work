//
//  WifiEntry.h
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#define VERSION_1 @"1.0"
#define VERSION_1_1 @"1.1"

@interface WifiEntry : NSObject

@property (nonatomic, copy) NSString *ssidWithQuotes;
@property (nonatomic, copy) NSString *bssid;
@property (nonatomic, copy) NSString *authMode;
@property (nonatomic, copy) NSString *encryptType; //version 1.1
@property (nonatomic, copy) NSString *quality;

@property (nonatomic) int signalLevel;
@property (nonatomic) int noiseLevel;
@property (nonatomic) int channel;

- (id)initWithSSID:(NSString *)ssid;

@end

//
//  PlaylistInfo.h
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaylistInfo : NSObject

@property (nonatomic, copy) NSString *macAddr;
@property (nonatomic, copy) NSString *urlImage;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *urlFile;
@property (nonatomic, copy) NSString *alertType;
@property (nonatomic, copy) NSString *alertVal;
@property (nonatomic, copy) NSString *registrationID;
@property (nonatomic, strong) UIImage *imgSnapshot;

- (NSDate *)getTimeCode;
- (BOOL)isLastClip;
- (NSString *)getAlertVal;
- (NSString *)getAlertType;
- (BOOL)containsClip:(NSString *)aString;

@end

//
//  PlaylistInfo.h
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaylistInfo : NSObject


@property (nonatomic, retain) NSString * mac_addr;

 
@property (nonatomic, retain) NSString *urlImage;
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *urlFile;
@property (nonatomic, retain) UIImage *imgSnapshot;

-(NSDate *) getTimeCode;
-(BOOL) isLastClip;
-(NSString *) getAlertVal;
-(NSString *) getAlertType;

- (BOOL)containsClip: (NSString *)aString;

@end

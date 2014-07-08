//
//  Camera.h
//  BlinkHD_ios
//
//  Created by Developer on 1/7/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _CAMERA_TAG {
    FORCUS_66_TAG = 566,
    MBP_83_TAG = 583,
    SCOUT_73_TAG = 73,
    MBP_85_TAG = 585
} CAMERA_TAG;

@interface Camera : NSObject
@property (nonatomic) CAMERA_TAG         ID;
@property (nonatomic, strong) NSString  *lable;
@property (nonatomic, strong) UIImage   *image;

- (id)initWith:(CAMERA_TAG)tag andLable:(NSString *)lable andImage:(UIImage *)image;
@end

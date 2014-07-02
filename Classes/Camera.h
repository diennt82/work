//
//  Camera.h
//  BlinkHD_ios
//
//  Created by Developer on 1/7/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _CAMERA_TAG {
    TAG_66 = 566,
    TAG_83 = 583,
    TAG_73 = 73,
    TAG_85 = 585
} CAMERA_TAG;

@interface Camera : NSObject
@property (nonatomic) CAMERA_TAG         ID;
@property (nonatomic, strong) NSString  *lable;
@property (nonatomic, strong) UIImage   *image;

- (id)initWith:(CAMERA_TAG)tag andLable:(NSString *)lable andImage:(UIImage *)image;
@end

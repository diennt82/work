//
//  Camera.m
//  BlinkHD_ios
//
//  Created by Developer on 1/7/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "Camera.h"

@implementation Camera
- (void)dealloc {
    [super dealloc];
    [_lable release];
    [_image release];
}

- (id)initWith:(CAMERA_TAG)tag andLable:(NSString *)lable andImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.ID = tag;
        self.lable = lable;
        self.image = image;
    }
    return self;
}
@end

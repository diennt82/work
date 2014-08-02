//
//  HttpCommunication.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 9/1/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CameraScanner/HttpCommunication.h>

@interface HttpCom : NSObject {
    HttpCommunication *_comWithDevice;
}
@property (nonatomic, strong) HttpCommunication *comWithDevice;

- (id)init;
+ (HttpCom *) instance;
@end

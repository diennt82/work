//
//  ClipInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 12/31/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClipInfo : NSObject

@property (nonatomic, strong) UIImage *imgSnapshot;
@property (nonatomic, copy) NSString *urlImage;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *urlFile;

@end

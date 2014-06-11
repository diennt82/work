//
//  CameraMenuViewController.h
//  BlinkHD_ios
//
//  Created by Developer on 2/11/14.
//  Copyright (c) 2014 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "ConnectionMethodDelegate.h"

@interface CameraMenuViewController : UIViewController
{
    NSString *_cameraName;
    NSString *_cameraNewName;
    UIImage *imageSelected;
}

@property (nonatomic, assign) NSString *cameraName;
@property (nonatomic, assign) id<ConnectionMethodDelegate> cameraMenuDelegate;
@property (nonatomic, assign) CamChannel *camChannel;
@property (nonatomic, retain) IBOutlet UIView *viewPorgress;

@end

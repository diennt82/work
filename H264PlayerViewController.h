//
//  H264PlayerViewController.h
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamChannel.h"

@interface H264PlayerViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *imageViewVideo;
@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backBarBtnItem;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *cameraNameBarBtnItem;
@property (retain, nonatomic) IBOutlet UIView *progressView;

@property (retain, nonatomic) IBOutlet UISegmentedControl *segCtrl;
@property (nonatomic, retain) NSString* stream_url;
@property (nonatomic, retain) CamChannel *selectedChannel;

- (void)stopStream;

@end

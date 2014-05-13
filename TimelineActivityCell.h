//
//  TimelineActivityCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineActivityCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *snapshotImage;
@property (retain, nonatomic) IBOutlet UILabel *eventLabel;
@property (retain, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *feedImageVideo;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorLoading;
@property (retain, nonatomic) IBOutlet UIImageView *lineImage;
@property (retain, nonatomic) IBOutlet UILabel *lblToHideLine;
@end

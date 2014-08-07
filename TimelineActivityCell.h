//
//  TimelineActivityCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineActivityCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *snapshotImage;
@property (nonatomic, weak) IBOutlet UILabel *eventLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *feedImageVideo;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorLoading;
@property (nonatomic, weak) IBOutlet UIImageView *lineImage;
@property (nonatomic, weak) IBOutlet UILabel *lblToHideLine;

@end

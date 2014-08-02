//
//  TimelineActivityCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineActivityCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *snapshotImage;
@property (nonatomic, retain) IBOutlet UILabel *eventLabel;
@property (nonatomic, retain) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *feedImageVideo;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorLoading;
@property (nonatomic, retain) IBOutlet UIImageView *lineImage;
@property (nonatomic, retain) IBOutlet UILabel *lblToHideLine;

@end

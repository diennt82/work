//
//  PlaylistCell.h
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *imgViewSnapshot;
@property (retain, nonatomic) IBOutlet UILabel *labelTitle;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

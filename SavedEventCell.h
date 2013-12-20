//
//  SavedEventCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedEventCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *snapshotImage;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *placeEventLabel;
@end

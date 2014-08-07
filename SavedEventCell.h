//
//  SavedEventCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedEventCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *snapshotImage;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *placeEventLabel;

@end

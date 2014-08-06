//
//  SavedEventCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedEventCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *snapshotImage;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *placeEventLabel;

@end

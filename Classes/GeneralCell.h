//
//  GeneralCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *valueSegmented;
@end

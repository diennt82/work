//
//  TimelineButtonCell.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimelineButtonCellDelegate <NSObject>

- (void)sendTouchBtnStateWithIndex: (NSInteger)rowIdx;

@end

@interface TimelineButtonCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *timelineCellButtn;
@property (nonatomic, assign) id<TimelineButtonCellDelegate> timelineBtnDelegate;
@property (nonatomic) NSInteger rowIndex;

@end

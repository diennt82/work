//
//  HelpWindowPopup.h
//  BlinkHD_ios
//
//  Created by Developer on 6/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpWindowPopup : UIView

- (id)initWithTitle:(NSString *)title andContent:(NSString *)content;
- (void)show;
@end

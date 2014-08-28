//
//  PassValidatePopup.h
//  BlinkHD_ios
//
//  Created by Developer on 28/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassValidatePopup : UIView
- (id)initwithPassword:(NSString *)text;
- (void)show;
- (void)dismiss;
@end

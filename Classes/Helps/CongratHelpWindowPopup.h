//
//  CongratHelpWindowPopup.h
//  BlinkHD_ios
//
//  Created by Developer on 26/8/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

typedef enum _CONGRAT_TYPE {
    START_FREE_TRIAL = 0,
    FIND_OUT_MORE = 1,
    MAYBE_LATER = 2,
    SOUND_GREAT = 3
} CONGRAT_TYPE;

#define kCongratValues [NSArray arrayWithObjects:@"Start Free Trial", @"Find Out More", @"No Thanks! Maybe Later", @"Sounds Great! Start Free Trial", nil]
#define kCongratKeys [NSArray arrayWithObjects:@(START_FREE_TRIAL), @(FIND_OUT_MORE), @(MAYBE_LATER), @(SOUND_GREAT), nil]

#import "HelpWindowPopup.h"

@interface CongratHelpWindowPopup : HelpWindowPopup
@property (nonatomic, retain) NSDictionary *buttonTitles;

- (void)reloadUIComponents;
@end

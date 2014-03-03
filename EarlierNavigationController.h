//
//  EarlierNavigationController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 28/2/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EarlierNavigationController : UINavigationController
{
    BOOL _isEarlierView;
}
@property (nonatomic, assign)BOOL isEarlierView;
@end

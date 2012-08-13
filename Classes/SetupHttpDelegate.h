//
//  SetupHttpDelegate.h
//  MBP_ios
//
//  Created by NxComm on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceConfiguration.h"


@protocol SetupHttpDelegate
- (void)sendConfiguration:(DeviceConfiguration *) conf;
@end


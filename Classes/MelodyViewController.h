//
//  MelodyViewController.h
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 22/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import "UIFont+Hubble.h"

@protocol MelodyVCDelegate <NSObject>

- (void)setMelodyWithIndex: (NSInteger) molodyIndex;

@end

@interface MelodyViewController : UIViewController {

}

@property (nonatomic) NSInteger melodyIndex;
@property (retain, nonatomic) CamChannel *selectedChannel;
@property (nonatomic, assign) id<MelodyVCDelegate> melodyVcDelegate;

- (void)setMelodyState_fg: (NSInteger )melodyIndex;

@end

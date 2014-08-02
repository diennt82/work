//
//  MelodyViewController.h
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 22/11/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>

#import "UIFont+Hubble.h"
#import "UIImage+Hubble.h"
#import "CellMelody.h"
#import "UIColor+Hubble.h"
#import "GAI.h"

@protocol MelodyVCDelegate <NSObject>

- (void)setMelodyWithIndex: (NSInteger) molodyIndex;

@end

@interface MelodyViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *melodyTableView;
@property (nonatomic, retain) CamChannel *selectedChannel;
@property (nonatomic, assign) id<MelodyVCDelegate> melodyVcDelegate;
@property (nonatomic, assign) NSInteger melodyIndex;

- (void)setMelodyState:(NSInteger)melodyIndex;
- (void)updateUIMelody:(NSInteger)playingIndex;

@end

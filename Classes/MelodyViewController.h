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
#import "UIImage+Hubble.h"
#import "CellMelody.h"
#import "UIColor+Hubble.h"
#import "GAI.h"


@interface MelodyViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableViewCell * cellMelody;
    IBOutlet UITableViewCell * cellMelody_land;
    IBOutlet UITableViewCell * cellMelody_iPad;
}

@property (retain, nonatomic) IBOutlet UITableView *melodyTableView;
@property (nonatomic) NSInteger melodyIndex;
@property (assign, nonatomic) CamChannel *selectedChannel;

- (void)getMelodyValue_bg;

@end

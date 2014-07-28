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

@protocol MelodySetingDelegate <NSObject>
- (void)updateCompleted:(BOOL)success;
@end

@interface MelodyViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableViewCell * cellMelody;
    IBOutlet UITableViewCell * cellMelody_land;
    IBOutlet UITableViewCell * cellMelody_iPad;
}

@property (retain, nonatomic) IBOutlet UITableView *melodyTableView;
@property (nonatomic) NSInteger melodyIndex;
@property (nonatomic) BOOL playing;
@property (nonatomic, assign) id <MelodySetingDelegate> melodyDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSelectedChannel:(CamChannel *)channel;
- (void)getMelodyValue_bg;
- (void)resetStatus;
- (void)setCurrentMelodyIndex:(NSInteger)melodyIndex andPlaying:(BOOL)playing;
 @end

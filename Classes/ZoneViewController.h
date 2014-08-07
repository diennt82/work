//
//  ZoneViewController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 21/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

@protocol ZoneViewControlerDeleate <NSObject>

- (void)beginProcessing;
- (void)endProcessing;

@end

@interface ZoneViewController : UIViewController
{
    int enabledZones[9];
}

@property (nonatomic, weak) IBOutlet UIButton *zone1;
@property (nonatomic, weak) IBOutlet UIButton *zone2;
@property (nonatomic, weak) IBOutlet UIButton *zone3;
@property (nonatomic, weak) IBOutlet UIButton *zone4;
@property (nonatomic, weak) IBOutlet UIButton *zone5;
@property (nonatomic, weak) IBOutlet UIButton *zone6;
@property (nonatomic, weak) IBOutlet UIButton *zone7;
@property (nonatomic, weak) IBOutlet UIButton *zone8;
@property (nonatomic, weak) IBOutlet UIButton *zone9;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *progress;

@property (nonatomic, strong) NSMutableArray *zoneMap;
@property (nonatomic, strong) NSMutableArray *zoneArray;
@property (nonatomic, strong) NSMutableArray *oldZoneArray;
@property (nonatomic, strong) CamChannel *selectedChannel;

@property (nonatomic, weak) id<ZoneViewControlerDeleate> zoneVCDelegate;

- (void)parseZoneStrings:(NSArray *)zoneStrings;

@end

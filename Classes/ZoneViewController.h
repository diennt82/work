//
//  ZoneViewController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 21/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
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

@property (nonatomic, retain) IBOutlet UIButton * zone1;
@property (nonatomic, retain) IBOutlet UIButton * zone2;
@property (nonatomic, retain) IBOutlet UIButton * zone3;
@property (nonatomic, retain) IBOutlet UIButton * zone4;
@property (nonatomic, retain) IBOutlet UIButton * zone5;
@property (nonatomic, retain) IBOutlet UIButton * zone6;
@property (nonatomic, retain) IBOutlet UIButton * zone7;
@property (nonatomic, retain) IBOutlet UIButton * zone8;
@property (nonatomic, retain) IBOutlet UIButton * zone9;


@property(nonatomic, retain) IBOutlet UIActivityIndicatorView * progress; 


@property (nonatomic, retain)  NSMutableArray * zoneMap ;



@property (nonatomic, retain) NSMutableArray *zoneArray ;
@property (nonatomic, retain) NSMutableArray *oldZoneArray;
@property (nonatomic, retain) CamChannel *selectedChannel;

@property (nonatomic, assign) id<ZoneViewControlerDeleate> zoneVCDelegate;

//- (void)resetButtonImage;
- (NSArray *)zoneSelectedList;


-(void) parseZoneStrings:(NSArray * )zoneStrings;


@end

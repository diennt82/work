//
//  MBP_CamListView.h
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamListItemView.h"


#define CHANNEL_1_TAG 100
#define CHANNEL_1_SETTING_TAG 101

#define CHANNEL_2_TAG 200
#define CHANNEL_2_SETTING_TAG 201

#define CHANNEL_3_TAG 300
#define CHANNEL_3_SETTING_TAG 301

#define CHANNEL_4_TAG 400
#define CHANNEL_4_SETTING_TAG 401

#define SEARCH_CAM_BTN 500
#define ADD_CAM_BTN 501
#define SCAN_CAM_BTN 502
#define LOGOUT_CAM_BTN 503


@interface MBP_CamListView : UIView {

	IBOutlet CamListItemView * channel1; 
	IBOutlet CamListItemView * channel2; 
	IBOutlet CamListItemView * channel3; 
	IBOutlet CamListItemView * channel4; 

	//an array of channels 1-4 -for easy processing 
	NSArray * channelViews; 
	
}

@property (nonatomic,retain) IBOutlet CamListItemView * channel1; 
@property (nonatomic,retain)IBOutlet CamListItemView * channel2; 
@property (nonatomic,retain)IBOutlet CamListItemView * channel3; 
@property (nonatomic,retain)IBOutlet CamListItemView * channel4;
@property (nonatomic, retain) NSArray * channelViews;

- (void) initViews;

@end

//
//  MBP_CamListView.h
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamListItemView.h"

@interface MBP_CamListView : UIView {

	IBOutlet CamListItemView * channel1; 
	IBOutlet CamListItemView * channel2; 
	IBOutlet CamListItemView * channel3; 
	IBOutlet CamListItemView * channel4; 

	
}

@property (nonatomic,retain) IBOutlet CamListItemView * channel1; 
@property (nonatomic,retain)IBOutlet CamListItemView * channel2; 
@property (nonatomic,retain)IBOutlet CamListItemView * channel3; 
@property (nonatomic,retain)IBOutlet CamListItemView * channel4; 



@end

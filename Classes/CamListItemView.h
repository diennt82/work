//
//  CamListItemView.h
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CamListItemView : UIView {

	IBOutlet UIImageView * cameraSnapshot;
	IBOutlet UIImageView * cameraLocationIndicator;
	IBOutlet UIImageView * cameraMelodyIndicator;
	IBOutlet UIImageView * cameraSettings;
	
	IBOutlet UILabel * cameraName;
	IBOutlet UILabel * cameraLastComm; 
}

@property (nonatomic, retain) IBOutlet UIImageView * cameraSnapshot;
@property (nonatomic, retain) IBOutlet UIImageView * cameraLocationIndicator;
@property (nonatomic, retain) IBOutlet UIImageView * cameraMelodyIndicator;
@property (nonatomic, retain) IBOutlet UIImageView * cameraSettings;

@property (nonatomic, retain) IBOutlet UILabel * cameraName;
@property (nonatomic, retain) IBOutlet UILabel * cameraLastComm; 


@end

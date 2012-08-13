//
//  MBP_StatusBarView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MBP_StatusBarView : UIView {


	IBOutlet UIImageView * batt_status_icon;
	IBOutlet UIImageView * video_rec_status_icon;
	IBOutlet UIImageView * channel_status_icon;
	IBOutlet UIImageView * wifi_status_icon;
	IBOutlet UILabel * temperature_label;
	IBOutlet UILabel * camName_label;
}


@property (nonatomic,retain)  IBOutlet UIImageView * video_rec_status_icon;
@property (nonatomic,retain)  IBOutlet UIImageView * channel_status_icon;
@property (nonatomic,retain)  IBOutlet UIImageView * wifi_status_icon, *batt_status_icon;
@property (nonatomic,retain)  IBOutlet UILabel * temperature_label, *camName_label;

- (void) switchChannel:(int) ch;
@end

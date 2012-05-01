//
//  MBP_StatusBarView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MBP_StatusBarView : UIView {

	IBOutlet UIImageView * walkie_talkie_status_icon;
	IBOutlet UIImageView * video_rec_status_icon;
	IBOutlet UIImageView * channel_status_icon;
	IBOutlet UIImageView * led_status_icon;
	IBOutlet UIImageView * wifi_status_icon;
	IBOutlet UIImageView * melody_status_icon;
	IBOutlet UILabel * temperature_label;
}

@property (nonatomic,retain)  IBOutlet UIImageView * walkie_talkie_status_icon;
@property (nonatomic,retain)  IBOutlet UIImageView * video_rec_status_icon;
@property (nonatomic,retain)  IBOutlet UIImageView * channel_status_icon;
@property (nonatomic,retain)  IBOutlet UIImageView * led_status_icon;
@property (nonatomic,retain)  IBOutlet UIImageView * wifi_status_icon;
@property (nonatomic,retain)  IBOutlet UIImageView * melody_status_icon;
@property (nonatomic,retain)  IBOutlet UILabel * temperature_label;

- (void) switchChannel:(int) ch;
@end

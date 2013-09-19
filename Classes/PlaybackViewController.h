//
//  PlaybackViewController
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <H264MediaPlayer/H264MediaPlayer.h>
#import "PlaylistInfo.h"
#import "PlaybackListener.h"
#import "PlayerCallbackHandler.h"

@interface PlaybackViewController : UIViewController<PlayerCallbackHandler>

{
    MediaPlayer *mp;
    PlaybackListener * listener; 
    
    NSTimer * list_refresher;
    NSMutableArray * clips;
}

@property (retain, nonatomic) IBOutlet UIImageView *imageVideo;
@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backBarBtnItem;
@property (retain, nonatomic) IBOutlet UIView *progressView;


@property (nonatomic, retain) PlaylistInfo * clip_info;

@property (nonatomic, retain) NSString *camera_mac;

@property (nonatomic, retain) NSString *urlVideo;

@end

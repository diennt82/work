//
//  PlaybackListener.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 18/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//


#include <H264MediaPlayer/mediaplayer.h>
#import "PlayerCallbackHandler.h"

class PlaybackListener: public MediaPlayerListener
{
public:
    PlaybackListener(id<PlayerCallbackHandler> handler);
    ~PlaybackListener();
    void notify(int msg, int ext1, int ext2);
    int getNextClip(char**);
    
    
    void updateClips(NSMutableArray *  newClips);
    void updateFinalClipCount(int clip_count); 
    
private:
    
    id<PlayerCallbackHandler> mHandler; 
    
    NSMutableArray *mClips;
    int current_clip_index;
    int final_number_of_clips;

};


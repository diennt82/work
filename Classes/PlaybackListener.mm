//
//  PlaybackListener.cpp
//  BlinkHD_ios
//
//  Created by Jason Lee on 18/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#include "PlaybackListener.h"


PlaybackListener::PlaybackListener(id<PlayerCallbackHandler> handler)
{
    final_number_of_clips = -1;
    current_clip_index = 0;
    
    mHandler = handler;
    
    
    mClips = NULL;
}

PlaybackListener::~PlaybackListener()
{
    
}

void PlaybackListener::updateClips(NSMutableArray *  newClips)
{
    mClips = newClips;
}
void  PlaybackListener::updateFinalClipCount(int clip_count)
{
    NSLog(@"set final number of clips: %d", clip_count);
    final_number_of_clips = clip_count;
}

void PlaybackListener::notify(int msg, int ext1, int ext2)
{
    if (mHandler != nil)
    {
        [mHandler handleMessage:msg
                          ext1:ext1
                          ext2:ext2];
    }
}

int PlaybackListener::getNextClip(char** url_cstr)
{
    
    if (final_number_of_clips == [mClips count] &&
        current_clip_index >= final_number_of_clips-1 )
    {
        return MEDIA_PLAYBACK_STATUS_COMPLETE;
    }
    
    
    if (current_clip_index >= [mClips count])
    {
        return MEDIA_PLAYBACK_STATUS_IN_PROGRESS;
    }
    else
    {
        current_clip_index ++;

        NSString * current_clip = [mClips objectAtIndex:current_clip_index];
        
        *url_cstr = (char *) malloc( [current_clip length] * sizeof(char));
        strcpy(*url_cstr, (char *) [current_clip UTF8String]);

        
        return MEDIA_PLAYBACK_STATUS_STARTED;
    }
    
    
	
}

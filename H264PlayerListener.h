//
//  File.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 18/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#ifndef __BlinkHD_ios__H264PlayerListener__
#define __BlinkHD_ios__H264PlayerListener__

#include <H264MediaPlayer/mediaplayer.h>
#import "PlayerCallbackHandler.h"

class H264PlayerListener: public MediaPlayerListener
{
public:
    ~H264PlayerListener();
   H264PlayerListener(id<PlayerCallbackHandler> handler);
    
    void notify(int msg, int ext1, int ext2);
    int getNextClip(char**);
private:
    
    id<PlayerCallbackHandler> mHandler; 
    
};

#endif

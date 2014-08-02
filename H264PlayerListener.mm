//
//  File.cpp
//  BlinkHD_ios
//
//  Created by Jason Lee on 18/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#include "H264PlayerListener.h"



H264PlayerListener::H264PlayerListener(id<PlayerCallbackHandler> handler)
{

    mHandler = handler;
}

H264PlayerListener::~H264PlayerListener()
{
   
}

void H264PlayerListener::notify(int msg, int ext1, int ext2)
{
    if (mHandler != nil)
    {
        [mHandler handleMessage:msg
                          ext1:ext1
                          ext2:ext2];
    }
}

int H264PlayerListener::getNextClip(char** url)
{
	//TODO
    
	return MEDIA_PLAYBACK_STATUS_IN_PROGRESS;
}

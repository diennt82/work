//
//  File.cpp
//  BlinkHD_ios
//
//  Created by Jason Lee on 18/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#include "H264PlayerListener.h"



H264PlayerListener::H264PlayerListener()
{

}

H264PlayerListener::~H264PlayerListener()
{
   
}

void H264PlayerListener::notify(int msg, int ext1, int ext2)
{
    //TODO:
    
}

int H264PlayerListener::getNextClip(char** url)
{
	//TODO
    
	return MEDIA_PLAYBACK_STATUS_IN_PROGRESS;
}

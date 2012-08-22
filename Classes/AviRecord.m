//
//  AviRecord.m
//  AiBallRecorder
//
//  Created by NxComm on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AviRecord.h"
#import "Util.h"

@implementation AviRecord

-(void)ReceiveAudio:(NSData*)audioData
{
	int i = 0;
	int audioLen = [audioData length];
	
	//NSLog(@"receive audio length = %d", audioLen);
	
	if(avi_info->mp4.m_idxSizeWrited + 16 > sizeof(avi_info->mp4.m_idxBuf))
	{
		NSLog(@"buffer full.. ignore audio");
		return;
	}
	
	while(i < audioLen)
	{
		int len;
		if(i + MAX_AUDIO_BUF_LEN <= audioLen)
			len = MAX_AUDIO_BUF_LEN;
		else{
			len = audioLen - i;
		}
		
		NSRange range = {i, len};
		NSData* ptr = [audioData subdataWithRange:range];
		[self AviWriteAudio:ptr length:len];
		i += len;
	}
	
}

-(int)DistanceFrame:(int)aBegin aEnd:(int)aEnd {
	int distance;
	if(aEnd < aBegin)
	{
		distance  = (aEnd + 10000) - aBegin;
	}else{
		distance = aEnd - aBegin;
	}
	return distance;	
}

-ResetCounter {
	iBeginRecAudioFlag = 1;
}

-GetAudio:(NSData*)audioData resetAudioBufferCount:(int)resetAudioBufferCount 
{
	if(resetAudioBufferCount > 0)
	{
		NSMutableData* audioExtractData = [[NSMutableData alloc] init];
		[audioExtractData setLength:resetAudioBufferCount * 16160];
		[self ReceiveAudio:audioExtractData];
		[audioExtractData release];
	}
	
	[self ReceiveAudio:audioData];
	iFileSize = ftell(avi_info->fd);
}

-(void)ReceiveImage:(NSData*)imgData
{
	if(avi_info->mp4.m_idxSizeWrited + 16 > sizeof(avi_info->mp4.m_idxBuf))
	{
		NSLog(@"buffer full.. ignore data");
		return;
	}
	
	[self AviWriteVideo:imgData length:[imgData length]];	
}

-GetImage:(NSData*)imgData imgIndex:(int)imgIndex
{
	if(iBeginRecImgFlag)
	{
		iBeginRecImgFlag = 0;
	}else{
		int missFrame = [self DistanceFrame:iImgCounter aEnd:imgIndex] - 1;

		for(int i = 0; i < missFrame;i++)
		{
			//NSLog(@"Detected missed frame!");
			[self ReceiveImage:imgData];
		}
	}
	[self ReceiveImage:imgData];
	iImgCounter = imgIndex;
	iFileSize = ftell(avi_info->fd);
}

-(int)GetRecordFlag
{
	return iRecordFlag;
}

-SetRecordFlag:(int)recordFlag
{
	iRecordFlag = recordFlag;
}

-AviOpen
{
	unsigned char abyte0[2];
	unsigned char abyte1[4];
	struct AVI_FILE_HEADER *avi_file_header = &(avi_info->AVIFileHeader);

	avi_file_header->ccRIFF[0] = 82;//R
	avi_file_header->ccRIFF[1] = 73;//I
	avi_file_header->ccRIFF[2] = 70;//F
	avi_file_header->ccRIFF[3] = 70;//F		
	fwrite(avi_file_header->ccRIFF, sizeof(avi_file_header->ccRIFF), 1, avi_info->fd);
	[Util IntToByteArray_LSB:0x900422 des:avi_file_header->avisize];
	fwrite(avi_file_header->avisize, sizeof(avi_file_header->avisize), 1, avi_info->fd);
	avi_file_header->ccAVI[0] = 65;//A
	avi_file_header->ccAVI[1] = 86;//V
	avi_file_header->ccAVI[2] = 73;//I
	avi_file_header->ccAVI[3] = 32;//
	fwrite(avi_file_header->ccAVI, sizeof(avi_file_header->ccAVI), 1, avi_info->fd);
	avi_file_header->ccLIST1[0] = 76;//L
	avi_file_header->ccLIST1[1] = 73;//I
	avi_file_header->ccLIST1[2] = 83;//S
	avi_file_header->ccLIST1[3] = 84;//T
	fwrite(avi_file_header->ccLIST1, sizeof(avi_file_header->ccLIST1), 1, avi_info->fd);
	[Util IntToByteArray_LSB:596 des:avi_file_header->List1Size];
	fwrite(avi_file_header->List1Size, sizeof(avi_file_header->List1Size), 1, avi_info->fd);

	avi_file_header->cchdrl[0] = 104;//h
	avi_file_header->cchdrl[1] = 100;//d
	avi_file_header->cchdrl[2] = 114;//r
	avi_file_header->cchdrl[3] = 108;//l
	fwrite(avi_file_header->cchdrl, sizeof(avi_file_header->cchdrl), 1, avi_info->fd);
	avi_file_header->ccavih[0] = 97;//a
	avi_file_header->ccavih[1] = 118;//v
	avi_file_header->ccavih[2] = 105;//i
	avi_file_header->ccavih[3] = 104;//h
	fwrite(avi_file_header->ccavih, sizeof(avi_file_header->ccavih), 1, avi_info->fd);
	avi_file_header->MainAVIHeaderSize = 56;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeaderSize des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwMicroSecPerFrame = 0x1e848;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwMicroSecPerFrame des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwMaxBytesPerSec = 0;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwMaxBytesPerSec des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwPaddingGranularity = 0;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwPaddingGranularity des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwFlags = 272;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwFlags des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwTotalFrames = 600;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwTotalFrames des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwInitialFrames = 0;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwInitialFrames des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwStreams = 2;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwStreams des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwSuggestedBufferSize = 0;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwSuggestedBufferSize des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwWidth = iWidth;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwWidth des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->MainAVIHeader.dwHeight = iHeight;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwHeight des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	[Util IntToByteArray_LSB:0 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);							 
	
	avi_file_header->ccLIST2[0] = 76;//L
	avi_file_header->ccLIST2[1] = 73;//I
	avi_file_header->ccLIST2[2] = 83;//S
	avi_file_header->ccLIST2[3] = 84;//T
	fwrite(avi_file_header->ccLIST2, sizeof(avi_file_header->ccLIST2), 1, avi_info->fd);
	[Util IntToByteArray_LSB:116 des:avi_file_header->List2Size];
	fwrite(avi_file_header->List2Size, sizeof(avi_file_header->List2Size), 1, avi_info->fd);
	avi_file_header->ccstrl1[0] = 115;//s
	avi_file_header->ccstrl1[1] = 116;//t
	avi_file_header->ccstrl1[2] = 114;//r
	avi_file_header->ccstrl1[3] = 108;//l
	fwrite(avi_file_header->ccstrl1, sizeof(avi_file_header->ccstrl1), 1, avi_info->fd);
	avi_file_header->ccstrh1[0] = 115;//s
	avi_file_header->ccstrh1[1] = 116;//t
	avi_file_header->ccstrh1[2] = 114;//r
	avi_file_header->ccstrh1[3] = 104;//h
	fwrite(avi_file_header->ccstrh1, sizeof(avi_file_header->ccstrh1), 1, avi_info->fd);
	[Util IntToByteArray_LSB:56 des:avi_file_header->AVIStreamHeader1Size];
	fwrite(avi_file_header->AVIStreamHeader1Size, sizeof(avi_file_header->AVIStreamHeader1Size), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.ccType[0] = 118;//v
	avi_file_header->AVIStreamHeader1.ccType[1] = 105;//i
	avi_file_header->AVIStreamHeader1.ccType[2] = 100;//d
	avi_file_header->AVIStreamHeader1.ccType[3] = 115;//s
	fwrite(avi_file_header->AVIStreamHeader1.ccType, sizeof(avi_file_header->AVIStreamHeader1.ccType), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.ccHandler[0] = 77;//M
	avi_file_header->AVIStreamHeader1.ccHandler[1] = 74;//J
	avi_file_header->AVIStreamHeader1.ccHandler[2] = 80;//P
	avi_file_header->AVIStreamHeader1.ccHandler[3] = 71;//G

	fwrite(avi_file_header->AVIStreamHeader1.ccHandler, sizeof(avi_file_header->AVIStreamHeader1.ccHandler), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wFlags = 256;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wFlags des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wPriority = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wPriority des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	avi_file_header->AVIStreamHeader1.wInitialFrames = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wInitialFrames des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wScale = 1000;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wScale des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wRate = 8000;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wRate des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wStart = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wStart des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	avi_file_header->AVIStreamHeader1.wLength = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wLength des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wSuggestedBufferSize = 0x100000;
	[Util IntToByteArray_LSB:0x100000 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wQuality = -1;//todosang
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wQuality des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader1.wSampleSize = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wSampleSize des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	[Util IntToByteArray_LSB:0 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	
	avi_file_header->ccstrf1[0] = 115;//s
	avi_file_header->ccstrf1[1] = 116;//t
	avi_file_header->ccstrf1[2] = 114;//r
	avi_file_header->ccstrf1[3] = 102;//f
	fwrite(avi_file_header->ccstrf1, sizeof(avi_file_header->ccstrf1), 1, avi_info->fd);
	[Util IntToByteArray_LSB:40 des:avi_file_header->AVIStreamHeader1Size];
	fwrite(avi_file_header->AVIStreamHeader1Size, sizeof(avi_file_header->AVIStreamHeader1Size), 1, avi_info->fd);
	avi_file_header->AVIStreamFormat.length = 40;
	[Util IntToByteArray_LSB:sizeof(avi_file_header->AVIStreamFormat) des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	avi_file_header->AVIStreamFormat.Width = iWidth;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwWidth des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	avi_file_header->AVIStreamFormat.Height = iHeight;
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwHeight des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	avi_file_header->AVIStreamFormat.Flags = 0x180001;
	[Util IntToByteArray_LSB:0x180001 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	

	avi_file_header->AVIStreamFormat.DXTag[0] = 77;//M
	avi_file_header->AVIStreamFormat.DXTag[1] = 74;//J
	avi_file_header->AVIStreamFormat.DXTag[2] = 80;//P
	avi_file_header->AVIStreamFormat.DXTag[3] = 71;//G
	fwrite(avi_file_header->AVIStreamFormat.DXTag, sizeof(avi_file_header->AVIStreamFormat.DXTag), 1, avi_info->fd);
	avi_file_header->AVIStreamFormat.unknown = 0xfd200;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamFormat.unknown des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	[Util IntToByteArray_LSB:0 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	

	avi_file_header->ccJUNK1[0] = 74;//J
	avi_file_header->ccJUNK1[1] = 85;//U
	avi_file_header->ccJUNK1[2] = 78;//N
	avi_file_header->ccJUNK1[3] = 75;//K
	fwrite(avi_file_header->ccJUNK1, sizeof(avi_file_header->ccJUNK1), 1, avi_info->fd);
	[Util IntToByteArray_LSB:128 des:avi_file_header->JUNK1Size];
	fwrite(avi_file_header->JUNK1Size, sizeof(avi_file_header->JUNK1Size), 1, avi_info->fd);
	fwrite(avi_file_header->cJUNK1, sizeof(avi_file_header->cJUNK1), 1, avi_info->fd);
	avi_file_header->ccLIST3[0] = 76;//L
	avi_file_header->ccLIST3[1] = 73;//I
	avi_file_header->ccLIST3[2] = 83;//S
	avi_file_header->ccLIST3[3] = 84;//T

	fwrite(avi_file_header->ccLIST3, sizeof(avi_file_header->ccLIST3), 1, avi_info->fd);
	[Util IntToByteArray_LSB:260 des:avi_file_header->List3Size];
	fwrite(avi_file_header->List3Size, sizeof(avi_file_header->List3Size), 1, avi_info->fd);
	avi_file_header->ccstrl2[0] = 115;//s
	avi_file_header->ccstrl2[1] = 116;//t
	avi_file_header->ccstrl2[2] = 114;//r
	avi_file_header->ccstrl2[3] = 108;//l
	fwrite(avi_file_header->ccstrl2, sizeof(avi_file_header->ccstrl2), 1, avi_info->fd);
	avi_file_header->ccstrh2[0] = 115;//s
	avi_file_header->ccstrh2[1] = 116;//t
	avi_file_header->ccstrh2[2] = 114;//r
	avi_file_header->ccstrh2[3] = 104;//h
	fwrite(avi_file_header->ccstrh2, sizeof(avi_file_header->ccstrh2), 1, avi_info->fd);
	[Util IntToByteArray_LSB:56 des:avi_file_header->AVIStreamHeader2Size];
	fwrite(avi_file_header->AVIStreamHeader2Size, sizeof(avi_file_header->AVIStreamHeader2Size), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.ccType[0] = 97;//a
	avi_file_header->AVIStreamHeader2.ccType[1] = 117;//u
	avi_file_header->AVIStreamHeader2.ccType[2] = 100;//d
	avi_file_header->AVIStreamHeader2.ccType[3] = 115;//s
	fwrite(avi_file_header->AVIStreamHeader2.ccType, sizeof(avi_file_header->AVIStreamHeader2.ccType), 1, avi_info->fd);
	fwrite(avi_file_header->AVIStreamHeader2.ccHandler, sizeof(avi_file_header->AVIStreamHeader2.ccHandler), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wFlags = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader2.wFlags des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);	
	avi_file_header->AVIStreamHeader2.wPriority = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader2.wPriority des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wInitialFrames = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader2.wInitialFrames des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wScale = 1;
	[Util IntToByteArray_LSB:1 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wRate = avi_info->audio.nSamplesPerSec;
	[Util IntToByteArray_LSB:avi_info->audio.nSamplesPerSec des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wStart = 0;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader2.wStart des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wLength = 0;
	[Util IntToByteArray_LSB:0 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wSuggestedBufferSize = 1024;
	[Util IntToByteArray_LSB:1010 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wQuality = 2000;
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader2.wQuality des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIStreamHeader2.wSampleSize = avi_info->audio.nBlockAlign;
	[Util IntToByteArray_LSB:avi_info->audio.nBlockAlign des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	[Util IntToByteArray_LSB:0 des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	
	avi_file_header->ccstrf2[0] = 115;//s
	avi_file_header->ccstrf2[1] = 116;//t
	avi_file_header->ccstrf2[2] = 114;//r
	avi_file_header->ccstrf2[3] = 102;//f
	fwrite(avi_file_header->ccstrf2, sizeof(avi_file_header->ccstrf2), 1, avi_info->fd);
	[Util IntToByteArray_LSB:50 des:avi_file_header->AVIAudioStreamFormatSize];
	fwrite(avi_file_header->AVIAudioStreamFormatSize, sizeof(avi_file_header->AVIAudioStreamFormatSize), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.wFormatTag = avi_info->audio.wFormatTag;
	[Util ShortToByteArray_LSB:avi_info->audio.wFormatTag des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.nChannels = avi_info->audio.nChannels;
	[Util ShortToByteArray_LSB:avi_info->audio.nChannels des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.nSamplesPerSec = avi_info->audio.nSamplesPerSec;
	[Util IntToByteArray_LSB:avi_info->audio.nSamplesPerSec des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.nAvgBytesPerSec = avi_info->audio.nAvgBytesPerSec;
	[Util IntToByteArray_LSB:avi_info->audio.nAvgBytesPerSec des:abyte1];
	fwrite(abyte1, sizeof(abyte1), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.nBlockAlign = avi_info->audio.nBlockAlign;
	[Util ShortToByteArray_LSB:avi_info->audio.nBlockAlign des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.wBitsPerSample = avi_info->audio.wBitsPerSample;
	[Util ShortToByteArray_LSB:avi_info->audio.wBitsPerSample des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.cbSize = avi_info->audio.cbSize;
	[Util ShortToByteArray_LSB:avi_info->audio.cbSize des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	avi_file_header->AVIAudioStreamFormat.nSamplePerBlock = avi_info->audio.nSamplePerBlock;
	[Util ShortToByteArray_LSB:avi_info->audio.nSamplePerBlock des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.nNumCoef, sizeof(avi_file_header->AVIAudioStreamFormat.nNumCoef), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef1_0, sizeof(avi_file_header->AVIAudioStreamFormat.Coef1_0), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef2_0, sizeof(avi_file_header->AVIAudioStreamFormat.Coef2_0), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef1_1, sizeof(avi_file_header->AVIAudioStreamFormat.Coef1_1), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef2_1, sizeof(avi_file_header->AVIAudioStreamFormat.Coef2_1), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef1_2, sizeof(avi_file_header->AVIAudioStreamFormat.Coef1_2), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef2_2, sizeof(avi_file_header->AVIAudioStreamFormat.Coef2_2), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef1_3, sizeof(avi_file_header->AVIAudioStreamFormat.Coef1_3), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef2_3, sizeof(avi_file_header->AVIAudioStreamFormat.Coef2_3), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef1_4, sizeof(avi_file_header->AVIAudioStreamFormat.Coef1_4), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef2_4, sizeof(avi_file_header->AVIAudioStreamFormat.Coef2_4), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef1_5, sizeof(avi_file_header->AVIAudioStreamFormat.Coef1_5), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef2_5, sizeof(avi_file_header->AVIAudioStreamFormat.Coef2_5), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef1_6, sizeof(avi_file_header->AVIAudioStreamFormat.Coef1_6), 1, avi_info->fd);
	fwrite(avi_file_header->AVIAudioStreamFormat.Coef2_6, sizeof(avi_file_header->AVIAudioStreamFormat.Coef2_6), 1, avi_info->fd);

	avi_file_header->ccJUNK2[0] = 74;//J
	avi_file_header->ccJUNK2[1] = 85;//U
	avi_file_header->ccJUNK2[2] = 78;//N
	avi_file_header->ccJUNK2[3] = 75;//K
	fwrite(avi_file_header->ccJUNK2, sizeof(avi_file_header->ccJUNK2), 1, avi_info->fd);
	[Util IntToByteArray_LSB:126 des:avi_file_header->JUNK2Size];
	fwrite(avi_file_header->JUNK2Size, sizeof(avi_file_header->JUNK2Size), 1, avi_info->fd);
	fwrite(avi_file_header->cJUNK2, sizeof(avi_file_header->cJUNK2), 1, avi_info->fd);
	avi_file_header->ccJUNK3[0] = 74;//J
	avi_file_header->ccJUNK3[1] = 85;//U
	avi_file_header->ccJUNK3[2] = 78;//N
	avi_file_header->ccJUNK3[3] = 75;//K
	fwrite(avi_file_header->ccJUNK3, sizeof(avi_file_header->ccJUNK3), 1, avi_info->fd);
	[Util IntToByteArray_LSB:128 des:avi_file_header->JUNK3Size];
	fwrite(avi_file_header->JUNK3Size, sizeof(avi_file_header->JUNK3Size), 1, avi_info->fd);
	fwrite(avi_file_header->cJUNK3, sizeof(avi_file_header->cJUNK3), 1, avi_info->fd);
	avi_file_header->ccLISTMOVI[0] = 76;//L
	avi_file_header->ccLISTMOVI[1] = 73;//I
	avi_file_header->ccLISTMOVI[2] = 83;//S
	avi_file_header->ccLISTMOVI[3] = 84;//T
	fwrite(avi_file_header->ccLISTMOVI, sizeof(avi_file_header->ccLISTMOVI), 1, avi_info->fd);
	avi_file_header->moviListSize = 0;
	[Util IntToByteArray_LSB:avi_file_header->moviListSize des:avi_file_header->FccmoviListSize];
	fwrite(avi_file_header->FccmoviListSize, sizeof(avi_file_header->FccmoviListSize), 1, avi_info->fd);
	avi_file_header->ccmovi[0] = 109;//m
	avi_file_header->ccmovi[1] = 111;//o
	avi_file_header->ccmovi[2] = 118;//v
	avi_file_header->ccmovi[3] = 105;//i
	fwrite(avi_file_header->ccmovi, sizeof(avi_file_header->ccmovi), 1, avi_info->fd);
	avi_info->mp4.m_idxSizeWrited = 0;
	avi_info->mp4.m_mp4para.dwChunkOffset = 4;
	avi_file_header->moviListSize = 4;
	[Util IntToByteArray_LSB:4 des:avi_file_header->FccmoviListSize];
	avi_info->mp4.m_mp4para.TotalFrameNumber = 0;	
}

-AviClose
{
	struct MP4* mp4 = &(avi_info->mp4);
	struct MOVI_HEADER* movi_header = (struct MOVI_HEADER*)malloc(sizeof(struct MOVI_HEADER));
	struct AVI_FILE_HEADER* avi_file_header = &(avi_info->AVIFileHeader);
	unsigned char abyte0[4];

	movi_header->FourCC[0] = 105;//i
	movi_header->FourCC[1] = 100;//d
	movi_header->FourCC[2] = 120;//x
	movi_header->FourCC[3] = 49;//1
	movi_header->FrameSize = avi_info->mp4.m_idxSizeWrited;
	
	fwrite(movi_header->FourCC, sizeof(movi_header->FourCC), 1, avi_info->fd);
	[Util IntToByteArray_LSB:movi_header->FrameSize des:movi_header->FccFrameSize];
	fwrite(movi_header->FccFrameSize, sizeof(movi_header->FccFrameSize), 1, avi_info->fd);
	if(movi_header->FrameSize > 0) {
		fwrite(avi_info->mp4.m_idxBuf, movi_header->FrameSize, 1, avi_info->fd);
	}
	avi_file_header->MainAVIHeader.dwTotalFrames = mp4->m_mp4para.TotalFrameNumber;
	
	[Util IntToByteArray_LSB:752 + avi_file_header->moviListSize + 8 + movi_header->FrameSize des:avi_file_header->avisize];
	
	double d = (double)(avi_file_header->MainAVIHeader.dwTotalFrames * 1000) / (avi_info->end_video_frame_time_stamp - avi_info->first_video_frame_time_stamp);
	avi_file_header->AVIStreamHeader1.wRate = (int)(d * 1000);
	double d1 = (double)(1000 / d);
	avi_file_header->MainAVIHeader.dwMicroSecPerFrame = (int)d1;
	avi_file_header->AVIStreamHeader1.wLength = avi_file_header->MainAVIHeader.dwTotalFrames;
	
	int pos;
	pos = 4;
	fseek(avi_info->fd, pos, SEEK_SET);
	fwrite(avi_file_header->avisize, sizeof(avi_file_header->avisize), 1, avi_info->fd);
	pos = 32;
	fseek(avi_info->fd, pos, SEEK_SET);
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwMicroSecPerFrame des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	pos = 48;
	fseek(avi_info->fd, pos, SEEK_SET);
	[Util IntToByteArray_LSB:avi_file_header->MainAVIHeader.dwTotalFrames des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);
	pos = 132;
	fseek(avi_info->fd, pos, SEEK_SET);
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wRate des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);	
	pos = 140;
	fseek(avi_info->fd, pos, SEEK_SET);
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader1.wLength des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);	
	
	pos = 400;
	fseek(avi_info->fd, pos, SEEK_SET);	
	[Util IntToByteArray_LSB:avi_file_header->AVIStreamHeader2.wLength des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);	
	pos = 756;
	fseek(avi_info->fd, pos, SEEK_SET);	
	
	[Util IntToByteArray_LSB:avi_file_header->moviListSize des:abyte0];
	fwrite(abyte0, sizeof(abyte0), 1, avi_info->fd);	
	fflush(avi_info->fd);
	fclose(avi_info->fd);
	free(movi_header);
}

-AviWriteVideo:(NSData*)videoData length:(int)length 
{
	struct MP4* mp4 = &(avi_info->mp4);
	struct AVI_FILE_HEADER* avi_file_header = &(avi_info->AVIFileHeader);
	struct MOVI_HEADER* movi_header = (struct MOVI_HEADER*)malloc(sizeof(struct MOVI_HEADER));
	unsigned char abyte1[4];
	unsigned char abyte2[4];
	unsigned char abyte3[4];
	unsigned char abyte4[4];

	movi_header->FourCC[0] = 48;//0
	movi_header->FourCC[1] = 48;//0
	movi_header->FourCC[2] = 100;//d
	movi_header->FourCC[3] = 98;//b
	abyte1[0] = 48;
	abyte1[1] = 48;
	abyte1[2] = 100;
	abyte1[3] = 98;
	movi_header->FrameSize = length;
	[Util IntToByteArray_LSB:16 des:abyte2];
	[Util IntToByteArray_LSB:mp4->m_mp4para.dwChunkOffset des:abyte3];
	[Util IntToByteArray_LSB:movi_header->FrameSize des:abyte4];
	mp4->m_mp4para.TotalFrameNumber++;
	mp4->m_NumCurrentVideo++;
	avi_file_header->moviListSize += movi_header->FrameSize + 8;
	mp4->m_mp4para.dwChunkOffset = mp4->m_mp4para.dwChunkOffset + movi_header->FrameSize + 8;
	
	fwrite(movi_header->FourCC, sizeof(movi_header->FourCC), 1, avi_info->fd);
	[Util IntToByteArray_LSB:movi_header->FrameSize des:movi_header->FccFrameSize];
	fwrite(movi_header->FccFrameSize, sizeof(movi_header->FccFrameSize), 1, avi_info->fd);
	fwrite([videoData bytes], length, 1, avi_info->fd);
	
	//NSLog(@"WriteVideo length is %d", length);
	if(avi_info->mp4.m_idxSizeWrited <= 0xffff0)
	{
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited, abyte1, 4);
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited + 4, abyte2, 4);
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited + 8, abyte3, 4);
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited + 12, abyte4, 4);
		avi_info->mp4.m_idxSizeWrited += 16;
	}
	
	free(movi_header);	
}

-AviWriteAudio:(NSData*)audioData length:(int)length
{
	struct MOVI_HEADER *movi_header = (struct MOVI_HEADER*)malloc(sizeof(struct MOVI_HEADER));
	struct AVI_FILE_HEADER *avi_file_header = &(avi_info->AVIFileHeader);
	struct MP4* mp4 = &(avi_info->mp4);
	unsigned char abyte1[4];
	unsigned char abyte2[4];
	unsigned char abyte3[4];
	unsigned char abyte4[4];
	
	movi_header->FourCC[0] = 48;//0
	movi_header->FourCC[1] = 49;//1
	movi_header->FourCC[2] = 119;//w
	movi_header->FourCC[3] = 98;//b
	movi_header->FrameSize = length;
	abyte1[0] = 48;
	abyte1[1] = 49;
	abyte1[2] = 119;
	abyte1[3] = 98;
	[Util IntToByteArray_LSB:16 des:abyte2];
	[Util IntToByteArray_LSB:mp4->m_mp4para.dwChunkOffset des:abyte3];
	[Util IntToByteArray_LSB:movi_header->FrameSize des:abyte4];
	avi_file_header->moviListSize += movi_header->FrameSize + 8;
	mp4->m_mp4para.dwChunkOffset = mp4->m_mp4para.dwChunkOffset + movi_header->FrameSize + 8;
	avi_file_header->AVIStreamHeader2.wLength += movi_header->FrameSize / avi_file_header->AVIStreamHeader2.wSampleSize;
	
	fwrite(movi_header->FourCC, sizeof(movi_header->FourCC), 1, avi_info->fd);
	[Util IntToByteArray_LSB:movi_header->FrameSize des:movi_header->FccFrameSize];
	fwrite(movi_header->FccFrameSize, sizeof(movi_header->FccFrameSize), 1, avi_info->fd);
	fwrite([audioData bytes], length, 1, avi_info->fd);
	
	if(avi_info->mp4.m_idxSizeWrited <= 0xffff0)
	{
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited, abyte1, 4);
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited + 4, abyte2, 4);
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited + 8, abyte3, 4);
		memcpy(avi_info->mp4.m_idxBuf + avi_info->mp4.m_idxSizeWrited + 12, abyte4, 4);
		avi_info->mp4.m_idxSizeWrited += 16;
	}
	
	free(movi_header);
}

-(int)GetCurrentRecordSize
{
	return iFileSize;
}


-InitWithFilename:(NSString*)filename video_width:(int) w video_height:(int) h
{
	iBeginRecAudioFlag = 1;
	iBeginRecImgFlag = 1;
	
	iWidth = w;
	iHeight= h;
	
	iImgCounter = 0;
	iAudioCounter = 0;
	
	iImageIndex = 0;
	iImageRecIndex = 0;
	
	iAudioIndex = 0;
	iAudioRecIndex = 0;
	
	avi_info = (struct AVI_INFO*)malloc(sizeof(struct AVI_INFO));
	iFileSize = 0;
	
	avi_info->fps = '\036';
	avi_info->audio.wFormatTag = 1;
	avi_info->audio.nSamplesPerSec = 8000;
	avi_info->audio.nChannels = 1;
	avi_info->audio.wBitsPerSample = 16;
	avi_info->audio.nBlockAlign = (unsigned short)((avi_info->audio.nChannels * avi_info->audio.wBitsPerSample) / 8);
	avi_info->audio.nAvgBytesPerSec = avi_info->audio.nSamplesPerSec * avi_info->audio.nBlockAlign;
	avi_info->audio.cbSize = 32;
	avi_info->fd = fopen([filename cString], "wb");
	[self AviOpen];
	
	avi_info->first_video_frame_time_stamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
}

-Init:(NSString*)filename 
{
	iBeginRecAudioFlag = 1;
	iBeginRecImgFlag = 1;
	
	iWidth = 640;
	iHeight= 480;
	
	iImgCounter = 0;
	iAudioCounter = 0;
	
	iImageIndex = 0;
	iImageRecIndex = 0;
	
	iAudioIndex = 0;
	iAudioRecIndex = 0;
	
	avi_info = (struct AVI_INFO*)malloc(sizeof(struct AVI_INFO));
	iFileSize = 0;
	
	avi_info->fps = '\036';
	avi_info->audio.wFormatTag = 1;
	avi_info->audio.nSamplesPerSec = 8000;
	avi_info->audio.nChannels = 1;
	avi_info->audio.wBitsPerSample = 16;
	avi_info->audio.nBlockAlign = (unsigned short)((avi_info->audio.nChannels * avi_info->audio.wBitsPerSample) / 8);
	avi_info->audio.nAvgBytesPerSec = avi_info->audio.nSamplesPerSec * avi_info->audio.nBlockAlign;
	avi_info->audio.cbSize = 32;
	avi_info->fd = fopen([filename cString], "wb");
	[self AviOpen];
	
	avi_info->first_video_frame_time_stamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
}

-Close
{
	avi_info->end_video_frame_time_stamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
	[self AviClose];
}

- (void)dealloc {
    [super dealloc];
}
@end
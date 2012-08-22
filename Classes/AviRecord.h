//
//  AviRecord.h
//  AiBallRecorder
//
//  Created by NxComm on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PublicDefine.h"

struct MAIN_AVI_HEADER {
	int dwMicroSecPerFrame;
	int dwMaxBytesPerSec;
	int dwPaddingGranularity;
	int dwFlags;
	int dwTotalFrames;
	int dwInitialFrames;
	int dwStreams;
	int dwSuggestedBufferSize;
	int dwWidth;
	int dwHeight;
	int dwReserved[4];
};

struct AVI_STREAM_HEADER {
	unsigned char ccType[4];
	unsigned char ccHandler[4];
	int wFlags;
	int wPriority;
	int wInitialFrames;
	int wScale;
	int wRate;
	int wStart;
	int wLength;
	int wSuggestedBufferSize;
	int wQuality;
	int wSampleSize;
	int unknown1;
	int unknown2;
};

struct AVI_STREAM_FORMAT
{
	int length;
	int Width;
	int Height;
	int Flags;
	unsigned char DXTag[4];
	int unknown;
	int Reserved[4];
};

struct AVI_AUDIO_STREAM_FORMAT {
	unsigned short wFormatTag;
	unsigned short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	unsigned short nBlockAlign;
	unsigned short wBitsPerSample;
	unsigned short cbSize;
	unsigned short nSamplePerBlock;
	unsigned char nNumCoef[2];
	unsigned char Coef1_0[2];
	unsigned char Coef2_0[2];
	unsigned char Coef1_1[2];
	unsigned char Coef2_1[2];
	unsigned char Coef1_2[2];
	unsigned char Coef2_2[2];
	unsigned char Coef1_3[2];
	unsigned char Coef2_3[2];
	unsigned char Coef1_4[2];
	unsigned char Coef2_4[2];
	unsigned char Coef1_5[2];
	unsigned char Coef2_5[2];
	unsigned char Coef1_6[2];
	unsigned char Coef2_6[2];
};


struct AVI_FILE_HEADER {
	unsigned char ccRIFF[4];
	unsigned char avisize[4];
	unsigned char ccAVI[4];
	unsigned char ccLIST1[4];
	unsigned char List1Size[4];
	unsigned char cchdrl[4];
	unsigned char ccavih[4];
	int MainAVIHeaderSize;
	struct MAIN_AVI_HEADER MainAVIHeader;
	unsigned char ccLIST2[4];
	unsigned char List2Size[4];
	unsigned char ccstrl1[4];
	unsigned char ccstrh1[4];
	unsigned char AVIStreamHeader1Size[4];
	struct AVI_STREAM_HEADER AVIStreamHeader1;
	unsigned char ccstrf1[4];
	unsigned char AVIStreamFormatSize[4];
	struct AVI_STREAM_FORMAT AVIStreamFormat;
	unsigned char ccJUNK1[4];
	unsigned char JUNK1Size[4];
	unsigned char cJUNK1[128];
	unsigned char ccLIST3[4];
	unsigned char List3Size[4];
	unsigned char ccstrl2[4];
	unsigned char ccstrh2[4];
	unsigned char AVIStreamHeader2Size[4];
	struct AVI_STREAM_HEADER AVIStreamHeader2;
	unsigned char ccstrf2[4];
	unsigned char AVIAudioStreamFormatSize[4];
	struct AVI_AUDIO_STREAM_FORMAT AVIAudioStreamFormat;
	unsigned char ccJUNK2[4];
	unsigned char JUNK2Size[4];
	unsigned char cJUNK2[126];
	unsigned char ccJUNK3[4];
	unsigned char JUNK3Size[4];
	unsigned char cJUNK3[128];
	unsigned char ccLISTMOVI[4];
	int moviListSize;
	unsigned char FccmoviListSize[4];
	unsigned char ccmovi[4];
};

struct AVI_INDEX_ENTRY
{
	unsigned char FourCC[4];
	int dwFlags;
	int dwChunkOffset;
	int dwChunkLength;
};


struct MOVI_HEADER
{
	unsigned char FourCC[4];
	unsigned char FccFrameSize[4];
	int FrameSize;
};

struct RGBQUAD
{
	unsigned char rgbBlue;
	unsigned char rgbGreen;
	unsigned char rgbRed;
	unsigned char rgbReserved;
};

struct BITMAPINFOHEADER
{
	long long biSize;
	int biWidth;
	int biHeight;
	short biPlanes;
	short biBitCount;
	long long biCompression;
	long long biSizeImage;
	int biXPelsPerMeter;
	int biYPelsPerMeter;
	long long biClrUsed;
	long long biClrImportant;
};

struct BITMAPINFO
{
	struct BITMAPINFOHEADER bmiHeader;
	struct RGBQUAD bmiColors;
};

struct MP4PARA
{
	FILE* mp4_idx_fp;
	FILE* mp4_avi_fp;
	int DisplayMode;
	int frame_rate;
	unsigned short Location[20];
	unsigned short AviChunkFileName[128];
	unsigned short IndexChunkFileName[128];
	int TotalFrameNumber;
	int dwChunkOffset;
	int width;
	int height;
};

struct SMP4Info
{
	int short_video_header;
	int random_accessible_vol;
	int video_object_type_indication;
	int video_object_layer_verid;
	int video_object_layer_priority;
	int newpred_enable;
	int aspect_ratio_info;
	int par_width;
	int par_height;
	int scalability;
	int video_object_layer_shape;
	int video_object_layer_shape_extension;
	int vop_time_increment_resolution;
	int vop_time_increment;
	int fixed_vop_time_increment;
	int video_object_layer_width;
	int video_object_layer_height;
	int interlaced;
	int obmc_disable;
	int sprite_enable;
	int quant_precision;
	int quant_type;
	int bits_per_pixel;
	int quarter_sample;
	int resync_marker_disable;
	int data_partitioned;
	int reversible_vlc;
	int vop_coding_type;
	int vop_rounding_type;
	int reduced_resolution_vop_enable;
	int vop_reduced_resolution;
	int change_conv_ratio_disable;
	int vop_constant_alpha;
	int vop_constant_alpha_value;
	int intra_dc_vlc_thr;
	int vop_quant;
	int vop_fcode_forward;
	int vop_fcode_backward;
	int vop_shape_coding_type;
	int vop_id;
	int vop_id_for_prediction;
	int vop_id_for_prediction_indication;
	int temporal_reference;
	int split_screen_indicator;
	int document_camera_indicator;
	int full_picture_freeze_release;
	int source_format;
	int picture_coding_type;
	int pei;
	int psupp;
	int gob_number;
	int use_intra_dc_vlc;
	int time_code;
	int vop_time_increment_length;
	int newpred_length;
	int vop_totalsize_y;
	int vop_totalsize_c;
	int vop_totalsize;
	int video_object_layer_width_c;
	int video_object_layer_height_c;
	int mb_number;
	int mb_number_len;
	int resync_mark_len;
	int mb_width;
	int mb_height;
	int bits_processed;
	int p_vop_count;
};


struct MP4
{
	struct BITMAPINFO m_vih;
	struct SMP4Info m_info;
	struct MP4PARA m_mp4para;
	int m_NumCurrentVideo;
	int m_HeaderLen;
	int m_FrameBufLen;
	int m_bStartAVI;
	int m_bGotFirstI;
	int m_VideoType;
	unsigned short m_FrameType;
	int m_FAviSize;
	int m_FIdxSize;
	int m_FIdxWSize;
	int m_FinalSize;
	int m_FErrFlag;
	int m_Frate;
	int m_FOddFlag;
	unsigned char m_VolHeader[20];
	struct MOVI_HEADER m_MovHeader;
	struct AVI_INDEX_ENTRY m_AviIdxEntry;
	struct AVI_FILE_HEADER m_AviFHeader;
	unsigned char* m_tBuf;
	unsigned char* m_AVIBuf;
	unsigned char* m_FrameBuf;
	unsigned char* m_iBuf;
	unsigned char* m_oBuf;
	unsigned char m_idxBuf[0x100000];
	int m_iSize;
	int m_oSize;
	int m_oSizeWrited;
	int m_idxSizeWrited;
};


struct AVI_INFO {
	unsigned short type;
	int time;
	int last;
	int frames;
	unsigned short fps;
	unsigned short head[40];
	FILE* fp;
	FILE* fp_idx;
	FILE* fd;
	int size;
	int frate;
	long long first_video_frame_time_stamp;
	long long end_video_frame_time_stamp;
	long long vts;
	struct AVI_FILE_HEADER AVIFileHeader;
	struct MP4 mp4;
	int mp4_vol_hdr_is_sent;
	struct AVI_AUDIO_STREAM_FORMAT audio;
};

@interface AviRecord : NSObject {
	struct AVI_INFO* avi_info;
	int iState;
	int iInitFlag;
	NSString* iFilename;
	int iWidth, iHeight;
	int iImageIndex, iImageRecIndex;
	int iAudioIndex, iAudioRecIndex;
	int iRecordFlag, iImgCounter, iAudioCounter;
	int iFileSize;
	int iBeginRecAudioFlag, iBeginRecImgFlag;
}

-(void)ReceiveAudio:(NSData*)audioData;
-(int)DistanceFrame:(int)aBegin aEnd:(int)aEnd;
-ResetCounter;
-GetAudio:(NSData*)audioData resetAudioBufferCount:(int)resetAudioBufferCount;
-(void)ReceiveImage:(NSData*)imgData;
-GetImage:(NSData*)imgData imgIndex:(int)imgIndex;
-(int)GetRecordFlag;
-SetRecordFlag:(int)recordFlag;
-AviOpen;
-AviClose;
-AviWriteVideo:(NSData*)videoData length:(int)length;
-AviWriteAudio:(NSData*)audioData length:(int)length;
-(int)GetCurrentRecordSize;
-Init:(NSString*)filename;
-InitWithFilename:(NSString*)filename video_width:(int) w video_height:(int) h;
-Close;
@end

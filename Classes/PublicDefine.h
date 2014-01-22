/*
 *  PublicDefines.h
 *
 *  Created by NxComm on 1/2/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef PUBLICDEFINE_H_
#define PUBLICDEFINE_H_


//#define IBALL_STREAM_ONLY_MODE // for customer testing

#define AIBALL_GET_STREAM_ONLY_REQUEST @"GET /?action=stream HTTP/1.1\r\n"

#define IBALL_AUDIO_SUPPORT 1
#define AIBALL_GET_REQUEST @"GET /?action=appletvastream HTTP/1.1\r\n"


#define DEFAULT_SSID_PREFIX @"Camera-"
#define DEFAULT_SSID_HD_PREFIX @"CameraHD-"

//define default IP
#define DEFAULT_IP_PREFIX @"192.168.2."
#define DEFAULT_IP_PREFIX_CAMERA_C89    @"192.168.193."


#define DEFAULT_BM_IP @"192.168.2.1"
#define DEFAULT_BM_IP_CAMERA_C89    @"192.168.193.1"
#define DEFAULT_BM_PORT 80
#define DEFAULT_AIBALL_SERVER @"http://192.168.2.1:80"
//#define DEFAULT_AIBALL_SERVER @"http://192.168.1.107:80"

#define BOUNDARY_STRING @"--boundarydonotcross"
#define AUTHENTICATION_ERROR    @"HTTP/1.0 401"
#define SESSIONKEY_MISMATCHED   @"HTTP/1.0 601"
#define RELAY2_ERROR_851        @"HTTP/1.1 851"


#define MAX_IMAGE_BUF_NUMBER 2
#define MAX_IMAGE_BUF_LEN 65536

#define MAX_AUDIO_BUF_NUMBER 2
#define MAX_AUDIO_BUF_LEN 1010

#define BUFFER_EMPTY 0
#define BUFFER_PROCESSING 1
#define BUFFER_FULL 2

#define DEFAULT_MAX_RECORD_SIZE 50

#define SCAN_TIMEOUT 60//5*60 //5 mins

//#define AIBALL_QUERY_REQUEST_STRING   @"Mot-Cam QUERY   *               192.168.3.125  "
#define AIBALL_QUERY_REQUEST_STRING   @"Mot-Cam QUERY   *               "



// ADDED 

#define DEFAULT_CONTRAST_LVL    2
#define DEFAULT_BRIGHTNESS_LVL  4


/* Movement motor duty cycle max*/
#define IRABOT_DUTYCYCLE_MAX    1.0
#define IRABOT_DUTYCYCLE_LR_MAX 1.0


/* Movement command http req timeout */
#define IRABOT_HTTP_REQ_TIMEOUT  1



/*20110803: AUDIO_Recording in Irabot
 * Commen the flag below to disable the feature
 */

#define IRABOT_AUDIO_RECORDING_SUPPORT 

#ifdef IRABOT_AUDIO_RECORDING_SUPPORT
#define IRABOT_AUDIO_RECORDING_PORT 51108

#define SENDING_SOCKET_TAG 2
#endif


/*20110803: add 300ms per HS requirement 
 if there is a change in direction from LF->RT or vice vesa 
 delay for 300ms before sending
 */ 
#define IRABOT_DIRECTIONAL_CHANGE_DELAY 1

/* Debug: use brightness Plus/minus as UPDN and LFRT direction 
 to test sending cmd to device simultaneously 
 */
#define DEBUG_SIMULATE_DIRECTION_HTTP_REQ 0
 
/* TEMPORARY: Toggle the LEFT and RIGHT : 
   i.e. usr press LEFT -> send RIGHT, usr press RIGHT -> send LEFT
 
#define REVERT_LEFT_RIGHT_DIRECTION 1
 
*/
#define REVERT_UP_DOWN_DIRECTION 1

/* DESIGN 2 of direction control 
   - refer to Design document 
 */
#define DESIGN_2 1

/* save audio data in to a file in iphone/ipad document directories */
#define DBG_AUDIO 0

/* 20110819: embedd wifi in video data 
 - enable this flag to read wifi and battery info */
#define WIFI_AND_BATTERY_IN_VIDEO_DATA 1

// Move from FirstPage
#define FIRST_TIME_SETUP @"_first_time_setup"

#if 0



#if WIFI_AND_BATTERY_IN_VIDEO_DATA
#define WIFI_AND_BATTERY_POLLING_PERIOD 0.5 //3 /*seconds*/
#else
#define WIFI_AND_BATTERY_POLLING_PERIOD 30 /*seconds*/
#endif

/* WORK AROUND: video image from rabot has mirror image
   - use this flag to mirror it to back */
#define MIRROR_VIDEO_IMAGE 0


//#define BATTERY_QUERY_AT_10sec 1
#define DONT_UPDATE_BATTERY_VALUE 1

#endif //0

//for debug purpose (see FPS and View in Stun/relay/local
#define SHOW_DEBUG_INFO

#endif /* PUBLICDEFINE_H_ */

#define CAMERA_UDID @"udid"


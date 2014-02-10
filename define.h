//
//  define.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 24/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#ifndef BlinkHD_ios_define_h
#define BlinkHD_ios_define_h



//define macro
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?YES:NO
#define isiPhone4  ([[UIScreen mainScreen] bounds].size.height == 480)?YES:NO
#define CONCURRENT_SETUP    1


#define SET_UP_CAMERA @"SET_UP_CAMERA"
#define BLUETOOTH_SETUP  1
#define WIFI_SETUP      2




//timeout
#define CAMERA_NAME_MAX 20
#define TIME_OUT_RECONNECT_BLE  30.0
#define SHORT_TIME_OUT_SEND_COMMAND     10.0
#define LONG_TIME_OUT_SEND_COMMAND     30.0



//Define TAG
#define ALERT_ASK_FOR_RETRY_WIFI_TAG    1
#define RETRY_CONNECTION_BLE_FAIL_TAG   2

//define font
#define PN_REGULAR_FONT             @"ProximaNova-Regular"
#define PN_REGULAR_ITALIC_FONT      @"ProximaNova-RegularItalic"
#define PN_BLACK_FONT               @"ProximaNova-Black"
#define PN_BOLD_FONT                @"ProximaNova-Bold"
#define PN_BOLD_IT_FONT             @"ProximaNova-BoldIt"
#define PN_EXTRA_BOLD_FONT          @"ProximaNova-Extrabold"
#define PN_LIGHT_FONT               @"ProximaNova-Light"
#define PN_LIGHT_ITALIC_FONT        @"ProximaNova-LightItalic"
#define PN_SEMIBOLD_FONT            @"ProximaNova-Semibold"
#define PN_SEMIBOLD_ITALIC_FONT     @"ProximaNova-SemiboldItalic"





//define color
#define TIMER_COLOR         ff3504
#define RECORD_VIDEO_COLOR  00acf7

#endif

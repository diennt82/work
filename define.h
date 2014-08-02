//
//  define.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 24/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#ifndef BlinkHD_ios_define_h
#define BlinkHD_ios_define_h


//get screen size
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

//define macro
#define isiOS7AndAbove ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)?YES:NO

#define isPhoneLandscapeMode (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) || UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?YES:NO
#define isiPhone4  ([[UIScreen mainScreen] bounds].size.height == 480)?YES:NO

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define CONCURRENT_SETUP    1


#define SET_UP_CAMERA @"SET_UP_CAMERA"
#define BLUETOOTH_SETUP  1
#define WIFI_SETUP      2




//timeout
#define MAX_LENGTH_CAMERA_NAME  30
#define MIN_LENGTH_CAMERA_NAME  5
#define TIME_OUT_RECONNECT_BLE  30.0
#define SHORT_TIME_OUT_SEND_COMMAND     7.0
#define LONG_TIME_OUT_SEND_COMMAND     30.0



//Define TAG
#define ALERT_ASK_FOR_RETRY_WIFI_TAG    1
#define RETRY_CONNECTION_BLE_FAIL_TAG   2

//define font
#define PN_REGULAR_FONT             @"ProximaNova-Regular"
#define PN_REGULAR_ITALIC_FONT      @"ProximaNova-RegularItalic"        //no ok
#define PN_BLACK_FONT               @"ProximaNova-Black"
#define PN_BOLD_FONT                @"ProximaNova-Bold"
#define PN_BOLD_IT_FONT             @"ProximaNova-BoldIt"           //no ok
#define PN_EXTRA_BOLD_FONT          @"ProximaNova-Extrabold"        //NO OK
#define PN_LIGHT_FONT               @"ProximaNova-Light"
#define PN_LIGHT_ITALIC_FONT        @"ProximaNova-LightItalic"      //NO ok
#define PN_SEMIBOLD_FONT            @"ProximaNova-Semibold"
#define PN_SEMIBOLD_ITALIC_FONT     @"ProximaNova-SemiboldItalic"       //NO OK





//define color
#define TIMER_COLOR         ff3504
#define RECORD_VIDEO_COLOR  00acf7

//define margin, padding
#define PADDING_BOTTOM_TEXT 21.0f

#define PADDING_BOTTOM_IMAGE 40.5f

//define for melody
#define HEIGHT_CELL_TABLE_IPHONE                   48
#define MARGIN_LEFT_BUTTON_CELL_TABLE_IPHONE       10
#define MARGIN_LEFT_TEXT_CELL_TABLE_IPHONE         47

#define ALIGN_TOP_OF_TIME_LINE 18
#define ENABLE_DO_NOT_DISTURB   @"EnableDoNotDisturb"
#define TIME_TO_EXPIRED         @"TimeToExpire"


#endif

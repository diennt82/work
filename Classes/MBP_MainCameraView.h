//
//  MBP_MainCameraView.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBP_iosViewController.h"

@class MBP_iosViewController;

@interface MBP_MainCameraView : UIView {
	IBOutlet UIImageView * videoView;
	
	IBOutlet UIImageView * directionPad;
	IBOutlet UIImageView * directionIndicator;
	
	IBOutlet UIActivityIndicatorView * progressView;
	
	MBP_iosViewController * viewController;
	
	float translation_up_limit, translation_down_limit, translation_left_limit, translation_right_limit;
    CGPoint	beginLocation;
	
}

@property (nonatomic,retain) IBOutlet UIImageView * directionPad;
@property (nonatomic,retain) IBOutlet UIImageView * directionIndicator;

@property (nonatomic,retain) IBOutlet UIImageView * videoView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * progressView;

@property (nonatomic,retain)  MBP_iosViewController * viewController;


- (void) initializedWithViewController:(MBP_iosViewController *) viewctlr;

- (void) touchEventAt:(CGPoint) location phase:(UITouchPhase) phase;
- (void) _touchesbegan: (CGPoint) location;
- (void) _touchesmoved: (CGPoint) location;
- (void) _touchesended: (CGPoint) location;
- (void) validatePoint: (CGPoint)location andTranslateV:(UIView*) view began: (BOOL)isBegan;

@end

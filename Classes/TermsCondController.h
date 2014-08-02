//
//  TermsCondController.h
//  BlinkHD_ios
//
//  Created by openxcell on 5/15/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsCondController : UIViewController<UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webViewTC;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;

@end

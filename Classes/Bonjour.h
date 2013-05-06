//
//  Bonjour.h
//  MBP_ios
//
//  Created by nxcomm on 06/05/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSNetServices.h>
@interface Bonjour : UIViewController <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    NSNetServiceBrowser * _browserService;
    NSNetService * _currentService;
}

@property (nonatomic, retain) NSTimer * timer;
@property (assign, nonatomic) id<NSNetServiceBrowserDelegate> delegate;
@property (assign, nonatomic) BOOL isSearching;
@property (nonatomic, retain) NSMutableArray * serviceArray;
@end

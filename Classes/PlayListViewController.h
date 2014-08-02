//
//  PlayListViewController.h
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Hubble Connected Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaylistDelegate <NSObject>

- (void)stopStreamWhenPushPlayback;

@end

@interface PlayListViewController : UITableViewController

@property (nonatomic, retain) id<PlaylistDelegate> playlistDelegate;
@property (nonatomic, retain) NSMutableArray *playlistArray;
@property (nonatomic, assign) UINavigationController *navController;

@end

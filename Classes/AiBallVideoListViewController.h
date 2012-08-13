//
//  AiBallVideoListViewController.h
//  AiBallRecorder
//
//  Created by NxComm on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiBallPlayViewController.h"


#define PLAYLIST_BACK_BUTTON 400

@interface AiBallVideoListViewController : UITableViewController {
	NSArray* filelist;
	AiBallPlayViewController *playViewController;
	

}



- (void) refreshFileList;

@end

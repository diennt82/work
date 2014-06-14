//
//  PlayListViewController.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import "PlayListViewController.h"
#import "PlaylistInfo.h"
#import "PlaybackViewController.h"

@interface PlayListViewController ()

@end

@implementation PlayListViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"self.playlistArray.count = %d", self.playlistArray.count);
    return self.playlistArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2) {
        [cell setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:1 alpha:1]];
    }
    else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaylistCell";
    PlaylistCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaylistCell" owner:nil options:nil];
    for (id curObj in objects) {
        if([curObj isKindOfClass:[UITableViewCell class]]) {
            cell = (PlaylistCell *)curObj;
            break;
        }
    }
    
    // Configure the cell...
    PlaylistInfo *playlistInfo = _playlistArray[indexPath.row];
    if ( playlistInfo ) {
        cell.imgViewSnapshot.image = [UIImage imageNamed:@"no_img_available.jpeg"];
        
        if ( !playlistInfo.imgSnapshot ) {
            [cell.activityIndicator startAnimating];
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                playlistInfo.imgSnapshot = [self imageWithUrlString:playlistInfo.urlImage scaledToSize:CGSizeMake(113, 64)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
                    [cell.activityIndicator stopAnimating];
                    cell.activityIndicator.hidden = YES;
                });
            });
        }
        else {
            NSLog(@"playlistInfo.imgSnapshot already");
            cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
             cell.activityIndicator.hidden = YES;
        }
        
        //Set motion type
        if ( playlistInfo.titleString && ![playlistInfo.titleString isEqualToString:@""] ) {
            cell.labelTitle.text = playlistInfo.titleString;
        }
        else {
            cell.labelTitle.text = @"Motion Detected";
        }
        
        //set date
        NSDate *date = [playlistInfo getTimeCode];
        if ( date ) {
            NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"dd-MM-yyyy 'at' HH:mm"];
            NSTimeZone *gmt = [NSTimeZone systemTimeZone];
            [formatter setTimeZone:gmt];
            
            NSString *date_str =  [formatter stringFromDate:date];
            NSLog(@"date_str: %@",date_str);
            cell.labelDate.text = date_str;
        }
        else {
            cell.labelDate.text = @"";
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (UIImage *)imageWithUrlString:(NSString *)urlString scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
    
	[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    PlaylistInfo *playlistInfo = (PlaylistInfo *)[_playlistArray objectAtIndex:indexPath.row];
    NSLog(@"urlFile = %@", playlistInfo.urlFile);
    
    if ( playlistInfo.urlFile && ![playlistInfo.urlFile isEqualToString:@""] && playlistInfo.imgSnapshot ) {
        PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] initWithNibName:@"PlaybackViewController" bundle:nil];
        [playbackViewController setClipInfo:playlistInfo];
        
        if ( _playlistDelegate ) {
            [_playlistDelegate stopStreamWhenPushPlayback];
            self.playlistDelegate = nil;
        }
        
        [self.navController pushViewController:playbackViewController animated:NO];
        [playbackViewController release];
    }
    else {
        NSLog(@"urlFile nil");
        [[[[UIAlertView alloc] initWithTitle:@""
                                     message:@"There is no clip associated with this snapshot"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] autorelease] show];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = @"";
    if ( section == 0 ) {
        sectionName = NSLocalizedString(@"Earlier Events", @"Earlier Events");
    }
    return sectionName;
}

@end

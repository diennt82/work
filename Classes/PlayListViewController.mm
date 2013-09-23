//
//  PlayListViewController.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "PlayListViewController.h"
#import "PlaylistInfo.h"
#import "PlaybackViewController.h"

@interface PlayListViewController ()

@end

@implementation PlayListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"self.playlistArray.count = %d", self.playlistArray.count);
    return self.playlistArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:1 alpha:1]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaylistCell";
    PlaylistCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaylistCell" owner:nil options:nil];
    
    for (id curObj in objects)
    {
        
        if([curObj isKindOfClass:[UITableViewCell class]])
        {
            cell = (PlaylistCell *)curObj;
            break;
        }
    }
    
    // Configure the cell...
    
    PlaylistInfo *playlistInfo = [self.playlistArray objectAtIndex:indexPath.row];
    if (playlistInfo) {
        cell.imgViewSnapshot.image = [UIImage imageNamed:@"no_img_available.jpeg"];
        
        if (playlistInfo.imgSnapshot == nil)
        {
            [cell.activityIndicator startAnimating];
            
            CGSize newSize = CGSizeMake(113, 64);
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q,
                           ^{
                               playlistInfo.imgSnapshot = [self imageWithUrlString:playlistInfo.urlImage scaledToSize:newSize];
                               
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  //NSLog(@"img = %@", img);
                                                  cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
                                                  [cell.activityIndicator stopAnimating];
                                                  cell.activityIndicator.hidden = YES;
                                              }
                                              );
                           });
        }
        else
        {
            NSLog(@"playlistInfo.imgSnapshot already");
            cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
             cell.activityIndicator.hidden = YES;
        }
        
        //Set motion type
        if (playlistInfo.titleString != nil &&
            ([playlistInfo.titleString isEqualToString:@""] == FALSE))
        {
            cell.labelTitle.text = playlistInfo.titleString;
        }
        else
        {
            cell.labelTitle.text = @"Motion Detected";
        }
        
        //set date
        
        NSDate * date = [playlistInfo getTimeCode];
        if (date != nil)
        {
            
            NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"dd-MM-yyyy 'at' HH:mm"];
            NSTimeZone *gmt = [NSTimeZone systemTimeZone];
            [formatter setTimeZone:gmt];
            
            
            NSString * date_str =  [formatter stringFromDate:date];
            
            NSLog(@"date_str: %@",date_str);
            
            cell.labelDate.text = date_str;
        }
        else
        {
            cell.labelDate.text = @""; //set empty
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
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    PlaylistInfo *playlistInfo = (PlaylistInfo *)[self.playlistArray objectAtIndex:indexPath.row];
    
    NSLog(@"urlFile = %@", playlistInfo.urlFile);
    
    if( playlistInfo.urlFile != nil &&
       ([playlistInfo.urlFile isEqualToString:@""] == FALSE )&&
       playlistInfo.imgSnapshot != nil )
    {
        
        
        PlaybackViewController *playbackViewController = [[PlaybackViewController alloc]
                                                          initWithNibName:@"PlaybackViewController" bundle:nil];
        playbackViewController.clip_info = playlistInfo;
        
        if (self.playlistDelegate != nil)
        {
            [self.playlistDelegate stopStreamWhenPushPlayback];
            self.playlistDelegate = nil;
        }
        
        [self.navController pushViewController:playbackViewController animated:NO];
        [playbackViewController release];
    }
    else
    {
        NSLog(@"urlFile nil");
        [[[[UIAlertView alloc] initWithTitle:@""
                                     message:@"There is no clip associated with this snapshot"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil]
          autorelease]
         show];
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Earlier Events", @"Earlier Events");
            break;
        
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end

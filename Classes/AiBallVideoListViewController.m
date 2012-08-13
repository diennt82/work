//
//  AiBallVideoListViewController.m
//  AiBallRecorder
//
//  Created by NxComm on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AiBallVideoListViewController.h"
#import "AiBallPlayViewController.h"
#import "Util.h"

@implementation AiBallVideoListViewController


#pragma mark -
#pragma mark View lifecycle


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{

	NSArray * nibArray =  [[NSBundle mainBundle] loadNibNamed:nibName 
								  owner:self 
								options:nil];
	
	UIView * myCustomView = (UIView *)[nibArray objectAtIndex:0];
	self.tableView = (UITableView *) [[myCustomView subviews] objectAtIndex:0];
	
	
	NSLog(@"table frame: %f %f ", self.tableView.frame.size.width, self.tableView.frame.size.height);

	
	return self;//[super initWithNibName:nibName bundle:nibBundle];
	
		
	
	
}



- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
			
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.sectionHeaderHeight = 40;
	
	self.tableView.bounces = NO;
	
	CGRect frame = self.tableView.frame;
	
	NSLog(@"table frame: %f %f ", frame.size.width, frame.size.height);
	
	
	UIView * bgView = [[UIView alloc] initWithFrame:frame];
	[bgView autorelease];
	UIImageView * bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height)];
	[bgImg setImage:[UIImage imageNamed:@"background.png"]];
	
	[bgImg autorelease];
	[bgView addSubview:bgImg];
	self.tableView.backgroundView = bgView;
	
	
	
	
    [super viewWillAppear:animated];
	[self refreshFileList];
}

- (void)refreshFileList
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSPredicate *containPred = [NSPredicate predicateWithFormat:@"SELF endswith[cd] %@", @".avi"]; 	
	
	if(filelist != nil) {
		[filelist release];
	}
	filelist = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath: documentsDirectory error:nil]
				filteredArrayUsingPredicate:containPred];
	[filelist retain];
	
	
	[self.tableView reloadData];	
	
	
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
 - (void)viewWillDisappear:(BOOL)animated {	
 aviPlayer.videoSink = self;
 [aviPlayer Start:[self filename]];
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
	
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
	        (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	
	
}

#pragma mark -
#pragma mark Table view data source


- (UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section {
    
	CGRect frame = self.tableView.frame;
	
	UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,40)];
	//containerView.backgroundColor = [UIColor blackColor];
	//--- Setting ICON ---
	
	UIImageView * iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40,40)];
	[iconImg autorelease];
	[iconImg setImage:[UIImage imageNamed:@"large_icon_2_1.png"]];
	
	
	//----- Label --
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,0,frame.size.width-40-40,40)];
	[headerLabel autorelease];
	
	headerLabel.text = @"Playlist";//[Internationalization get:@"Settings" alter:@"Settings"];
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.shadowColor = [UIColor whiteColor];
	headerLabel.shadowOffset = CGSizeMake(0,1);
	headerLabel.font = [UIFont boldSystemFontOfSize:22];
	headerLabel.backgroundColor = [UIColor clearColor];
	
	//--- Back Button --- 
	UIButton * back = [[UIButton alloc]  initWithFrame:CGRectMake(frame.size.width - 40 ,5,40,40)];
	[back autorelease];
	back.tag = PLAYLIST_BACK_BUTTON; 
	[back setImage:[UIImage imageNamed:@"arrowleft.png"] forState:UIControlStateNormal];
	[back addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[containerView addSubview:headerLabel];
	[containerView addSubview:iconImg];
	[containerView addSubview:back];
	
	
	
	
    return containerView;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [filelist count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	
    cell.textLabel.text = [filelist objectAtIndex:indexPath.row];
	
    return cell;
}

/*
- (BOOL)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		NSString* delFileName = [NSString stringWithFormat:@"%@%@%@", [Util getRecordDirectory], @"/", [filelist objectAtIndex:indexPath.row]];
		unlink([delFileName cStringUsingEncoding:[NSString defaultCStringEncoding]]);
		[self refreshFileList];
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	

	NSLog(@"selected at row: %d", indexPath.row);
    // Navigation logic may go here. Create and push another view controller.
	if(playViewController == nil) {
		playViewController = [[AiBallPlayViewController alloc] initWithNibName:@"AiBallPlayViewController" bundle:nil];
	}
	playViewController.filename = [NSString stringWithFormat:@"%@%@%@", [Util getRecordDirectory], @"/", [filelist objectAtIndex:indexPath.row]];
	
	//[self.navigationController pushViewController:playViewController animated:YES];
	
	[self presentModalViewController:playViewController animated:YES];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	if(playViewController != nil) {
		[playViewController release];
		playViewController = nil;
	}
}


- (void)dealloc {
    [super dealloc];
}


- (void) btnPressed: (id) sender
{
	int sender_tag = ((UIButton *) sender).tag;
	if (sender_tag	== PLAYLIST_BACK_BUTTON)
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	
	
}
@end


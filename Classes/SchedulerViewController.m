//
//  SchedulerViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define NUM_COL 8
#define NUM_ROW 25

#import "SchedulerViewController.h"
#import "CellImageView.h"

@interface SchedulerViewController () <CellImageViewDelegate>
{
    BOOL selectedImageCell[25][8];
}

@property (nonatomic) NSInteger imageCellWidth;
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) NSArray *dayArray;

@end

@implementation SchedulerViewController

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
    
    self.imageCellWidth = UIScreen.mainScreen.bounds.size.width / 8;
    self.dayArray = [NSArray arrayWithObjects:@"Hours", @"Mon", @"Tue", @"Wed", @"Thur", @"Fri", @"Sat", @"Sun", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CellImageViewDelegate

- (void)tapOnImageAtRow:(NSInteger)row lolumn:(NSInteger)col state:(BOOL)selected
{
    selectedImageCell[row][col] = selected;
    
    if (selected)
    {
        for (int i = row - 1; i > -1; i--)
        {
            if(selectedImageCell[i][col] == selected)
            {
                // True
                
                for (int j = i; j < row; j++)
                {
                    selectedImageCell[j][col] = selected;
                }
                
                break;
            }
        }
    }
    
    for (int i = row + 1; i < NUM_ROW; i++)
    {
        if (selectedImageCell[i][col] == selected)
        {
            for (int j = row + 1; j < i; j++)
            {
                selectedImageCell[j][col] = selected;
            }
            
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)reloadDataInTableView
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return NUM_ROW;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tmpView = [[UIView alloc] init];
    
    //for (int i = 0; i < NUM_COL; i++)
    for (int i = 0; i < _numberOfColumn; i++)
    {
        UIImage *image =[UIImage imageNamed:@"hour-img"];
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * _imageCellWidth, 0, _imageCellWidth, tableView.rowHeight)];
        [dayLabel setBackgroundColor:[UIColor colorWithPatternImage:image]];
        dayLabel.text = [_dayArray objectAtIndex:i];
        dayLabel.textColor = [UIColor whiteColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        
        [tmpView addSubview:dayLabel];
    }
    return tmpView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    //for (int i = 0; i < NUM_COL; i++)
    for (int i = 0; i < _numberOfColumn; i++)
    {
        if (i > 0)
        {
            if (selectedImageCell[indexPath.row][i] == FALSE)
            {
                self.image =[UIImage imageNamed:@"DotCell"];
            }
            else
            {
                self.image = [UIImage imageNamed:@"selected-img"];
            }
            
            //UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
            CellImageView *imgView = [[CellImageView alloc] initWithImage:self.image];
            
            imgView.frame = CGRectMake(i * _imageCellWidth, 0, _imageCellWidth, tableView.rowHeight);
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:imgView
                                                                                        action:@selector(singleTapGestureCaptured:)];
            [imgView addGestureRecognizer:singleTap];
            [imgView setMultipleTouchEnabled:YES];
            [imgView setUserInteractionEnabled:YES];
            
            imgView.rowIndex = indexPath.row;
            imgView.colomnIndex = i;
            imgView.cellImgViewDelegate = self;
            imgView.selected = selectedImageCell[indexPath.row][i];
            
            [[cell contentView] addSubview:imgView];
        }
        else
        {
            UIImage *image =[UIImage imageNamed:@"hour-img"];
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * _imageCellWidth, 0, _imageCellWidth, tableView.rowHeight)];
            //image.size = CGSizeMake(70, tableView.rowHeight);
            [dayLabel setBackgroundColor:[UIColor colorWithPatternImage:image]];
            if (indexPath.row == 0)
            {
                dayLabel.text = @"Midnight";
            }
            else
            {
                if (indexPath.row < 12)
                {
                    dayLabel.text = [NSString stringWithFormat:@"%d am", indexPath.row];
                }
                else if(indexPath.row == 12)
                {
                    dayLabel.text = @"Noon";
                }
                else
                {
                    dayLabel.text = [NSString stringWithFormat:@"%d pm", indexPath.row - 12];
                }
            }
            dayLabel.textColor = [UIColor whiteColor];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            
            [[cell contentView] addSubview:dayLabel];
        }
    }
    
    return cell;
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end

//
//  SchedulerViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "SchedulerViewController.h"
#import "CellImageView.h"

@interface SchedulerViewController () <CellImageViewDelegate>
{
    BOOL selectedImageCell[25][8];
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSArray *dayArray;
@property (nonatomic) NSInteger imageCellWidth;

@end

@implementation SchedulerViewController

#define NUM_COL 8
#define NUM_ROW 25

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageCellWidth = UIScreen.mainScreen.bounds.size.width / 8;
    self.dayArray = [NSArray arrayWithObjects:@"Hours", @"Mon", @"Tue", @"Wed", @"Thur", @"Fri", @"Sat", @"Sun", nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - CellImageViewDelegate

- (void)tapOnImageAtRow:(NSInteger)row column:(NSInteger)col state:(BOOL)selected
{
    selectedImageCell[row][col] = selected;
    
    if (selected) {
        for (int i = row - 1; i > -1; i--) {
            if (selectedImageCell[i][col] == selected) {
                // True
                for (int j = i; j < row; j++) {
                    selectedImageCell[j][col] = selected;
                }
                break;
            }
        }
    }
    
    for (int i = row + 1; i < NUM_ROW; i++) {
        if (selectedImageCell[i][col] == selected) {
            for (int j = row + 1; j < i; j++) {
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_ROW;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tmpView = [[UIView alloc] init];
    
    for (int i = 0; i < _numberOfColumn; i++) {
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
    
    for (int i = 0; i < _numberOfColumn; i++) {
        if (i > 0) {
            if (selectedImageCell[indexPath.row][i] == NO) {
                self.image =[UIImage imageNamed:@"DotCell"];
            }
            else {
                self.image = [UIImage imageNamed:@"selected-img"];
            }
            
            CellImageView *imgView = [[CellImageView alloc] initWithImage:_image];
            
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
        else {
            UIImage *image =[UIImage imageNamed:@"hour-img"];
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * _imageCellWidth, 0, _imageCellWidth, tableView.rowHeight)];
            [dayLabel setBackgroundColor:[UIColor colorWithPatternImage:image]];
            
            if (indexPath.row == 0) {
                dayLabel.text = @"Midnight";
            }
            else {
                if (indexPath.row < 12) {
                    dayLabel.text = [NSString stringWithFormat:@"%d am", indexPath.row];
                }
                else if(indexPath.row == 12) {
                    dayLabel.text = @"Noon";
                }
                else {
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

@end

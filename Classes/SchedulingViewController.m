//
//  SchedulingViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 1/15/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "SchedulingViewController.h"
#import "SchedulingCell.h"

@interface SchedulingViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    BOOL valueMap[25][8];
}

@property (nonatomic, strong) NSIndexPath *lastAccessed;
@property (nonatomic, strong) NSArray *arrayDays;
@property (nonatomic) NSInteger cellSize;
@property (nonatomic) NSInteger cellSizeMax;

@end

@implementation SchedulingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionViewMap registerClass:[SchedulingCell class] forCellWithReuseIdentifier:@"SchedulingCell"];
    _collectionViewMap.multipleTouchEnabled = YES;
    _collectionViewMap.allowsMultipleSelection = YES;
    
    _collectionViewMap.delegate = self;
    _collectionViewMap.dataSource = self;
    _collectionViewMap.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 320);
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    [gestureRecognizer setMaximumNumberOfTouches:1];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f &&
        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.cellSize = UIScreen.mainScreen.bounds.size.width / 9;
        self.cellSizeMax = UIScreen.mainScreen.bounds.size.width - _cellSize * 2;
    }
    else {
        self.cellSize = UIScreen.mainScreen.bounds.size.width / 8;
        self.cellSizeMax = UIScreen.mainScreen.bounds.size.width - _cellSize;
    }
    
    self.arrayDays = @[
                       LocStr(@"M"),
                       LocStr(@"T"),
                       LocStr(@"W"),
                       LocStr(@"Th"),
                       LocStr(@"F"),
                       LocStr(@"S"),
                       LocStr(@"Su")
                       ];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ( _everydayFlag ) {
        return 2;
    }
    return 8;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 26;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SchedulingCell *cell = (SchedulingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SchedulingCell" forIndexPath:indexPath];
    CGSize sizeScale = CGSizeZero;
    
    if ( _everydayFlag ) {
        sizeScale = CGSizeMake(_cellSizeMax, _cellSize);
    }
    else {
        sizeScale = CGSizeMake(_cellSize, _cellSize);
    }
    
    UIImage *imageBg = [self imageWithStringName:@"DotCell" scaledToSize:sizeScale];
    UIImage *imageSelected = [self imageWithStringName:@"selected-img" scaledToSize:sizeScale];
    
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            UIImage *imageHour = [self imageWithStringName:@"DotCell" scaledToSize:CGSizeMake(_cellSize, _cellSize)];
            cell.backgroundColor = [UIColor colorWithPatternImage:imageHour];;
            
            for (id obj in cell.contentView.subviews) {
                if ([obj isKindOfClass:[UILabel class]]) {
                    [obj removeFromSuperview];
                }
            }
        }
        else {
            UILabel *labelTitle = cell.labelTitle;
            if ( !labelTitle ) {
                labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sizeScale.width, sizeScale.height)];
            }
            
            if ( _everydayFlag ) {
                labelTitle.text = LocStr(@"Everyday");
            }
            else {
                labelTitle.text = _arrayDays[indexPath.item - 1];
            }
            
            labelTitle.textColor = [UIColor whiteColor];
            labelTitle.backgroundColor = [UIColor colorWithPatternImage:imageBg];
            labelTitle.textAlignment = NSTextAlignmentCenter;
            
            [cell.contentView addSubview:labelTitle];
            cell.labelTitle.hidden = NO;
        }
    }
    else if (indexPath.item == 0) {
        UILabel *labelTitle = cell.labelTitle;
        if ( !labelTitle )
        {
            labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _cellSize, _cellSize)];
        }
        
        if (indexPath.section == 1) {
            // Midnight
            labelTitle.text = LocStr(@"MN");
        }
        else {
            if (indexPath.section < 13) {
                // morning
                labelTitle.text = [NSString stringWithFormat:LocStr(@"%ld am"), (long)indexPath.section - 1];
            }
            else if (indexPath.section == 13) {
                // Noon
                labelTitle.text = LocStr(@"Noon");
            }
            else if (indexPath.section < 25) {
                // Afternoon
                labelTitle.text = [NSString stringWithFormat:LocStr(@"%ld pm"), ((long)indexPath.section - 1) % 12];
            }
            else {
                // Midnight
                labelTitle.text = LocStr(@"MN");
            }
        }
        
        labelTitle.textColor = [UIColor whiteColor];
        UIImage *imageHour = [self imageWithStringName:@"DotCell" scaledToSize:CGSizeMake(_cellSize, _cellSize)];
        labelTitle.backgroundColor = [UIColor colorWithPatternImage:imageHour];
        
        [cell.contentView addSubview:labelTitle];
        cell.labelTitle.hidden = NO;
    }
    else {
        
        cell.backgroundColor = [UIColor colorWithPatternImage:imageBg];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:imageSelected] ;
        
        for (id obj in cell.contentView.subviews) {
            if ([obj isKindOfClass:[UILabel class]]) {
                [obj removeFromSuperview];
            }
        }
    }
    
    return cell;
}

- (UIImage *)imageWithStringName:(NSString *)stringName scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
    [[UIImage imageNamed:stringName] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    float pointerX = [gestureRecognizer locationInView:_collectionViewMap].x;
    float pointerY = [gestureRecognizer locationInView:_collectionViewMap].y;
    
    for (UICollectionViewCell *cell in _collectionViewMap.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY) {
            NSIndexPath *touchOver = [_collectionViewMap indexPathForCell:cell];
            
            if (_lastAccessed != touchOver) {
                if (cell.selected) {
                    [self deselectCellForCollectionView:_collectionViewMap atIndexPath:touchOver];
                }
                else {
                    [self selectCellForCollectionView:_collectionViewMap atIndexPath:touchOver];
                }
            }
            
            self.lastAccessed = touchOver;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.lastAccessed = nil;
        _collectionViewMap.scrollEnabled = YES;
    }
}

- (void)selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}

- (void)deselectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"selected-img"]];
    valueMap[indexPath.section - 1][indexPath.item] = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DotCell"]];
    valueMap[indexPath.section - 1][indexPath.item] = NO;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        return CGSizeMake(_cellSize, _cellSize);
    }
    else if (_everydayFlag == YES) {
        return CGSizeMake(_cellSizeMax, _cellSize);
    }
    else {
        return CGSizeMake(_cellSize, _cellSize);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end

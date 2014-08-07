//
//  CellImageView.h
//  BlinkHD_ios
//
//  Created by Developer on 12/21/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellImageViewDelegate <NSObject>

- (void)tapOnImageAtRow:(NSInteger)row column:(NSInteger)col state:(BOOL)selected;

@end

@interface CellImageView : UIImageView

@property (nonatomic, weak) id<CellImageViewDelegate> cellImgViewDelegate;

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) NSInteger colomnIndex;
@property (nonatomic) BOOL selected;

- (void)singleTapGestureCaptured:(id)sender;

@end

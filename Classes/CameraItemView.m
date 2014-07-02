//
//  CameraItemView.m
//  BlinkHD_ios
//
//  Created by Developer on 1/7/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CameraItemView.h"

@implementation CameraItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithConorLeftLocation:(CGPoint)location {
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"CameraItemView" owner:self options:nil];
    id obj = [subviewArray objectAtIndex:0];
    if ([obj isKindOfClass:[CameraItemView class]]) {
        UIView *view = (UIView *)obj;
        view.frame = CGRectMake(location.x, location.y, ITEM_WIDTH, ITEM_HEIGHT);
        return [obj retain];
    }
    return nil;
}

- (void)setCamera:(Camera *)camera {
    self.itemButton.tag = camera.ID;
    [self.itemButton setBackgroundImage:camera.image forState:UIControlStateNormal];
    self.itemLable.text = camera.lable;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)dealloc {
    [_itemButton release];
    [_itemLable release];
    [super dealloc];
}

- (IBAction)handlerItemButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(selectedItem:)]) {
        [self.delegate selectedItem:self.itemButton.tag];
    }
}
@end

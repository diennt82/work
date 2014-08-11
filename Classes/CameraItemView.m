//
//  CameraItemView.m
//  BlinkHD_ios
//
//  Created by Developer on 1/7/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CameraItemView.h"

@interface CameraItemView()
@property (nonatomic, retain) NSString *cameraText;
@end

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
        CGFloat width = ITEM_WIDTH_IPHONE;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            width = ITEM_WIDTH_IPAD;
        }
        view.frame = CGRectMake(location.x, location.y, width, ITEM_HEIGHT);
        return [obj retain];
    }
    return nil;
}

- (void)setCamera:(Camera *)camera {
    self.cameraText = camera.lable;
    
    self.itemButton.tag = camera.ID;
    [self.itemButton setBackgroundImage:camera.image forState:UIControlStateNormal];
    self.itemLable.text = camera.lable;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.itemLable.frame;
    CGFloat width = ITEM_WIDTH_IPHONE;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = ITEM_WIDTH_IPAD;
    }
    rect.size.width = width;
    rect.size.height = ceilf([self calculateHeightForString:self.cameraText withWidthFrame:self.itemLable.frame.size.width andFont:self.itemLable.font]);
    self.itemLable.frame = rect;
    
    rect = self.itemButton.frame;
    rect.origin.x = (self.frame.size.width - rect.size.width) / 2;
    self.itemButton.frame = rect;
}

- (void)dealloc {
    [_itemButton release];
    [_itemLable release];
    [_cameraText release];
    [super dealloc];
}

- (IBAction)handlerItemButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(selectedItem:)]) {
        [self.delegate selectedItem:self.itemButton.tag];
    }
}

- (CGFloat)calculateHeightForString:(NSString *)desc withWidthFrame:(CGFloat)width andFont:(UIFont *)font {
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    CGSize theSize = [desc sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return theSize.height;
}
@end

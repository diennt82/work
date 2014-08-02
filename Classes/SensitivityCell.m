//
//  SensitivityCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#define NUMBER_CIRCLE 5
#define ALIGNMENT_LR 40

#import "SensitivityCell.h"

@interface SensitivityCell()

@property (nonatomic, retain) IBOutlet UIImageView *imageViewCircleWhite;
@property (nonatomic, retain) IBOutlet UIButton *btnSwitch;
@property (nonatomic, retain) NSArray *imageViewCircleArray;

@end

@implementation SensitivityCell

- (void)drawRect:(CGRect)rect
{
    [_btnSwitch setImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [_btnSwitch setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [_btnSwitch setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    _btnSwitch.selected = _switchValue;
    
    UIImageView *imageViewCone = (UIImageView *)[self viewWithTag:508];
    if (_rowIndex == 0) {
        imageViewCone.hidden = NO;
    }
    else {
        imageViewCone.hidden = YES;
    }
    
    self.imageViewCircleArray = @[[self viewWithTag:500], [self viewWithTag:501], [self viewWithTag:502]];
    
    UIImageView *imageViewLine = (UIImageView *)[self viewWithTag:509];
    if (_switchValue) {
        imageViewLine.image = [UIImage imageNamed:@"settings_line"];
    }
    else{
        imageViewLine.image = [UIImage imageNamed:@"settings_line_white"];
    }
    
    UIImageView *imageView3 = (UIImageView *)[self viewWithTag:503];
    imageView3.center = CGPointMake(imageView3.center.x, imageViewLine.center.y);
    
    UIImageView *imageView4 = (UIImageView *)[self viewWithTag:504];
    imageView4.center = CGPointMake(imageView4.center.x, imageViewLine.center.y);
    
    imageView3.hidden = YES;
    imageView4.hidden = YES;
    
    for (UIImageView *imageView in _imageViewCircleArray) {
        imageView.userInteractionEnabled = _switchValue;
        imageView.center = CGPointMake(imageView.center.x, imageViewLine.center.y);
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [imageView addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        if (!_switchValue) {
            imageView.image = [UIImage imageNamed:@"settings_circle_disable"];
        }
        else {
            imageView.image = [UIImage imageNamed:@"settings_circle"];
        }
    }
    
    self.imageViewCircleWhite.center = ((UIImageView *)_imageViewCircleArray[_settingsValue]).center;
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    NSInteger tempValue = recognizer.view.tag % 500;
    
    if (_settingsValue != tempValue) {
        _imageViewCircleWhite.transform = CGAffineTransformMakeTranslation(recognizer.view.center.x - _imageViewCircleWhite.center.x, 0);
        self.settingsValue = tempValue;
        
        [_sensitivityCellDelegate reportChangedSettingsValue:_settingsValue atRow:_rowIndex];
    }
}

- (IBAction)btnSwitchTouchUpInsideAction:(UIButton *)sender
{
    self.switchValue = !_switchValue;
    sender.selected = _switchValue;
    
    for (UIImageView *imageView in _imageViewCircleArray) {
        imageView.userInteractionEnabled = _switchValue;
        if (!_switchValue) {
            imageView.image = [UIImage imageNamed:@"settings_circle_disable"];
        } else {
            imageView.image = [UIImage imageNamed:@"settings_circle"];
        }
    }
    
    UIImageView *imageViewLine = (UIImageView *)[self viewWithTag:509];
    if (_switchValue) {
        imageViewLine.image = [UIImage imageNamed:@"settings_line"];
    }
    else {
        imageViewLine.image = [UIImage imageNamed:@"settings_line_white"];
    }
    
    [_sensitivityCellDelegate reportSwitchValue:_switchValue andRowIndex:_rowIndex];
}

- (void)dealloc
{
    [_nameLabel release];
    [_valueSwitch release];
    [_imageViewCircleWhite release];
    [_btnSwitch release];
    [_imageViewCircleArray release];
    [super dealloc];
}

@end

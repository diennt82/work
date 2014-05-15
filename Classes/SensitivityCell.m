//
//  SensitivityCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define NUMBER_CIRCLE 5
#define ALIGNMENT_LR 40

#import "SensitivityCell.h"
@interface SensitivityCell()

@property (retain, nonatomic) IBOutlet UIImageView *imageViewCircleWhite;
@property (retain, nonatomic) IBOutlet UIButton *btnSwitch;

@property (retain, nonatomic) NSArray *imageViewCircleArray;

@end

@implementation SensitivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    [self.btnSwitch setImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [self.btnSwitch setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [self.btnSwitch setImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    
    self.btnSwitch.selected = _switchValue;
    
    if(_switchValue)
    {
        self.imgViewEnableDisable.hidden = YES;
    }else{
        self.imgViewEnableDisable.hidden = NO;
    }
    
    UIImageView *imageViewCone = (UIImageView *)[self viewWithTag:508];
    
    if (_rowIndex == 0)
    {
        imageViewCone.hidden = NO;
    }
    else
    {
        imageViewCone.hidden = YES;
    }
    
    self.imageViewCircleArray = [NSArray arrayWithObjects:[self viewWithTag:500], [self viewWithTag:501], [self viewWithTag:502], nil];
    
    UIImageView *imageViewLine = (UIImageView *)[self viewWithTag:509];
    
    UIImageView *imageView3 = (UIImageView *)[self viewWithTag:503];
    imageView3.center = CGPointMake(imageView3.center.x, imageViewLine.center.y);
    
    UIImageView *imageView4 = (UIImageView *)[self viewWithTag:504];
    imageView4.center = CGPointMake(imageView4.center.x, imageViewLine.center.y);
    
    imageView3.hidden = YES;
    imageView4.hidden = YES;
    
    for (UIImageView *imageView in _imageViewCircleArray)
    {
        imageView.userInteractionEnabled = _switchValue;
        imageView.center = CGPointMake(imageView.center.x, imageViewLine.center.y);
        UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)] autorelease];
        [imageView addGestureRecognizer:tapGesture];
    }
    
    self.imageViewCircleWhite.center = ((UIImageView *)_imageViewCircleArray[_settingsValue]).center;
}

- (void)singleTap: (UITapGestureRecognizer *)recognizer
{
    NSInteger tempValue = recognizer.view.tag % 500;
    
    if (_settingsValue != tempValue)
    {
        self.imageViewCircleWhite.transform = CGAffineTransformMakeTranslation(recognizer.view.center.x - _imageViewCircleWhite.center.x, 0);
        self.settingsValue = tempValue;
        
        [_sensitivityCellDelegate reportChangedSettingsValue:_settingsValue atRow:_rowIndex];
    }
}
- (IBAction)btnSwitchTouchUpInsideAction:(UIButton *)sender
{
    self.switchValue = !_switchValue;
    sender.selected = _switchValue;
    if(_switchValue)
    {
        self.imgViewEnableDisable.hidden = YES;
    }else{
        self.imgViewEnableDisable.hidden = NO;
    }

    
    for (UIImageView *imageView in _imageViewCircleArray)
    {
        imageView.userInteractionEnabled = _switchValue;
    }
    
    [_sensitivityCellDelegate reportSwitchValue:_switchValue andRowIndex:_rowIndex];
}

- (void)dealloc {
    [_nameLabel release];
    [_valueSwitch release];
    [_imageViewCircleWhite release];
    [_btnSwitch release];
    [super dealloc];
}
@end

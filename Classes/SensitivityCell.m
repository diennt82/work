//
//  SensitivityCell.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "SensitivityCell.h"
#import "UIView+Custom.h"

#define NUMBER_CIRCLE 5
#define ALIGNMENT_LR 40

#define SENSITIVITY_IMAGE_VIEW_CONE 508
#define SENSITIVITY_IMAGE_VIEW_LINE 509

enum SensitivityImageViewCircleTag
{
    SensitivityImageViewCircleTagLow = 500,
    SensitivityImageViewCircleTagMedium,
    SensitivityImageViewCircleTagHigh,
    SensitivityImageViewCircleTagExtraLow,
    SensitivityImageViewCircleTagExtraHigh,
};
typedef enum SensitivityImageViewCircleTag SensitivityImageViewCircleTag;

enum SensitivityLabelTag
{
    SensitivityLabelTagLow = 750,
    SensitivityLabelTagMedium,
    SensitivityLabelTagHigh,
    SensitivityLabelTagOptionVideo,
    SensitivityLabelTagOptionSnapshot,
};
typedef enum SensitivityLabelTag SensitivityLabelTag;

@interface SensitivityCell()

@property (retain, nonatomic) IBOutlet UIImageView *imageViewCircleWhite;
@property (retain, nonatomic) IBOutlet UIButton *btnSwitch;
@property (retain, nonatomic) IBOutlet UIButton *btnVideoRecording;
@property (retain, nonatomic) IBOutlet UIButton *btnCaptureSnapshot;

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
    [self xibDefaultLocalization];
    
    NSString *on = [NSString stringWithFormat:@" %@", NSLocalizedStringWithDefaultValue(@"on", nil, [NSBundle mainBundle], @"ON", nil)];
    NSString *off = [NSString stringWithFormat:@" %@", NSLocalizedStringWithDefaultValue(@"off", nil, [NSBundle mainBundle], @"OFF", nil)];
    
    [self.btnSwitch setBackgroundImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [self.btnSwitch setBackgroundImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [self.btnSwitch setBackgroundImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    [self.btnSwitch setTitle:off forState:UIControlStateNormal];
    [self.btnSwitch setTitle:on forState:UIControlStateSelected];
    [self.btnSwitch setTitle:on forState:UIControlStateHighlighted];
    
    [self.btnVideoRecording setBackgroundImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [self.btnVideoRecording setBackgroundImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [self.btnVideoRecording setBackgroundImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    [self.btnVideoRecording setTitle:off forState:UIControlStateNormal];
    [self.btnVideoRecording setTitle:on forState:UIControlStateSelected];
    [self.btnVideoRecording setTitle:on forState:UIControlStateHighlighted];
    
    [self.btnCaptureSnapshot setBackgroundImage:[UIImage imageNamed:@"settings_switch_off"] forState:UIControlStateNormal];
    [self.btnCaptureSnapshot setBackgroundImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateSelected];
    [self.btnCaptureSnapshot setBackgroundImage:[UIImage imageNamed:@"settings_switch_on"] forState:UIControlStateHighlighted];
    [self.btnCaptureSnapshot setTitle:off forState:UIControlStateNormal];
    [self.btnCaptureSnapshot setTitle:on forState:UIControlStateSelected];
    [self.btnCaptureSnapshot setTitle:on forState:UIControlStateHighlighted];
    
    self.btnSwitch.selected          = _switchValue;
    self.btnVideoRecording.enabled   = _switchValue;
    self.btnCaptureSnapshot.enabled  = _switchValue;
    self.btnVideoRecording.selected  = _recordingValue;
    self.btnCaptureSnapshot.selected = _captureSnapshotValue;
    
    UIImageView *imageViewCone = (UIImageView *)[self viewWithTag:SENSITIVITY_IMAGE_VIEW_CONE];
    
    if (_rowIndex == 0)
    {
        imageViewCone.hidden = NO;
    }
    else
    {
        imageViewCone.hidden = YES;
    }
    
    self.imageViewCircleArray = [NSArray arrayWithObjects:[self viewWithTag:SensitivityImageViewCircleTagLow], [self viewWithTag:SensitivityImageViewCircleTagMedium], [self viewWithTag:SensitivityImageViewCircleTagHigh], nil];
    
    UIImageView *imageViewLine = (UIImageView *)[self viewWithTag:SENSITIVITY_IMAGE_VIEW_LINE];
    
    if(_switchValue){
        imageViewLine.image = [UIImage imageNamed:@"settings_line.png"];
        
    }else{
        imageViewLine.image = [UIImage imageNamed:@"settings_line_white.png"];
    }
    
    UIImageView *imageView3 = (UIImageView *)[self viewWithTag:SensitivityImageViewCircleTagExtraLow];
    imageView3.center = CGPointMake(imageView3.center.x, imageViewLine.center.y);
    
    UIImageView *imageView4 = (UIImageView *)[self viewWithTag:SensitivityImageViewCircleTagExtraHigh];
    imageView4.center = CGPointMake(imageView4.center.x, imageViewLine.center.y);
    
    imageView3.hidden = YES;
    imageView4.hidden = YES;
    
    for (UIImageView *imageView in _imageViewCircleArray)
    {
        imageView.userInteractionEnabled = _switchValue;
        imageView.center = CGPointMake(imageView.center.x, imageViewLine.center.y);
        UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)] autorelease];
        [imageView addGestureRecognizer:tapGesture];
        
        if(!_switchValue)
        {
            imageView.image = [UIImage imageNamed:@"settings_circle_disable.png"];
        }else{
            imageView.image = [UIImage imageNamed:@"settings_circle.png"];
        }

    }
    
    self.imageViewCircleWhite.center = ((UIImageView *)_imageViewCircleArray[_settingsValue]).center;
}

- (void)xibDefaultLocalization
{
    [[self viewWithTag:SensitivityLabelTagLow] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_label_low", nil, [NSBundle mainBundle], @"Low", nil)];
    [[self viewWithTag:SensitivityLabelTagMedium] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_label_medium", nil, [NSBundle mainBundle], @"Medium", nil)];
    [[self viewWithTag:SensitivityLabelTagHigh] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_label_high", nil, [NSBundle mainBundle], @"High", nil)];
    
    [[self viewWithTag:SensitivityLabelTagOptionVideo] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_label_video_recording", nil, [NSBundle mainBundle], @"Motion Video Recording", nil)];
    
    [[self viewWithTag:SensitivityLabelTagOptionSnapshot] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_label_capture_snapshot", nil, [NSBundle mainBundle], @"Motion Capture Snapshot", nil)];
}

- (void)singleTap: (UITapGestureRecognizer *)recognizer
{
    NSInteger tempValue = recognizer.view.tag % SensitivityImageViewCircleTagLow;
    
    if (_settingsValue != tempValue)
    {
        self.imageViewCircleWhite.transform = CGAffineTransformMakeTranslation(recognizer.view.center.x - _imageViewCircleWhite.center.x, 0);
        self.settingsValue = tempValue;
        
        if ([_sensitivityCellDelegate respondsToSelector:@selector(reportChangedSettingsValue:atRow:)])
        {
            [_sensitivityCellDelegate reportChangedSettingsValue:_settingsValue atRow:_rowIndex];
        }
    }
}

- (IBAction)btnSwitchTouchUpInsideAction:(UIButton *)sender
{
    self.switchValue = !_switchValue;
    sender.selected = _switchValue;
    self.btnVideoRecording.enabled   = _switchValue;
    self.btnCaptureSnapshot.enabled  = _switchValue;
    
    for (UIImageView *imageView in _imageViewCircleArray)
    {
        imageView.userInteractionEnabled = _switchValue;
        if(!_switchValue)
        {
            imageView.image = [UIImage imageNamed:@"settings_circle_disable.png"];
        }else{
            imageView.image = [UIImage imageNamed:@"settings_circle.png"];
        }
    }
    UIImageView *imageViewLine = (UIImageView *)[self viewWithTag:SENSITIVITY_IMAGE_VIEW_LINE];
    if(_switchValue){
        imageViewLine.image = [UIImage imageNamed:@"settings_line.png"];
    }else{
        imageViewLine.image = [UIImage imageNamed:@"settings_line_white.png"];
    }
    
    if ([_sensitivityCellDelegate respondsToSelector:@selector(reportSwitchValue:andRowIndex:)])
    {
        [_sensitivityCellDelegate reportSwitchValue:_switchValue andRowIndex:_rowIndex];
    }
}

- (IBAction)btnRecordingTouchUpInsideAction:(UIButton *)sender
{
    self.recordingValue = !_recordingValue;
    sender.selected = _recordingValue;
    [self reportAdditionalOption];
}

- (IBAction)btnCaptureSnapshotTouchUpInsideAction:(UIButton *)sender
{
    self.captureSnapshotValue = !_captureSnapshotValue;
    sender.selected = _captureSnapshotValue;
    
    [self reportAdditionalOption];
}

- (void)reportAdditionalOption
{
    if ([_sensitivityCellDelegate respondsToSelector:@selector(reportChangedAdditionalOptionsValue:atRow:)
         ]) {
        [_sensitivityCellDelegate reportChangedAdditionalOptionsValue:@[[NSNumber numberWithBool:_recordingValue], [NSNumber numberWithBool:_captureSnapshotValue]] atRow:_rowIndex];
    }
}

- (void)dealloc {
    [_nameLabel release];
    [_valueSwitch release];
    [_imageViewCircleWhite release];
    [_btnSwitch release];
    [_btnVideoRecording release];
    [_btnCaptureSnapshot release];
    [super dealloc];
}

@end

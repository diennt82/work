//
//  CameraDetailCell.m
//  BlinkHD_ios
//
//  Created by openxcell on 5/19/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CameraDetailCell.h"

@implementation CameraDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"CameraDetailCell" owner:self options:nil];
        self = [[nibArray objectAtIndex:0] retain];
        self.backgroundColor = COLOR_RGB(43.0, 50.0, 56.0);
        
        [self.btnChangeName setTitle:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_button_cameraname", nil, [NSBundle mainBundle], @"Camera Name", nil) forState:UIControlStateNormal];
        [self.btnChangeImage setTitle:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_button_changeimage", nil, [NSBundle mainBundle], @"Change Image", nil) forState:UIControlStateNormal];
        [self.btnFirmwareVersion setTitle:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_button_firmwareversion", nil, [NSBundle mainBundle], @"Firmware Version", nil) forState:UIControlStateNormal];
        [self.btnModelID setTitle:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_button_model_id", nil, [NSBundle mainBundle], @"Model ID", nil) forState:UIControlStateNormal];
        [self.btnRemoveCamera setTitle:NSLocalizedStringWithDefaultValue(@"xib_camerasettings_cell_button_remove_camera", nil, [NSBundle mainBundle], @"Remove Camera", nil) forState:UIControlStateNormal];
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

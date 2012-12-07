//
//  EditCameraCell.m
//  MBP_ios
//
//  Created by NxComm on 12/7/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "EditCameraCell.h"

@implementation EditCameraCell

@synthesize  cameraIndex, vc;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(IBAction)alertSettings:(id)sender
{
    UIButton * dummy = [[UIButton alloc]init];
    dummy.tag = cameraIndex;
    
   //  NSLog(@"alertSettings cell: %d ", cameraIndex);
    [vc alertSetting:dummy];
}
-(IBAction)removeCamera:(id)sender
{
    
    UIButton * dummy = [[UIButton alloc]init];
    dummy.tag = cameraIndex;
    
    
   //  NSLog(@"removeCamera cell: %d ", cameraIndex);
    [vc removeCamera:dummy];

    
}
-(IBAction)renameCamera:(id)sender
{
    
    UIButton * dummy = [[UIButton alloc]init];
    dummy.tag = cameraIndex;
    
    // NSLog(@"renameCamera cell: %d ", cameraIndex);
    
    [vc renameCamera:dummy];

    
}



@end

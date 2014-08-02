//
//  ChangeImageViewController.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 14/3/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeImageViewController : UIViewController<UIImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *delayedPhotoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *dismissChangeImageButton;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSTimer *cameraTimer;
@property (nonatomic, strong) NSMutableArray *capturedImages;

- (IBAction)dissmissChangeImageVC:(id)sender;

@end

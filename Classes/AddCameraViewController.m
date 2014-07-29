//
//  AddCameraViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 3/6/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "CameraItemView.h"
#define MAX_CAM_ALLOWED 4
//#define CAMERA_TAG_66 566
//#define CAMERA_TAG_83 583 //83/ 836

#import "AddCameraViewController.h"
#import "define.h"
#import "PublicDefine.h"

#define VERTICAL_DISTANCE           15
#define HORIGENTAL_DISTANCE         10

@interface AddCameraViewController () <CameraItemViewDelegate>
@property (nonatomic, assign) IBOutlet UILabel  *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel  *desLabel;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (nonatomic, assign) IBOutlet UIScrollView  *scrollView;
@end

@implementation AddCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rect = self.btnCancel.frame;
    rect.origin.y = [UIScreen mainScreen].bounds.size.height - rect.size.height - 15;
    self.btnCancel.frame = rect;
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"cancel_btn"] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"cancel_btn_pressed"] forState:UIControlEventTouchDown];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    Camera *cam = [[Camera alloc] initWith:FORCUS_66_TAG andLable:@"Focus 66" andImage:[UIImage imageNamed:@"focus661-black"]];
    [array addObject:cam];
    [cam release];
    
    cam = [[Camera alloc] initWith:MBP_83_TAG andLable:@"MBP 83/836" andImage:[UIImage imageNamed:@"camera_2"]];
    [array addObject:cam];
    [cam release];
    
    cam = [[Camera alloc] initWith:SCOUT_73_TAG andLable:@"Scout 73" andImage:[UIImage imageNamed:@"camera_scout85"]];
    [array addObject:cam];
    [cam release];
    
    cam = [[Camera alloc] initWith:MBP_85_TAG andLable:@"MBP 85/854" andImage:[UIImage imageNamed:@"mbp85"]];
    [array addObject:cam];
    [cam release];
    
    [self loadCameras:array];
    [array release];
    
    rect = self.titleLabel.frame;
    rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
    self.titleLabel.frame = rect;
    
    rect = self.desLabel.frame;
    rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
    self.desLabel.frame = rect;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate sendActionCommand:TRUE];
        self.delegate = nil;
    }];
}

- (IBAction)btnCancelTouchUpInsideAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate sendActionCommand:FALSE];
        self.delegate = nil;
    }];
}

#pragma mark - Methods

- (void)showDialog
{
    NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
    NSString * msg = NSLocalizedStringWithDefaultValue(@"remove_one_cam",nil, [NSBundle mainBundle],
                                                       @"Please remove one camera from the current  list before addding the new one", nil);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:msg
                          delegate:nil
                          cancelButtonTitle:ok
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnCancel release];
    [super dealloc];
}

#pragma mark - CameraItemViewDelegate
- (void)selectedItem:(CAMERA_TAG)cameraTad {
    NSInteger cameraType = WIFI_SETUP;
    switch (cameraTad) {
        case MBP_83_TAG:
             cameraType = BLUETOOTH_SETUP;
            break;
        case FORCUS_66_TAG:
            cameraType = WIFI_SETUP;
            break;
        case SCOUT_73_TAG:
            cameraType = SETUP_CAMERA_FOCUS73;
            break;
        case MBP_85_TAG:
            cameraType = BLUETOOTH_SETUP;
            break;
        default:
            break;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:cameraType forKey:SET_UP_CAMERA];
    [userDefaults setObject:@(cameraTad) forKey:SET_UP_CAMERA_TAG];
    [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [_delegate sendActionCommand:TRUE];
    }];
}

- (void)loadCameras:(NSArray *)cameras {
    NSInteger numberOfRow = 1;
    CGFloat scaleDistance = 1;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        numberOfRow = 3;
        scaleDistance = 4;
    }
    
    NSInteger numberOfColumn = (self.scrollView.frame.size.width - VERTICAL_DISTANCE * scaleDistance) / (ITEM_WIDTH + VERTICAL_DISTANCE * scaleDistance);
    NSInteger realColumn = cameras.count / numberOfRow;
    CGFloat paddingLeft = 30;
    if (realColumn <= numberOfColumn) {
        realColumn = numberOfColumn;
        paddingLeft = (self.scrollView.frame.size.width - (realColumn * ITEM_WIDTH + (realColumn - 1) * VERTICAL_DISTANCE * scaleDistance)) / 2;
    }
    CGFloat paddingTop = 10;//(self.frame.size.height - numberOfRow * ITEM_HEIGHT) / 2;
    
    CGFloat y = paddingTop;
    for (int i = 0; i < numberOfRow; i++) {
        CGFloat x = paddingLeft;
        for (int j = 0; j < realColumn; j++) {
            int index = (i * realColumn + j);
            if (index >= cameras.count) break;
            Camera *cam = [cameras objectAtIndex:index];
            CameraItemView *itemView = [[CameraItemView alloc] initWithConorLeftLocation:CGPointMake(x, y)];
            [itemView setCamera:cam];
            itemView.delegate = self;
            [self.scrollView addSubview:itemView];
            [itemView release];
            
            if (i == 0 && j == realColumn - 1) {
                CGSize size = CGSizeMake(x + ITEM_WIDTH + paddingLeft, self.scrollView.frame.size.height);
                self.scrollView.contentSize = size;
            }
            x += ITEM_WIDTH + VERTICAL_DISTANCE * scaleDistance;
        }
        y += ITEM_HEIGHT + HORIGENTAL_DISTANCE * scaleDistance;
    }
    
}
@end

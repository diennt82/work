//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define D1 @"480p"
#define HD1 @"720p-10"
#define HD15 @"720p-15"

#import "H264PlayerViewController.h"



#import "HttpCommunication.h"
#import "PlaylistInfo.h"
#import "PlaylistViewController.h"
#import "PlaylistCell.h"
#import "MTStackViewController.h"
#import "HttpCommunication.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import <H264MediaPlayer/H264MediaPlayer.h>


@interface H264PlayerViewController ()
<UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    MediaPlayer* mp;
}

@property (retain, nonatomic) IBOutlet UITableView *tableViewPlaylist;
@property (retain, nonatomic) IBOutlet UIView *viewCtrlButtons;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerHQOptions;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBntItemReveal;

@property (nonatomic, retain) HttpCommunication* httpComm;
@property (nonatomic, retain) NSMutableArray *playlistArray;
@property (nonatomic) BOOL mpFlag;
@property (nonatomic, retain) NSArray *eventArr;
@property (nonatomic, retain) HttpCommunication *htppComm;

@end

@implementation H264PlayerViewController

#pragma mark - View
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
    
    self.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", self.selectedChannel.profile.ip_address];
    
    NSLog(@"stream_url = %@", self.stream_url);
    
//    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
//                                                       @"Back", nil);
//    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:[self stackViewController]
//                                                                  action:@selector(toggleLeftViewController)];
    
    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(preToggleLeftViewController)];

    self.navigationItem.leftBarButtonItem = revealIcon;
//	self.navigationItem.backBarButtonItem =
//    [[[UIBarButtonItem alloc] initWithTitle:msg
//                                      style:UIBarButtonItemStyleBordered
//                                     target:nil
//                                     action:nil] autorelease];
    self.tableViewPlaylist.delegate = self;
    self.tableViewPlaylist.dataSource = self;
    self.tableViewPlaylist.rowHeight = 68;
    
    self.pickerHQOptions.delegate = self;
    self.pickerHQOptions.dataSource = self;
    
    //self.barBntItemReveal.target = [self stackViewController];
    
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self checkOrientation];
    
//    if (self.mpFlag) {
//        self.progressView.hidden = NO;
//        //[self.view bringSubviewToFront:self.progressView];
//        [self setupCamera];
//        //[self performSelectorInBackground:@selector(loadEarlierList) withObject:nil];
//        [self loadEarlierList];
//        self.mpFlag = FALSE;
//    }
}

#pragma mark - Action

- (IBAction)segCtrlAction:(id)sender {
    
    if (self.segCtrl.selectedSegmentIndex == 0) {
        
        self.tableViewPlaylist.hidden = YES;
        
        if (self.mpFlag) {
            self.progressView.hidden = NO;
            [self.view bringSubviewToFront:self.progressView];
            [self setupCamera];
            self.mpFlag = FALSE;
        }
        else
        {
            [self.view bringSubviewToFront:self.imageViewVideo];
        }
    }
    else if (self.segCtrl.selectedSegmentIndex == 1)
    {
        if (self.playlistArray.count == 0) {
            self.progressView.hidden = NO;
        }
        
        self.tableViewPlaylist.hidden = NO;
        [self.view bringSubviewToFront:self.tableViewPlaylist];
    }
    
    NSLog(@"self.segCtrl.selectedSegmentIndex = %d", self.segCtrl.selectedSegmentIndex);
}
- (IBAction)hqPressAction:(id)sender {
    self.pickerHQOptions.hidden = NO;
    [self.view bringSubviewToFront:self.pickerHQOptions];
}
- (IBAction)iFrameOnlyPressAction:(id)sender {
}
- (IBAction)recordingPressAction:(id)sender {
}

- (IBAction)barBntItemRevealAction:(id)sender {
//    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:[self stackViewController]
//                                                                 action:@selector(toggleLeftViewController)];
    //[self.stackViewController toggleLeftViewController];
}

- (void)preToggleLeftViewController
{
    [self.stackViewController toggleLeftViewController];
}
#pragma mark - Method

- (void)becomeActive
{
    //CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    //self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
//    self.backBarBtnItem.target = self;
//    self.backBarBtnItem.action = @selector(goBackToCameraList);
//SLIDE MENU
    self.backBarBtnItem.target = self.stackViewController;
    self.backBarBtnItem.action = @selector(toggleLeftViewController);
    
    self.progressView.hidden = NO;
    //[self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
//    [self performSelector:@selector(startStream)
//               withObject:nil
//               afterDelay:0.1];
    NSLog(@"self.segCtrl.selectedSegmentIndex = %d", self.segCtrl.selectedSegmentIndex);
    
    [self setupCamera];
    
    [self performSelectorInBackground:@selector(loadEarlierList) withObject:nil];
    
    //[self loadEarlierList];

    if (self.segCtrl.selectedSegmentIndex == 0) {
        self.tableViewPlaylist.hidden= YES;
        if (mp) {
            if (mp->isPlaying()) {
                [self.view bringSubviewToFront:self.imageViewVideo];
            }
        }
    
    }
//    else if (self.segCtrl.selectedSegmentIndex == 1)
//    {
//        self.tableViewPlaylist.hidden = NO;
//        [self.view bringSubviewToFront:self.tableViewPlaylist];
//    }
}

- (void)setupCamera
{
    if (self.httpComm != nil)
    {
        [self.httpComm release];
        self.httpComm = nil;
    }
    
    self.httpComm = [[HttpCommunication alloc]init];
    self.httpComm.device_ip = self.selectedChannel.profile.ip_address;
    self.httpComm.device_port = self.selectedChannel.profile.port;
    
    //Support remote UPNP video as well
    if (self.selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"created a local streamer");
        self.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", self.selectedChannel.profile.ip_address];
        
        //self.progressView.hidden = YES;
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
    }
    else if (self.selectedChannel.profile.minuteSinceLastComm <= 5)
    {
        NSLog(@"created a remote streamer");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:@selector(createSesseionSuccessWithResponse:)
                                                                             FailSelector:@selector(createSessionFailedWithResponse:)
                                                                                ServerErr:@selector(createSessionFailedUnreachableSerever)];
        [jsonComm createSessionWithRegistrationId:mac
                                    andClientType:@"IOS"
                                        andApiKey:apiKey];

    }
}

-(void) startStream
{
    status_t status;

    mp = new MediaPlayer(false);
    
    //`NSLog(@"Play with TCP Option >>>>> ") ;
    //mp->setPlayOption(MEDIA_STREAM_RTSP_WITH_TCP);
    
    NSString * url ;//=@"http://192.168.3.116:6667/blinkhd";
    
    url = _stream_url;
    
    
    status = mp->setDataSource([url UTF8String]);
    
    
    
    if (status != NO_ERROR) // NOT OK
    {
        
        
        return;
    }
    
    mp->setVideoSurface(self.imageViewVideo);
    
    NSLog(@"Prepare the player");
    
    status=  mp->prepare();
    
    printf("prepare return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("prepare() error: %d\n", status);
        exit(1);
    }
    
    self.progressView.hidden = YES;
    // Play anyhow
    
    status=  mp->start();
    
    printf("start() return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("start() error: %d\n", status);
        return;
    }
}

- (void)goBackToCameraList
{
    
    [self stopStream];
    
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)stopStream
{
    @synchronized(self)
    {
        if (mp != NULL)
        {
            if (mp->isPlaying())
            {
                mp->suspend();
                mp->stop();
            }
            free(mp);
        }
        mp = NULL;
    }
}

- (void)loadEarlierList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
//    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
//                                                                             Selector:@selector(getPlaylistSuccessWithResponse:)
//                                                                         FailSelector:@selector(getPlaylistFailedWithResponse:)
//                                                                            ServerErr:@selector(getPlaylistUnreachableSetver)];
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
//    [jsonComm getAllRecordedFilesWithRegistrationId:mac
//                                           andEvent:@"04"
//                                          andApiKey:apiKey];
    NSDictionary *responseDict = [jsonComm getAllRecordedFilesBlockedWithRegistrationId:mac
                                                  andEvent:@"04"
                                                 andApiKey:apiKey];
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"] intValue] == 200) {
            self.eventArr = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            //[self.tableViewPlaylist reloadData];
            
            self.playlistArray = [NSMutableArray array];
            
            for (NSDictionary *playlist in self.eventArr) {
                NSDictionary *clipInfo = [[playlist objectForKey:@"playlist"] objectAtIndex:0];
                
                PlaylistInfo *playlistInfo = [[[PlaylistInfo alloc] init] autorelease];
                playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                
                [self.playlistArray addObject:playlistInfo];
                //[self.tableViewPlaylist reloadData];
            }
            
            //[self.tableViewPlaylist performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [self.tableViewPlaylist reloadData];
            NSLog(@"reloadData %d", self.playlistArray.count);
            
            //[self performSelectorInBackground:@selector(downloadImage) withObject:nil];
        }
    }
    
    self.progressView.hidden = YES;
}

//- (void)downloadImage
//{
//    
//}

#pragma mark - JSON Callback

- (void)createSesseionSuccessWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"createSesseionSuccessWithResponse %@", responseDict);
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"] intValue] == 200) {
            self.stream_url = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
            
            NSString *tempString = [[self.stream_url componentsSeparatedByString:@"/"] lastObject];
            
            if ([tempString isEqualToString:@"blinkhd"] ) {
                return;
            }
            [self performSelector:@selector(startStream)
                       withObject:nil
                       afterDelay:0.1];
        }
    }
}

- (void)createSessionFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"createSessionFailedWith code %d", [[responseDict objectForKey:@"status"] intValue]);
}

- (void)createSessionFailedUnreachableSerever
{
    NSLog(@"createSessionFailedUnreachableSerever");
}

#pragma mark - Rotation screen
- (BOOL)shouldAutorotate
{
    NSLog(@"Should Auto Rotate");
	return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame]; // Get status bar frame dimensions
    NSLog(@"1 Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x,
          rect.origin.y, rect.size.width, rect.size.height);
    //HACK : incase hotspot is turned on
    if (rect.size.height>21 &&  rect.size.height<50)
    {

    }

    else
    {
        
    }
}

-(void) checkOrientation
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land_ipad"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 1024, 576);
            self.imageViewVideo.frame = newRect;
        }
        else
        {
            
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 480, 256);
            self.imageViewVideo.frame = newRect;
            self.viewCtrlButtons.frame.origin = CGPointMake(0, 106);
            //self.progressView.frame = CGRectMake(0, 44, 480, 320);
            
//            imageView.frame = CGRectMake(
//                                         imageView.frame.origin.x,
//                                         imageView.frame.origin.y, newWidth, newHeight);
//            
//            imageView.contentMode = UIViewContentModeBottomLeft; // This determines position of image
//            imageView.clipsToBounds = YES;
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
        }
        else
        {
        }
        
		//Rotate the slider
		//zoombarView.transform = CGAffineTransformRotate(zoombarView.transform, -M_PI*0.5);
		//Initializng the slider value to zero.
		//self.zoombar.value=currentZoomLvl*ZOOM_STEP;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
        }
        else
        {
        }
        
        //if (fwUpgradeInProgess == TRUE)
        {
        }
        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_ipad"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 768, 432);
            self.imageViewVideo.frame = newRect;
        }
        else
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 320, 180);
            self.imageViewVideo.frame = newRect;
            self.viewCtrlButtons.frame.origin = CGPointMake(0, 30);
            //self.progressView.frame = CGRectMake(0, 44, 320, 480);
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
        }
        else
        {
        }

        //if (fwUpgradeInProgess == TRUE)
        {
        }
	}
    
    [self checkIphone5Size:orientation];

//    self.backBarBtnItem.target = self;
//    self.backBarBtnItem.action = @selector(goBackToCameraList);
// SLIDE MENU
    self.backBarBtnItem.target = self.stackViewController;
    self.backBarBtnItem.action = @selector(toggleLeftViewController);
}

- (void) checkIphone5Size: (UIInterfaceOrientation)orientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568)
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"iphone5 SHift right...");
//            CGAffineTransform translate = CGAffineTransformMakeTranslation(44, 0);
//            self.imageViewVideo.transform = translate;
            CGRect newRect = CGRectMake(0, 0, 568, 320);
            self.imageViewVideo.frame = newRect;
            
//            self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, self.progressView.frame.size.width + 88, self.progressView.frame.size.height);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"self.playlistArray.count = %d", self.playlistArray.count);
    //return self.eventArr.count;
    return self.playlistArray.count;
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:1 alpha:1]];
    }
    else
        [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
    
    static NSString *CellIdentifier = @"PlaylistCell";
    PlaylistCell *cell = [self.tableViewPlaylist dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaylistCell" owner:nil options:nil];
    for (id curObj in objects) {
        if([curObj isKindOfClass:[UITableViewCell class]]){
            cell = (PlaylistCell *)curObj;
            break;
        }
    }
    
    // Configure the cell...
    
    PlaylistInfo *playlistInfo = [self.playlistArray objectAtIndex:indexPath.row];
    if (playlistInfo) {
        cell.imgViewSnapshot.image = [UIImage imageNamed:@"no_img_available.jpeg"];
        
        if (!playlistInfo.imgSnapshot) {
            [cell.activityIndicator startAnimating];
            
            CGSize newSize = CGSizeMake(64, 64);
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                playlistInfo.imgSnapshot = [self imageWithUrlString:playlistInfo.urlImage scaledToSize:newSize];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"img = %@", img);
                    cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
                    [cell.activityIndicator stopAnimating];
                    cell.activityIndicator.hidden = YES;
                });
            });
        }
        else
        {
            NSLog(@"playlistInfo.imgSnapshot already");
            cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
        }
        
        if (playlistInfo.titleString && ![playlistInfo.titleString isEqualToString:@""]) {
            cell.labelTitle.text = playlistInfo.titleString;
        }
        else
        {
            cell.labelTitle.text = @"Title";
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (UIImage *)imageWithUrlString:(NSString *)urlString scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
    
	[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    PlaylistInfo *playlistInfo = (PlaylistInfo *)[self.playlistArray objectAtIndex:indexPath.row];
    
    NSLog(@"urlFile = %@", playlistInfo.urlFile);
    
    if(playlistInfo.urlFile && ![playlistInfo.urlFile isEqualToString:@""] && playlistInfo.imgSnapshot)
    {
        PlaylistViewController *playlistViewController = [[PlaylistViewController alloc] init];
        playlistViewController.urlVideo = playlistInfo.urlFile;
        if (mp) {
            [self stopStream];
            self.mpFlag = TRUE;
        }
        
        [self.navigationController pushViewController:playlistViewController animated:NO];
        [playlistViewController release];
    }
    else
    {
        NSLog(@"urlFile nil");
        [[[[UIAlertView alloc] initWithTitle:@"Sorry"
                                     message:@"Url file maybe empty. Or wait for load image"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil]
          autorelease]
         show];
    }
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSString *textRow;
    switch (row) {
        case 0:
            textRow = @"D1";
            break;
        case 1:
            textRow = @"HD 1 Mbps";
            break;
        case 2:
            textRow = @"HD 1.5 Mbps";
            break;
            
        default:
            break;
    }
    return textRow;
} 


#pragma mark -
#pragma mark PickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    // send command here
    pickerView.hidden = YES;
    
    [self performSelectorInBackground:@selector(setVQ_bg:)
                           withObject:[NSNumber numberWithInt:row]];
}

- (void)setVQ_bg:(NSNumber *) row
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	int videoQ =[userDefaults integerForKey:@"int_VideoQuality"];
    
    NSData * responseData  = nil;
    if (  self.selectedChannel.profile.isInLocal)
	{
        NSString *modeVideo = @"";
		if (self.httpComm != nil)
		{
            switch ([row intValue]) {
                case 0:
                    modeVideo = @"480p";
                    break;
                case 1:
                    modeVideo = @"720p-10";
                    break;
                case 2:
                    modeVideo = @"720p-15";
                    break;
                default:
                    break;
            }
            
            responseData = [self.httpComm sendCommandAndBlock_raw:SET_RESOLUTION_VGA];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5)
	{

	}
    
//	if (responseData != nil)
//	{
//		[self performSelectorOnMainThread:@selector(setVQ_fg)
//                               withObject:nil waitUntilDone:NO];
//	}
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageViewVideo release];
    [_topToolbar release];
    [_backBarBtnItem release];
    [_progressView release];
    [_cameraNameBarBtnItem release];
    [_segCtrl release];
    [_tableViewPlaylist release];
    
    [_stream_url release];
    [_selectedChannel release];
    [_playlistArray release];
    [_httpComm release];
    
    [_barBntItemReveal release];
    [_viewCtrlButtons release];
    [_pickerHQOptions release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setImageViewVideo:nil];
    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    [self setCameraNameBarBtnItem:nil];
    [self setSegCtrl:nil];
    [self setTableViewPlaylist:nil];
    
    [self setStream_url:nil];
    [self setSelectedChannel:nil];
    [self setPlaylistArray:nil];
    [self setHttpComm:nil];
    
    [super viewDidUnload];
}
@end

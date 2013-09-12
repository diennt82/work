//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "H264PlayerViewController.h"
#include "mediaplayer.h"
#import "HttpCommunication.h"
#import "PlaylistInfo.h"
#import "PlaylistViewController.h"
#import "PlaylistCell.h"
#import "MTStackViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface H264PlayerViewController () <UITableViewDataSource, UITableViewDelegate>
{
    MediaPlayer* mp;
}

@property (retain, nonatomic) IBOutlet UITableView *tableViewPlaylist;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBntItemReveal;

@property (nonatomic, retain) HttpCommunication* httpComm;
@property (nonatomic, retain) NSMutableArray *playlistArray;
@property (nonatomic) BOOL mpFlag;
@property (nonatomic, retain) NSArray *eventArr;

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
    
    //self.barBntItemReveal.target = [self stackViewController];
    
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
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
    CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    //self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
//    self.backBarBtnItem.target = self;
//    self.backBarBtnItem.action = @selector(goBackToCameraList);
    
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
//        NSDictionary *responseDict = [jsonComm createSessionBlockedWithRegistrationId:mac
//                                                                        andClientType: @"IOS"
//                                                                            andApiKey:apiKey];
        
        //self.stream_url = @"rtmp://";
    }
}

-(void) startStream
{
    status_t status;

    mp = new MediaPlayer();
    
    NSString * url =@"http://192.168.3.116:6667/blinkhd";
    
    url = _stream_url;
    
    
    status = mp->setDataSource([url UTF8String]);
    printf("setDataSource return: %d\n", status);
    
    
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("setDataSource error: %d\n", status);
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
    if (mp) {
        [self stopStream];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)stopStream
{
    printf("STOP\n");
    if (mp->isPlaying())
    {
        mp->suspend();
        mp->stop();
    }
    free(mp);
    mp = NULL;
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
            
            //self.progressView.hidden = YES;
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
	return NO;
}

- (void) checkIphone5Size: (UIInterfaceOrientation)orientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568)
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"iphone5 SHift right...");
            CGAffineTransform translate = CGAffineTransformMakeTranslation(44, 0);
            self.imageViewVideo.transform = translate;
            
            self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, self.progressView.frame.size.width + 88, self.progressView.frame.size.height);
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
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"self.playlistArray.count = %d", self.playlistArray.count);
    //return self.eventArr.count;
    return self.playlistArray.count;
    //return 7;
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
        cell.textLabel.text = @"Title";
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
    //PlaylistInfo *playlistInfo = [[PlaylistInfo alloc] init];
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

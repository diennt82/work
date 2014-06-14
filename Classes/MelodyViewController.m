//
//  MelodyViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 22/11/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#define NUM_MELODY 6

#import "MelodyViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "define.h"
#import "KISSMetricsAPI.h"

#define GAI_CATEGORY    @"Melody view"

@interface MelodyViewController ()
{
    BOOL valueMelodiesMap[6];
    UIFont *semiBoldFont, *regularFont;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *melodyTitle;
@property (nonatomic, retain) IBOutlet UISwitch *musicSwitch;
@property (nonatomic, retain) NSArray *melodies;

@end

@implementation MelodyViewController

#pragma mark - UIViewController methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.melodyIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *mel1 = LocStr(@"melody_I");
    NSString *mel2 = LocStr(@"melody_II");
    NSString *mel3 = LocStr(@"melody_III");
    NSString *mel4 = LocStr(@"melody_IV");
    NSString *mel5 = LocStr(@"melody_V");
                            
    //if (self.selectedChannel.profile.modelID == 6) // SharedCam
    if ([self isSharedCam:self.selectedChannel.profile.registrationID]) {
        // SharedCam
        NSString *mel6 = LocStr(@"melody_VI");
        
        //All Melodies
        self.melodies = [[NSArray alloc] initWithObjects:mel1,mel2,mel3,mel4, mel5, mel6,nil];
    }
    else {
        // Expect CameraHD
        self.melodies = [[NSArray alloc] initWithObjects:mel1,mel2,mel3,mel4, mel5,nil];
    }
    
    [_melodies release];
    
    self.melodyTableView.delegate = self;
    self.melodyTableView.dataSource = self;
    [self loadFont];
    
    self.trackedViewName = GAI_CATEGORY;
}

#pragma mark - Public methods

- (void)updateUIMelody:(NSInteger)playingIndex
{
    if (playingIndex == -1)
        return;
    valueMelodiesMap[playingIndex] = YES;
    [self.melodyTableView reloadData];
}

- (void)setMelodyState_fg:(NSInteger)melodyIndex
{
    self.melodyIndex = melodyIndex - 1;
    
    if (melodyIndex == 0) {
        [self.musicSwitch setOn:FALSE];
    }
    else {
        [self.musicSwitch setOn:TRUE];
        [self.melodyTableView reloadData];
    }
}

#pragma mark - Private methods

- (void)loadFont
{
    if (isiPhone5) {
        semiBoldFont = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:19];
        regularFont = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:19];
    }
    else if (isiPhone4) {
        semiBoldFont = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:17];
        regularFont = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:17];
    }
    else {
        //maybe iPad
        semiBoldFont = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:30];
        regularFont = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:30];
    }
}

- (BOOL)isSharedCam:(NSString *)regID
{
    if (regID.length == 26) {
        if ([[regID substringWithRange:NSMakeRange(2, 4)] isEqualToString:@"0036"]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setMelodyStatus_fg: (NSNumber *)melodyIndex
{
    NSInteger melodyIdx = [melodyIndex integerValue];
    
    NSString *command = @"";
    if (melodyIdx == 0 ) {
        //mute
		command = @"melodystop";
		[self.musicSwitch setOn:FALSE];
	}
	else {
		command = [NSString stringWithFormat:@"melody%d", melodyIdx];
		[self.musicSwitch setOn:TRUE];
        
	}
    
    [self.melodyVcDelegate setMelodyWithIndex:melodyIdx];
    
    if (self.selectedChannel.profile .isInLocal == TRUE) {
        HttpCommunication *httpCommunication = [[HttpCommunication alloc] init];
        httpCommunication.device_ip = self.selectedChannel.profile.ip_address;
        httpCommunication.device_port = self.selectedChannel.profile.port;
        
        [httpCommunication sendCommandAndBlock_raw:command];
        [httpCommunication release];
    }
    else {
        BMS_JSON_Communication *jsonCommunication = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                           Selector:nil
                                                                                       FailSelector:nil
                                                                                          ServerErr:nil];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                     andCommand:[NSString stringWithFormat:@"action=command&command=%@", command]
                                                      andApiKey:apiKey];
        [jsonCommunication release];
    }
    
    [self.melodyTableView reloadData];
}

#pragma mark - Action

- (IBAction)doneTouchAction:(id)sender
{
    [self.view removeFromSuperview];
}


- (IBAction)melodySwitchValueChanged:(id)sender
{
    UISwitch *aSwtich = (UISwitch *)sender;
    if (!aSwtich.isOn) {
        self.melodyIndex = -1;
        [self.melodyTableView reloadData];
        [self setMelodyStatus_fg:[NSNumber numberWithInteger:_melodyIndex + 1]];
    }
}

#pragma mark TableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//return _melodies.count;
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //tableView.separatorColor = [UIColor clearColor];
    [tableView setBackgroundColor:[UIColor clearColor]];
	//return 1;
    return _melodies.count;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isPhoneLandscapeMode) {
        cell.alpha = 0.6; //0.6;
    }
    else {
        cell.alpha = 1.0; //1.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (isPhoneLandscapeMode) {
        static NSString *CellIdentifier = @"MelodyCellId_land";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"CellMelody_land" owner:self options:nil];
            cell = cellMelody_land;
            cellMelody_land = nil;
        }
        cell.backgroundColor = [UIColor cellMelodyColor];
        
        // Configure the cell...
        ((CellMelody *)cell).labelCellMelody.text = (NSString *) [_melodies objectAtIndex:indexPath.section];
        
        
        //update font
        ((CellMelody *)cell).labelCellMelody.textColor = [UIColor blackColor];
        if ( valueMelodiesMap[indexPath.section] ) {
            ((CellMelody *)cell).labelCellMelody.font = semiBoldFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageNamed:@"camera_action_pause.png"];;
        }
        else {
            ((CellMelody *)cell).labelCellMelody.font = regularFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageNamed:@"camera_action_play.png"];
        }
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            static NSString *CellIdentifier = @"MelodyCellId_iPad";
            
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"CellMelody_Portrait_iPad" owner:self options:nil];
                cell = cellMelody_iPad;
                cellMelody_iPad = nil;
            }
        }
        else {
            static NSString *CellIdentifier = @"MelodyCellId";
            
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"CellMelody" owner:self options:nil];
                cell = cellMelody;
                cellMelody = nil;
            }
        }

        cell.backgroundColor = [UIColor clearColor];
        // Configure the cell...
        ((CellMelody *)cell).labelCellMelody.text = (NSString *) [_melodies objectAtIndex:indexPath.section];
        
        
        //update font
        ((CellMelody *)cell).labelCellMelody.textColor = [UIColor blackColor];
        if ( valueMelodiesMap[indexPath.section] ) {
            ((CellMelody *)cell).labelCellMelody.font = semiBoldFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageCameraActionPause];;
        }
        else {
            ((CellMelody *)cell).labelCellMelody.font = regularFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageCameraActionPlay];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isPhoneLandscapeMode) {
        return 33;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 88;
    }
    else {
        return HEIGHT_CELL_TABLE_IPHONE;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"MelodyVC select row: %d", indexPath.row] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Selected melody"
                                                     withLabel:@"Row"
                                                     withValue:[NSNumber numberWithInteger:indexPath.row]];
    
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    valueMelodiesMap[indexPath.section] = !valueMelodiesMap[indexPath.section];
    
    if ( valueMelodiesMap[indexPath.section] ) {
        _melodyIndex = indexPath.section;
        
        for (int i = 0; i < _melodies.count; i++) {
            if (i != indexPath.section) {
                valueMelodiesMap[i] = FALSE;
            }
        }
    }
    else {
        _melodyIndex = -1;
    }
    
	[self performSelector:@selector(setMelodyStatus_fg:)
               withObject:[NSNumber numberWithInt:(_melodyIndex + 1)]
               afterDelay:0.1];
}

#pragma mark - Memory management methods

- (void)dealloc
{
    [_melodyTableView release];
    [_melodyTitle release];
    [_musicSwitch release];
    [_selectedChannel release];
    [_melodies release];
    
    [super dealloc];
}

@end

//
//  MelodyViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 22/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define NUM_MELODY 6

#import "MelodyViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "define.h"

@interface MelodyViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _melodies;
    BOOL valueMelodiesMap[6];
}

@property (retain, nonatomic) IBOutlet UITableView *melodyTableView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *melodyTitle;
@property (retain, nonatomic) IBOutlet UISwitch *musicSwitch;


@property (retain, nonatomic) NSArray* melodies;

@end

@implementation MelodyViewController
@synthesize melodies = _melodies;
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
    
    NSString * mel1 = NSLocalizedStringWithDefaultValue(@"melody_I",  nil, [NSBundle mainBundle],
                                                        @"Melody 1",  nil);
    NSString * mel2 = NSLocalizedStringWithDefaultValue(@"melody_II", nil, [NSBundle mainBundle],
                                                        @"Melody 2",  nil);
    NSString * mel3 = NSLocalizedStringWithDefaultValue(@"melody_III",nil, [NSBundle mainBundle],
                                                        @"Melody 3",  nil);
    NSString * mel4 = NSLocalizedStringWithDefaultValue(@"melody_IV", nil, [NSBundle mainBundle],
                                                        @"Melody 4",  nil);
    NSString * mel5 = NSLocalizedStringWithDefaultValue(@"melody_V",  nil, [NSBundle mainBundle],
                                                        @"Melody 5",  nil);
    //if (self.selectedChannel.profile.modelID == 6) // SharedCam
    if ([self isSharedCam:self.selectedChannel.profile.registrationID]) // SharedCam
    {
        NSString * mel6 = NSLocalizedStringWithDefaultValue(@"melody_VI", nil, [NSBundle mainBundle],
                                                            @"All Melodies", nil);
        //All Melodies
        self.melodies = [[NSArray alloc] initWithObjects:mel1,mel2,mel3,mel4, mel5, mel6,nil];
    }
    else // Expect CameraHD
    {
        self.melodies = [[NSArray alloc] initWithObjects:mel1,mel2,mel3,mel4, mel5,nil];
    }
    
    self.melodyTableView.delegate = self;
    self.melodyTableView.dataSource = self;
}

- (BOOL)isSharedCam: (NSString *)regID
{
    if (regID != nil)
    {
        if (regID.length == 26)
        {
            if ([[regID substringWithRange:NSMakeRange(2, 4)] isEqualToString:@"0036"])
            {
                return TRUE;
            }
        }
    }
    
    return FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_melodyTableView release];
    [_melodyTitle release];
    [_musicSwitch release];
    [_selectedChannel release];
    [super dealloc];
}

- (void)setMelodyState_fg:(NSInteger)melodyIndex
{
    self.melodyIndex = melodyIndex - 1;
    
    if (melodyIndex == 0)
    {
        [self.musicSwitch setOn:FALSE];
    }
    else
    {
        [self.musicSwitch setOn:TRUE];
        [self.melodyTableView reloadData];
    }
}

- (void)setMelodyStatus_fg: (NSNumber *)melodyIndex
{
    NSInteger melodyIdx = [melodyIndex integerValue];
    
    NSString * command = @"";
    if (melodyIdx == 0 ) //mute
	{
		command = @"melodystop";
		[self.musicSwitch setOn:FALSE];
	}
	else
	{
		command = [NSString stringWithFormat:@"melody%d", melodyIdx];
		[self.musicSwitch setOn:TRUE];
        
	}
    
    [self.melodyVcDelegate setMelodyWithIndex:melodyIdx];
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
        HttpCommunication *httpCommunication = [[HttpCommunication alloc] init];
        httpCommunication.device_ip = self.selectedChannel.profile.ip_address;
        httpCommunication.device_port = self.selectedChannel.profile.port;
        
        [httpCommunication sendCommandAndBlock_raw:command];
        
        [httpCommunication release];
    }
    else
    {
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


- (IBAction)melodySwitchValueChanged:(id)sender {
    
    UISwitch *aSwtich = (UISwitch *)sender;
    
    if (!aSwtich.isOn)
    {
        self.melodyIndex = -1;
        [self.melodyTableView reloadData];
        [self setMelodyStatus_fg:[NSNumber numberWithInteger:_melodyIndex + 1]];
    }
}


#pragma mark TableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    cell.alpha = 0.4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = (NSString *) [_melodies objectAtIndex:indexPath.section];
    cell.backgroundColor = [UIColor whiteColor];
    
    //update font
    cell.textLabel.textColor = [UIColor blackColor];
    if (valueMelodiesMap[indexPath.section] == TRUE)
    {
        UIFont *font = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:17];
        cell.textLabel.font = font;
        cell.imageView.image = [UIImage imageNamed:@"camera_action_pause.png"];
    }
    else
    {
        UIFont *font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:17];
        cell.textLabel.font = font;
        cell.imageView.image = [UIImage imageNamed:@"camera_action_play.png"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 60;
    }
    else
    {
        return 44;
    }
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    valueMelodiesMap[indexPath.section] = !valueMelodiesMap[indexPath.section];
    
    if (valueMelodiesMap[indexPath.section] == TRUE)
    {
        _melodyIndex = indexPath.section;
        
        for (int i = 0; i < _melodies.count; i++)
        {
            if (i != indexPath.section)
            {
                valueMelodiesMap[i] = FALSE;
            }
        }
    }
    else
    {
        _melodyIndex = -1;
    }
    
	[self performSelector:@selector(setMelodyStatus_fg:)
               withObject:[NSNumber numberWithInt:(_melodyIndex + 1)]
               afterDelay:0.1];
}

@end

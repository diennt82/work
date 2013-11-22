//
//  MelodyViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 22/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "MelodyViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface MelodyViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *melodyTableView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *melodyTitle;
@property (retain, nonatomic) IBOutlet UISwitch *musicSwitch;


@property (retain, nonatomic) NSArray* melodies;
@end

@implementation MelodyViewController

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
    
    NSString * mel1 = NSLocalizedStringWithDefaultValue(@"melody_I",nil, [NSBundle mainBundle],
                                                        @"Melody 1", nil);
    NSString * mel2 = NSLocalizedStringWithDefaultValue(@"melody_II",nil, [NSBundle mainBundle],
                                                        @"Melody 2", nil);
    NSString * mel3 = NSLocalizedStringWithDefaultValue(@"melody_III",nil, [NSBundle mainBundle],
                                                        @"Melody 3", nil);
    NSString * mel4 = NSLocalizedStringWithDefaultValue(@"melody_IV",nil, [NSBundle mainBundle],
                                                        @"Melody 4", nil);
    NSString * mel5 = NSLocalizedStringWithDefaultValue(@"melody_V",nil, [NSBundle mainBundle],
                                                        @"Melody 5", nil);
    NSString * mel6 = NSLocalizedStringWithDefaultValue(@"melody_VI",nil, [NSBundle mainBundle],
                                                        @"Melody 6", nil);
    
    self.melodies = [[NSArray alloc] initWithObjects:mel1,mel2,mel3,mel4, mel5, mel6,nil];
    
    self.melodyTableView.delegate = self;
    self.melodyTableView.dataSource = self;
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
        
        NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        [jsonCommunication sendCommandBlockedWithRegistrationId:mac
                                                     andCommand:[NSString stringWithFormat:@"action=command&command=%@", command]
                                                      andApiKey:apiKey];
        [jsonCommunication release];
    }
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
	return _melodies.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = (NSString *) [_melodies objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == _melodyIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
	if (_melodyIndex == indexPath.row)
	{
		return;
	}
    
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_melodyIndex inSection:0];
    
	UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
	if (newCell.accessoryType == UITableViewCellAccessoryNone) {
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
		self.melodyIndex = indexPath.row;
	}
    
	UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    
	if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
		oldCell.accessoryType = UITableViewCellAccessoryNone;
        
	}
    
    
	[self performSelector:@selector(setMelodyStatus_fg:)
               withObject:[NSNumber numberWithInt:(_melodyIndex + 1)]
               afterDelay:0.1];
}

@end

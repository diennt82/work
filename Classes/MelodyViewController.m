//
//  MelodyViewController.m
//  BlinkHD_ios
//
//  Created by Nxcomm Developer on 22/11/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "MelodyViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "define.h"
#import "HttpCom.h"
#import "MBProgressHUD/MBProgressHUD.h"

#define NUM_MELODY 6
#define GAI_CATEGORY    @"Melody view"

@interface MelodyViewController ()
{
    BOOL valueMelodiesMap[6];
    UIFont *semiBoldFont, *regularFont;
}

@property (retain, nonatomic) NSArray* melodies;
@property (retain, nonatomic) BMS_JSON_Communication *jsonCommBlock;

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
    if ([self.selectedChannel.profile isSharedCam]) // SharedCam
    {
        NSString * mel6 = NSLocalizedStringWithDefaultValue(@"melody_VI", nil, [NSBundle mainBundle],
                                                            @"All Melodies", nil);
        //All Melodies
        NSArray *arr = [[NSArray alloc] initWithObjects:mel1, mel2, mel3, mel4, mel5, mel6,nil];
        self.melodies = arr;
        [arr release];
    }
    else // Expect CameraHD
    {
        NSArray *arr = [[NSArray alloc] initWithObjects:mel1, mel2, mel3, mel4, mel5,nil];
        self.melodies = arr;
        [arr release];
    }
    
    self.melodyTableView.delegate = self;
    self.melodyTableView.dataSource = self;
    [self loadFont];
    
    self.trackedViewName = GAI_CATEGORY;
}

- (void)loadFont
{
    if (isiPhone5)
    {
        semiBoldFont = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:19];
        regularFont = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:19];
    }
    else if (isiPhone4)
    {
        semiBoldFont = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:17];
        regularFont = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:17];
    }
    else
    {
        //maybe iPad
        semiBoldFont = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:30];
        regularFont = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:30];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_melodyTableView release];
    //[_selectedChannel release];
    [_jsonCommBlock release];
    
    [super dealloc];
}

- (void)getMelodyValue_bg
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
        responseString = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"value_melody"];
    }
    else
    {
        if (_jsonCommBlock == nil)
        {
            BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
            self.jsonCommBlock = comm;
            [comm release];
        }
        
        NSDictionary *responseDict = [_jsonCommBlock sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                 andCommand:@"action=command&command=value_melody"
                                                                                  andApiKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"PortalApiKey"]];
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            
            if (status == 200)
            {
                responseString = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
    }
    
    NSLog(@"%s _melodyIndex:%d, responsed: %@", __func__, _melodyIndex, responseString);
    
    if (![responseString isEqualToString:@""])
    {
        NSRange tmpRange = [responseString rangeOfString:@": "];
        
        if (tmpRange.location != NSNotFound)
        {
            NSArray *tokens = [responseString componentsSeparatedByString:@": "];
            
            if (tokens.count > 1 )
            {
                NSInteger melodyIndex = [[tokens lastObject] integerValue] - 1;
                
                for (int i = 0; i < _melodies.count; i++)
                {
                    valueMelodiesMap[i] = FALSE;
                }
                
                if (melodyIndex != -1)
                {
                    valueMelodiesMap[melodyIndex]  = YES;
                }
                
                if (self.isViewLoaded && self.view.window) {
                    [_melodyTableView performSelectorOnMainThread:@selector(reloadData)
                                                       withObject:nil
                                                    waitUntilDone:NO];
                }
                else
                {
                    NSLog(@"%s View is invisible. Ignoring.", __FUNCTION__);
                }
            }
        }
    }
}

- (void)setMelodyStatus_bg: (NSNumber *)melodyIndex
{
    NSInteger melodyIdx = [melodyIndex integerValue];
    
    NSString * command = @"";
    if (melodyIdx == 0 ) //mute
	{
		command = @"melodystop";
	}
	else
	{
		command = [NSString stringWithFormat:@"melody%d", melodyIdx];
	}
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
        [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:command];
    }
    else
    {
        if (!_jsonCommBlock)
        {
            BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
            self.jsonCommBlock = comm;
            [comm release];
        }
        
        [_jsonCommBlock sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                     andCommand:[NSString stringWithFormat:@"action=command&command=%@", command]
                                                      andApiKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"PortalApiKey"]];
    }
    [self progressHDUDisplay:NO];
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
    if (isPhoneLandscapeMode)
    {
        cell.alpha = 0.6; //0.6;
    } else
    {
        cell.alpha = 1.0; //1.0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) NSLog(@"duy reload table, hihi");

    UITableViewCell *cell = nil;
    if (isPhoneLandscapeMode)
    {
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
        if (valueMelodiesMap[indexPath.section] == TRUE)
        {
            ((CellMelody *)cell).labelCellMelody.font = semiBoldFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageNamed:@"camera_action_pause.png"];;
        }
        else
        {
            ((CellMelody *)cell).labelCellMelody.font = regularFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageNamed:@"camera_action_play.png"];
        }
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            static NSString *CellIdentifier = @"MelodyCellId_iPad";
            
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"CellMelody_Portrait_iPad" owner:self options:nil];
                cell = cellMelody_iPad;
                cellMelody_iPad = nil;
            }
        } else
        {
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
        if (valueMelodiesMap[indexPath.section] == TRUE)
        {
            ((CellMelody *)cell).labelCellMelody.font = semiBoldFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageCameraActionPause];;
        }
        else
        {
            ((CellMelody *)cell).labelCellMelody.font = regularFont;
            ((CellMelody *)cell).imageCellMelody.image = [UIImage imageCameraActionPlay];
        }
    }
    
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (isPhoneLandscapeMode)
    {
        return 33;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 88;
    }
    else
    {
        return HEIGHT_CELL_TABLE_IPHONE;
    }
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"MelodyVC select row: %d", indexPath.row] withProperties:nil];
    [self progressHDUDisplay:YES];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Selected melody"
                                                     withLabel:@"Row"
                                                     withValue:[NSNumber numberWithInteger:indexPath.row]];
    
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
        self.playing = YES;
    }
    else
    {
        _melodyIndex = -1;
    }
    
    [_melodyTableView reloadData];
    [self performSelectorInBackground:@selector(setMelodyStatus_bg:) withObject:[NSNumber numberWithInt:(_melodyIndex + 1)]];
}

- (void)progressHDUDisplay:(BOOL)display {
    UIView *sv = [self.view superview];
    if (sv) {
        if (display) {
            MBProgressHUD *showProgress = [MBProgressHUD showHUDAddedTo:sv animated:YES];
            [showProgress setLabelText:@"Processing..."];
        } else {
            [MBProgressHUD hideAllHUDsForView:sv animated:YES];
        }
    }
}
@end

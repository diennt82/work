//
//  ZoneViewController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 21/10/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "ZoneViewController.h"

@interface ZoneViewController ()

@end

@implementation ZoneViewController
@synthesize  zone1, zone2, zone3, zone4,zone5,zone6,zone7,zone8,zone9;
@synthesize  zoneMap;

- (void)dealloc
{
    [zone1 release];
    [zone2 release];
    [zone3 release];
    [zone4 release];
    [zone5 release];
    [zone6 release];
    [zone7 release];
    [zone8 release];
    [zone9 release];
    
    [_zoneArray release];
    [_selectedChannel release];
    [_oldZoneArray release];
    [zoneMap release];
    
    [super dealloc];
}

#define NUM_OF_ZONES 9


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        
        memset(enabledZones, 0, NUM_OF_ZONES*(sizeof (int) ));
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.zoneArray = [[NSMutableArray alloc] initWithCapacity:NUM_OF_ZONES];
//    
//    for (int i = 0; i < NUM_OF_ZONES ; ++i)
//    {
//        [self.zoneArray addObject:@"0"];
//    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //create 9-element array
    self.zoneMap = [[[NSMutableArray alloc] initWithObjects:
                    zone1,zone2,zone3,
                    zone4, zone5,zone6,
                    zone7,zone8,zone9,nil] autorelease];
    
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self loadZones];
}

/* zoneStrings [ "00","11","01"..] */
-(void) parseZoneStrings:(NSArray * )zoneStrings
{
    self.oldZoneArray = [NSMutableArray arrayWithArray:zoneStrings];
    
    
    int row_col, row, col;
    int linear_index;
    
    //rebuild the zone map to int array
    memset(enabledZones, 0, NUM_OF_ZONES* sizeof(int) );
    
    for (NSString *zoneString in zoneStrings)
    {
        row_col = [zoneString integerValue];
        
        row = row_col /10;
        col = row_col %10;
        
        linear_index = (row *3) + col;
        
        if (linear_index < NUM_OF_ZONES)
        {
            enabledZones[linear_index] = 1;
        }
        else
        {
            //out of range - ignore it
        }
    }

    //[self loadZones];
}

-(void) loadZones
{
    UIButton *zoneBtn = nil;
    
    
    for (int i = 0; i < NUM_OF_ZONES; i++)
    {
        
        zoneBtn = (UIButton *) [self.zoneMap objectAtIndex:i];
        
        if (enabledZones[i] == 1)
        {
            [zoneBtn setImage:[UIImage imageNamed:@"motion_detection_on.png"] forState:UIControlStateNormal];
        }
        else
        {
            [zoneBtn setImage:[UIImage imageNamed:@"motion_detection_off_1.png"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Action
- (IBAction)zoneTouchAction:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *zoneBtn = (UIButton *)sender;
        UIButton *btn;
        
        NSLog(@"sizeof(enabledZones): %d", NUM_OF_ZONES);
        
        for (int i = 0; i < NUM_OF_ZONES; i++)
        {
            btn = (UIButton *) [self.zoneMap objectAtIndex:i];
            
            if (zoneBtn == btn)
            {
                //toggle it
                if (enabledZones[i] == 1)
                {
                    [zoneBtn setImage:[UIImage imageNamed:@"motion_detection_off_1.png"] forState:UIControlStateNormal];
                    enabledZones[i] = 0;
                }
                else
                {
                    [zoneBtn setImage:[UIImage imageNamed:@"motion_detection_on.png"] forState:UIControlStateNormal];
                    enabledZones[i] = 1;
                }
            }
        }
        
    }
    
    //NSLog(@"zone array: %@", self.zoneArray);
}

- (IBAction)okTouchedAction:(id)sender
{
    NSString * set_zone =@"";
    
    NSMutableArray * enabled_zone = [[NSMutableArray alloc] init];
    
    int row, col;
    int linear_index;
    
    for (int i = 0; i < sizeof(enabledZones); i++)
    {
        if (enabledZones[i] == 1)
        {
            linear_index = i;
            row = linear_index/3;
            col = linear_index%3;
            
            
            set_zone =[NSString stringWithFormat:@"%d%d", row,col];
            
            [enabled_zone addObject:set_zone];
            
            
        }
        else
        {
            
        }
    }
    
    
    
    NSLog(@"zone string: %@", set_zone);
    
    if ([enabled_zone count] >0 )
    {
        //send command with the element
        // [self.zoneVCDelegate beginProcessing];
        
        self.progress.hidden = NO;
        [self.progress startAnimating];
        
      
    }
    else
    {
        NSLog(@"zEmpty zone string");
        //[self dismissViewControllerAnimated:NO completion:nil];
        //[self.navigationController popViewControllerAnimated:NO];
        
    }
    
     [self performSelectorInBackground:@selector(setZoneDetection_bg:) withObject:enabled_zone];
 
}

- (IBAction)cancelTouchedAction:(id)sender
{
    
    //reload the old zone
    [self parseZoneStrings:self.oldZoneArray];
    
   // [self dismissViewControllerAnimated:NO completion:nil];
    
//    [self.navigationController popViewControllerAnimated:NO];

    [self.view removeFromSuperview];
    //NSLog(@"zone array: %@", self.zoneArray);
}


#pragma mark - Http command

- (void)setZoneDetection_bg: (NSMutableArray *)zoneStrings
{
    NSString *responseString = @"";
    /* format the set String*/
    
    NSString * set_zone =@"";
    
    for (NSString * str in zoneStrings)
    {
        set_zone = [set_zone stringByAppendingString:str];
        set_zone = [set_zone stringByAppendingString:@","];
    }
    
    if ( [set_zone hasSuffix:@","])
    {
    //* remove the last ,
        set_zone = [set_zone substringToIndex:set_zone.length - 1];
    }
    
    if (self.selectedChannel.profile.isInLocal == TRUE)
    {
        HttpCommunication *httpComm = [[[HttpCommunication alloc] init] autorelease];
        httpComm.device_ip = self.selectedChannel.profile.ip_address;
        httpComm.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [httpComm sendCommandAndBlock_raw:[NSString stringWithFormat:@"set_motion_area&grid=3x3&zone=%@", set_zone]];
        
        if (responseData != nil)
        {
            
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"response string: %@", responseString);
            
        }
    }
    else if(self.selectedChannel.profile.minuteSinceLastComm <= 5)
    {
        NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                           Selector:nil
                                                                                       FailSelector:nil
                                                                                          ServerErr:nil] autorelease];
        
        NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:mac
                                                                                  andCommand:[NSString stringWithFormat:@"set_motion_area&grid=3x3&zone=%@", set_zone]
                                                                                   andApiKey:apiKey];
        if (responseDict != nil)
        {
            
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                responseString = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
        
        NSLog(@"getVQ_bg responseDict = %@", responseDict);
    }
    
    if (![responseString isEqualToString:@""])
    {
        NSArray * tokens = [responseString componentsSeparatedByString:@": "];
        
        if (tokens.count > 1 )
        {
            if ([[tokens objectAtIndex:1] isEqualToString:@"0"])
            {
               //We save the new changes.
                self.oldZoneArray=[NSMutableArray arrayWithArray:zoneStrings];
               

            }
        }
    }
    else
    {
        
        NSLog(@"Failed to set zone");
        [self performSelectorOnMainThread:@selector(parseZoneStrings:)
                               withObject:self.oldZoneArray
                            waitUntilDone:NO];
        
        
        
    }
    
    //[self.zoneVCDelegate endProcessing];
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [self.progress stopAnimating];
                       
                       //[self.navigationController popViewControllerAnimated:NO];
                       
                        [self.view removeFromSuperview];
                   });
}

#pragma mark - json Call back

- (void)setZoneSuccessWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"set zone success response: %@", responseDict);
}

- (void)setZoneFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"set zone fail response: %@", responseDict);
}

- (void)setZoneFailedServerUnreachable
{
    NSLog(@"set zone server");
}

#pragma mark - Method

- (NSArray *)zoneSelectedList
{
    return nil;
}

#pragma mark - --

- (BOOL)shouldAutorotate
{
    return NO;
}



- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

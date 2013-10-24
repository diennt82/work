//
//  ZoneViewController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 21/10/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "ZoneViewController.h"

@interface ZoneViewController ()

@end

@implementation ZoneViewController
@synthesize  zone1, zone2, zone3, zone4,zone5,zone6,zone7,zone8,zone9;

- (void)dealloc
{
    [self.zone1 release];
    [self.zone2 release];
    [self.zone3 release];
    [self.zone4 release];
    [self.zone5 release];
    [self.zone6 release];
    [self.zone7 release];
    [self.zone8 release];
    [self.zone9 release];
    
    [self.zoneArray release];
    [self.selectedChannel release];
    [self.oldZoneArray release];
    
    [super dealloc];
}

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
    self.zoneArray = [[NSMutableArray alloc] initWithCapacity:9];
    
    for (int i = 0; i < 9; ++i)
    {
        [self.zoneArray addObject:@"0"];
    }
}

#pragma mark - Action
- (IBAction)zoneTouchAction:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *zoneBtn = (UIButton *)sender;
        
        if (zoneBtn == self.zone1)
        {
            if ([[self.zoneArray objectAtIndex:0] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"00" atIndexedSubscript:0];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:0];
            }
        }
        else if (zoneBtn == self.zone2)
        {
            if ([[self.zoneArray objectAtIndex:1] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"01" atIndexedSubscript:1];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:1];
            }
        }
        else if (zoneBtn == self.zone3)
        {
            if ([[self.zoneArray objectAtIndex:2] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"02" atIndexedSubscript:2];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:2];
            }
        }
        else if (zoneBtn == self.zone4)
        {
            if ([[self.zoneArray objectAtIndex:3] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"10" atIndexedSubscript:3];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:3];
            }
        }
        else if (zoneBtn == self.zone5)
        {
            if ([[self.zoneArray objectAtIndex:4] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"11" atIndexedSubscript:4];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:4];
            }
        }
        else if (zoneBtn == self.zone6)
        {
            if ([[self.zoneArray objectAtIndex:5] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"12" atIndexedSubscript:5];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:5];
            }
        }
        else if (zoneBtn == self.zone7)
        {
            if ([[self.zoneArray objectAtIndex:6] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"20" atIndexedSubscript:6];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:6];
            }
        }
        else if (zoneBtn == self.zone8)
        {
            if ([[self.zoneArray objectAtIndex:7] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"21" atIndexedSubscript:7];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:7];
            }
        }
        else if (zoneBtn == self.zone9)
        {
            if ([[self.zoneArray objectAtIndex:8] isEqualToString:@"0"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"22" atIndexedSubscript:8];
            }
            else
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
                [self.zoneArray setObject:@"0" atIndexedSubscript:8];
            }
        }
    }
    
    //NSLog(@"zone array: %@", self.zoneArray);
}

- (IBAction)okTouchedAction:(id)sender
{
    // send command to camera
    
    //NSMutableArray *selectedZone = [NSMutableArray array];
    NSString *zoneString = @"";
    
    for (NSString *zoneElement in self.zoneArray)
    {
        if(![zoneElement isEqualToString:@"0"])
        {

            zoneString = [zoneString stringByAppendingString:[NSString stringWithFormat:@"%@,", zoneElement]];
        }
    }
    
    NSLog(@"zone string: %@", zoneString);
    
    if (![zoneString isEqualToString:@""])
    {
        //send command with the element
         [self.zoneVCDelegate beginProcessing];
        
        zoneString = [zoneString substringToIndex:zoneString.length - 1];
        
        [self performSelectorInBackground:@selector(setZoneDetection_bg:) withObject:zoneString];
    }
    
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    
    //NSLog(@"zone str: %@", self.zoneArray);
}

- (IBAction)cancelTouchedAction:(id)sender
{
    // cancel
    self.view.hidden = YES;
    
    [self resetButtonImage];
    
    for (NSString *zoneElement in self.oldZoneArray)
    {
        for (id obj in [self.view subviews])
        {
            if ([obj isKindOfClass:[UIButton class]])
            {
                UIButton *zoneBtn = (UIButton *)obj;
                
                NSString *tmp = [NSString stringWithFormat:@"%02d", zoneBtn.tag % 100];
                
                if ([tmp isEqualToString:zoneElement])
                {
                    [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                    break;
                }
            }
        }
    }
    
    for (int i = 0; i < self.zoneArray.count; ++i)
    {
        [self.zoneArray setObject:@"0" atIndexedSubscript:i];
    }
    
    [self.view removeFromSuperview];
    //NSLog(@"zone array: %@", self.zoneArray);
}

#pragma mark - Metho

- (void)resetButtonImage
{
    for (id obj in [self.view subviews])
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton *zoneBtn = (UIButton *)obj;
            
            if (![zoneBtn.titleLabel.text isEqualToString:@"OK"] &&
                ![zoneBtn.titleLabel.text isEqualToString:@"Cancel"])
            {
                [zoneBtn setImage:[UIImage imageNamed:@"untick.jpeg"] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - Http command

- (void)setZoneDetection_bg: (NSString *)zoneString
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile.isInLocal == TRUE)
    {
        HttpCommunication *httpComm = [[HttpCommunication alloc] init];
        httpComm.device_ip = self.selectedChannel.profile.ip_address;
        httpComm.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [httpComm sendCommandAndBlock_raw:[NSString stringWithFormat:@"set_motion_area&grid=3x3&zone=%@", zoneString]];
        
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
                                                                                  andCommand:[NSString stringWithFormat:@"set_motion_area&grid=3x3&zone=%@", zoneString]
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
                [self performSelectorOnMainThread:@selector(setZoneDetection_fg_:)
                                       withObject:zoneString
                                    waitUntilDone:NO];
            }
        }
    }
    else
    {
        [self resetButtonImage];
        
        for (NSString *zoneElement in self.oldZoneArray)
        {
            for (id obj in [self.view subviews])
            {
                if ([obj isKindOfClass:[UIButton class]])
                {
                    UIButton *zoneBtn = (UIButton *)obj;
                    
                    NSString *tmp = [NSString stringWithFormat:@"%02d", zoneBtn.tag % 100];
                    
                    if ([tmp isEqualToString:zoneElement])
                    {
                        [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                        break;
                    }
                }
            }
        }
        
        for (int i = 0; i < self.zoneArray.count; ++i)
        {
            [self.zoneArray setObject:@"0" atIndexedSubscript:i];
        }
        
        [self.zoneVCDelegate endProcessing];
    }
}

- (void)setZoneDetection_fg_: (NSString *)zoneString
{
    NSArray *zoneArr = [NSArray array];
    
    NSRange tmpRange = [zoneString rangeOfString:@","];
    if (tmpRange.location != NSNotFound)
    {
        zoneArr = [NSArray arrayWithArray: [zoneString componentsSeparatedByString:@","]];
    }
    else
    {
        zoneArr = [NSArray arrayWithObject:zoneString];
    }
    
    [self resetButtonImage];
    
    for (NSString *zoneElement in zoneArr)
    {
        for (id obj in [self.view subviews])
        {
            if ([obj isKindOfClass:[UIButton class]])
            {
                UIButton *zoneBtn = (UIButton *)obj;
                
                NSString *tmp = [NSString stringWithFormat:@"%02d", zoneBtn.tag % 100];
                
                if ([tmp isEqualToString:zoneElement])
                {
                    [zoneBtn setImage:[UIImage imageNamed:@"tick.jpeg"] forState:UIControlStateNormal];
                    break;
                }
            }
        }
    }
    
    self.oldZoneArray = [NSArray arrayWithArray:zoneArr];
    
    for (int i = 0; i < self.zoneArray.count; ++i)
    {
        [self.zoneArray setObject:@"0" atIndexedSubscript:i];
    }
    
    [self.zoneVCDelegate endProcessing];
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

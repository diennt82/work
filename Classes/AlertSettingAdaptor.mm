//
//  AlertSettingAdaptor.m
//  MBP_ios
//
//  Created by NxComm on 9/14/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "AlertSettingAdaptor.h"

@implementation AlertSettingAdaptor

@synthesize soundCellView, tempHiCellView,  tempLoCellView;

@synthesize  progressView;

-(id) init
{
    self =  [super init]; 
    
    //Load this to make the link 
    [[NSBundle mainBundle] loadNibNamed:@"AlertSettingView" owner:self options:nil];
    
    
    
    return self; 
}

-(id) initWithCam:(CamProfile *)cp
{
    
    
    self =  [super init]; 
    
    //Load this to make the link 
    [[NSBundle mainBundle] loadNibNamed:@"AlertSettingView" owner:self options:nil];
    camera = cp; 
    
    return self; 
}

#pragma mark -
#pragma mark Table view delegates & datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UISwitch * alertSw; 
    switch (indexPath.row) {
        case 0:
            alertSw = (UISwitch *) [soundCellView viewWithTag:1];
            [alertSw setOn:camera.soundAlertEnabled];
            
            return soundCellView;
            break;
        case 1:
            alertSw = (UISwitch *) [tempHiCellView viewWithTag:1];
            [alertSw setOn:camera.tempHiAlertEnabled];
            
            return tempHiCellView;
            break;
        case 2:
            alertSw = (UISwitch *) [tempLoCellView viewWithTag:1];
            [alertSw setOn:camera.tempLoAlertEnabled];
            
            return tempLoCellView;
            break;
        default:
            break;
    }
    
    
    return nil ; 
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] 
                             animated:NO];
    
   
    
}

#pragma mark -

-(IBAction)soundAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.soundAlertEnabled  ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO; 
        [[progressView superview] bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
                                       selector:@selector(updateSoundAlert:) 
                                       userInfo:alertSw 
                                        repeats:NO];
        
    }
}

-(void) updateSoundAlert:(NSTimer *) exp
{
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
 NSLog(@"update sound alert");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    NSString * devTokenStr =(NSString*) [userDefaults objectForKey:_push_dev_token];
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil 
                                                                  FailSelector:nil 
                                                                     ServerErr:nil];
    if (alertSw.isOn)
    {
        //call get camlist query here 
        NSData* responseData = [bms_alerts BMS_enabledAlertBlockWithUser:user_email 
                                                                 AndPass:user_pass 
                                                                   regId:devTokenStr 
                                                                   ofMac:camera.mac_address
                                                               alertType:ALERT_TYPE_SOUND];
    }
    else 
    {
        //call get camlist query here 
        NSData* responseData = [bms_alerts BMS_disabledAlertBlockWithUser:user_email 
                                                                  AndPass:user_pass 
                                                                    regId:devTokenStr 
                                                                    ofMac:camera.mac_address
                                                                alertType:ALERT_TYPE_SOUND];
        
    }
    
    camera.soundAlertEnabled  =  alertSw.isOn;
    progressView.hidden = YES;         

}

-(IBAction)tempHiAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.tempHiAlertEnabled ==  alertSw.isOn )
    {
        
    }
    else
    {
              
        progressView.hidden = NO; 
        [[progressView superview] bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
                                       selector:@selector(updateTempHiAlert:) 
                                       userInfo:alertSw 
                                        repeats:NO];
        

                   
    }
}

-(void) updateTempHiAlert:(NSTimer *) exp
{
    
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
    
      NSLog(@"update temmp hi alert");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    NSString * devTokenStr =(NSString*) [userDefaults objectForKey:_push_dev_token];
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil 
                                                                  FailSelector:nil 
                                                                     ServerErr:nil];
    
    if (alertSw.isOn)
    {
        //call get camlist query here 
        NSData* responseData = [bms_alerts BMS_enabledAlertBlockWithUser:user_email 
                                                                 AndPass:user_pass 
                                                                   regId:devTokenStr 
                                                                   ofMac:camera.mac_address
                                                               alertType:ALERT_TYPE_TEMP_HI];
    }
    else 
    {
        //call get camlist query here 
        NSData* responseData = [bms_alerts BMS_disabledAlertBlockWithUser:user_email 
                                                                  AndPass:user_pass 
                                                                    regId:devTokenStr 
                                                                    ofMac:camera.mac_address
                                                                alertType:ALERT_TYPE_TEMP_HI];
        
    }
    
    camera.tempHiAlertEnabled  =  alertSw.isOn;
    
    progressView.hidden = YES;  
    
}
-(IBAction)tempLoAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.tempLoAlertEnabled  ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO; 
        [[progressView superview] bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
                                       selector:@selector(updateTempLoAlert:) 
                                       userInfo:alertSw 
                                        repeats:NO];
        
        
        
    }
}
-(void) updateTempLoAlert:(NSTimer *) exp
{
    
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * user_email  = (NSString*)[userDefaults objectForKey:@"PortalUseremail"];
    NSString * devTokenStr =(NSString*) [userDefaults objectForKey:_push_dev_token];
    
    BMS_Communication * bms_alerts = [[BMS_Communication alloc] initWithObject:self
                                                                      Selector:nil 
                                                                  FailSelector:nil 
                                                                     ServerErr:nil];
    NSLog(@"update temmp log alert");
    if (alertSw.isOn)
    {
        //call get camlist query here 
        NSData* responseData = [bms_alerts BMS_enabledAlertBlockWithUser:user_email 
                                                                 AndPass:user_pass 
                                                                   regId:devTokenStr 
                                                                   ofMac:camera.mac_address
                                                               alertType:ALERT_TYPE_TEMP_LO];
    }
    else 
    {
        //call get camlist query here 
        NSData* responseData = [bms_alerts BMS_disabledAlertBlockWithUser:user_email 
                                                                  AndPass:user_pass 
                                                                    regId:devTokenStr 
                                                                    ofMac:camera.mac_address
                                                                alertType:ALERT_TYPE_TEMP_LO];
        
    }
    
    camera.tempLoAlertEnabled  =  alertSw.isOn;    progressView.hidden = YES;  
    
}

@end

//
//  ViewController.m
//  TestPjnath
//
//  Created by Jason Lee on 30/9/13.
//  Copyright (c) 2013 Cvision. All rights reserved.
//

#import "StunClient.h"
#include "nat_detect.h"
#include "stun_sock.h"


@interface StunClient ()

@end

@implementation StunClient




extern int check_nat_type_async( pj_stun_nat_detect_cb *cb, void* user_data , char* stun_server);
extern int cleanup_pj();

@synthesize waiting_for_result, running;

@synthesize natCheckThread;
@synthesize mcallback;

-(id) init
{
    start_stun_client_async(STUN_SERVER);
    
    
    
    return [super init];
}

-(void) shutdown
{
    cleanup_pj();
}
-(void) dealloc
{
    
    
    
    [super dealloc];
    [self.natCheckThread release];
    
}



/* Blocking call return 0 on success
    return != 0 on failure */

-(int) create_stun_forwarder:(CamChannel*) channel;
{
    int ret  =0;
    
    if (ret == 0)
    {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        NSDate *timeOut = [NSDate dateWithTimeIntervalSinceNow:24.0];
        struct global * stun_global_data;
        struct peer * aPeer1, *aPeer2;
        int port1, port2;
        ret = -1;
        char straddr[128];
        while ( [[NSDate date] compare:timeOut] == NSOrderedAscending)
        {
            //do a simple "yield()" ..
            [runLoop runUntilDate:[NSDate date]];
            
            sleep(1);
            
           
            stun_global_data  = get_stun_data();
            
            
            
            aPeer1 = &stun_global_data->peer[0];
            port1 = htons(aPeer1->mapped_addr.ipv4.sin_port);
            
            
            
            aPeer2 = &stun_global_data->peer[1];
            port2 = htons(aPeer2->mapped_addr.ipv4.sin_port);
            
            

            if (port1 != 0 && port2 != 0)
            {
                //Found port
                
                set_destination_for_peer(aPeer1, "127.0.0.1", 12000); //audio
                set_destination_for_peer(aPeer2, "127.0.0.1", 13000); //video
                
                
                channel.local_fwd_audio_port = 12000;
                channel.local_fwd_video_port = 13000;
                channel.local_stun_audio_port = port1;
                channel.local_stun_video_port = port2;
                
                pj_sockaddr_print(&aPeer1->mapped_addr, straddr, sizeof(straddr), 0);
                
                channel.public_ip = [NSString stringWithUTF8String:straddr];
                
                ret =0;
                break;
            }
            
        }
        
        
        
        
        
        
        
        

    }
    
    
    return ret;
    
}



-(void) sendAudioProbesToIp:(NSString *) ip andPort:(int) port
{
    struct global * stun_global_data;
    struct peer * aPeer;
    
    stun_global_data  = get_stun_data();
    aPeer = &stun_global_data->peer[0];
    [self sendProbesFromSock:aPeer->stun_sock
                        ToIp:ip
                     andPort:port];
}
-(void) sendVideoProbesToIp:(NSString *) ip andPort:(int) port
{
    struct global * stun_global_data;
    struct peer * aPeer;
    
    stun_global_data  = get_stun_data();
    aPeer = &stun_global_data->peer[1];
    [self sendProbesFromSock:aPeer->stun_sock
                        ToIp:ip
                     andPort:port];
}


#pragma mark -
#pragma mark Chek SYMMETRIC NAT

-(BOOL) isCheckingForSymmetrictNat
{
    
    return self.waiting_for_result;

}

-(BOOL) test_start_async: (id<StunClientDelegate>) callback
{
  
    self.mcallback = callback;
    self.waiting_for_result = true;
    self.running = true;
    
    char* stunServer = STUN_SERVER;
    
    int countWhile = 0;
    int status;
    while (countWhile++ < 2 )
    {
        NSLog(@"Stun server: %s", stunServer);
        
         status = check_nat_type_async(&pj_callback_nat_type_set_res, (__bridge void*) self , stunServer);
        
        if (status != 0)
        {
            if (status == PJ_ERESOLVE)
            {
                //cleanup_pj();
                stunServer = STUN_SERVER_SIPGATE;
                continue;
            }
            
            NSLog(@"Error while init pj libs, status: %d\n ", status);
            
            break;
        }
        else
        {
            break;
        }
        
    }
    
    //[pool drain];
    
    return (status == PJ_SUCCESS);
    
    
}

-(BOOL) test_start_
{
   //NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];

    self.waiting_for_result = true;
    self.running = true; 
    
    char* stunServer = STUN_SERVER;
    
    int countWhile = 0;
    
    while (countWhile++ < 2 )
    {
        NSLog(@"Stun server: %s", stunServer);
        
        int status = check_nat_type_async(&pj_callback_nat_type_set_res, (__bridge void*) self , stunServer);
        
        if (status != 0)
        {
            if (status == PJ_ERESOLVE)
            {
                //cleanup_pj();
                stunServer = STUN_SERVER_SIPGATE;
                continue;
            }
            
            NSLog(@"Error while init pj libs, status: %d\n ", status);
            
            break;
        }
        
        NSDate *timeOut = [NSDate dateWithTimeIntervalSinceNow:24.0];
        
        while (self.waiting_for_result )
        {
            //do a simple "yield()" ..
            [runLoop runUntilDate:[NSDate date]];
            
            sleep(1);
            
            if ([[NSDate date] compare:timeOut] == NSOrderedDescending)
            {
                self.nat_status = PJ_ECANCELLED;
                self.nat_type = PJ_STUN_NAT_TYPE_ERR_UNKNOWN;
                break;
            }
        }
        
        ///RUN ON THREAD NOT ON UI

        //cleanup_pj();
        
        if (self.nat_status == PJ_SUCCESS)
        {
            break;
        }
    }
    
    //[pool drain];
    
    if (self.nat_type == PJ_STUN_NAT_TYPE_SYMMETRIC)
    {
        NSLog(@"ARGG we are in SYM nat !!");
        
        return TRUE;
    }

    
    return FALSE;

}




-(void) sendProbesFromSock:(pj_stun_sock *)fromSock ToIp: (NSString *) ip_ andPort:(int) port_
{
    struct pj_sockaddr_in servaddr;
    
    const char * sendline = "CMD:KICK_START";
    
    memset(&servaddr,0,sizeof(servaddr));
    servaddr.sin_family = PJ_AF_INET;
    servaddr.sin_addr.s_addr=inet_addr([ip_ UTF8String]);
    servaddr.sin_port=htons(port_);
    
    
    pj_status_t status;
    
    status = pj_stun_sock_sendto(fromSock , NULL, sendline, strlen(sendline)+1, 0,
                                 &servaddr, pj_sockaddr_get_len(&servaddr));
    
    if (status == PJ_SUCCESS)
    {
        NSLog(@"Send Probe succeeded");
    }
    else
    {
        NSLog(@"Send  Probe failed..");
        
    }
    
}


#pragma mark -
#pragma  mark  Callbacks

static void pj_callback_nat_type_set_res(void *user_data, const pj_stun_nat_detect_result *res)
{
    
    StunClient * vc = (__bridge StunClient*) user_data;
    
    vc.waiting_for_result = false;

    if(res != NULL)
    {
        NSLog(@"\n===================================\n");
        NSLog(@"Test status : %s, %d\n", res->status_text, res->status);
        
        NSLog(@"NAT types : %s\n", res->nat_type_name);
        NSLog(@"\n===================================\n");
        
        //Store the nat type
        vc.nat_type = res->nat_type;
        vc.nat_status = res->status;

    }

    
    [vc.mcallback symmetric_check_result: (res->nat_type == PJ_STUN_NAT_TYPE_SYMMETRIC)];
    
    
    
    
}



void ios_pj_log_func(int level, const char * data, int len)
{
    NSLog(@"PJLog: %d: %s", level, data);
}



@end

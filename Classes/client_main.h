//
//  client_main.h
//  TestPjnath
//
//  Created by Jason Lee on 1/10/13.
//  Copyright (c) 2013 Cvision. All rights reserved.
//

#ifndef _client_main_h
#define _client_main_h

#include <arpa/inet.h>
//#include<sys/socket.h>

#include "pjnath.h"
#include "pjlib-util.h"
#include "pjlib.h"

#include <sys/errno.h>

#define STUN_SERVER_SIPGATE "stun.sipgate.net"
#define STUN_SERVER "stun1.monitoreverywhere.com"
#define STUN_PORT    3478

struct peer
{
    pj_stun_sock   *stun_sock;
    pj_sockaddr	    mapped_addr;

    /* 20131001: added destination */
    struct sockaddr_in local_serv_addr;
    int local_serv_sock;
    
    struct sockaddr_in local_serv_addr_r;
    int local_serv_sock_r;
    
    struct pj_sockaddr_in remote_peer;
    
    pj_thread_t  * rtcp_thread;
    
    
};


struct global
{
    pj_caching_pool	 cp;
    pj_pool_t		*pool;
    pj_stun_config	 stun_config;
    pj_thread_t		*thread;
    pj_bool_t		 quit;
    
    pj_dns_resolver	*resolver;
    
    pj_turn_sock	*relay;
    pj_sockaddr		 relay_addr;
    
    struct peer		 peer[2];
} ;

 struct options
{
    pj_bool_t	 use_tcp;
    char	*srv_addr;
    char	*srv_port;
    char	*realm;
    char	*user_name;
    char	*password;
    pj_bool_t	 use_fingerprint;
    char	*stun_server;
    char	*nameserver;
} ;






struct global  * get_stun_data();
int start_stun_client_async(char* stunServer);
void set_destination_for_peer(struct peer * _peer, char * fwd_ip, int localPort);




#endif

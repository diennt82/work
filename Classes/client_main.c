/* $Id: client_main.c 3553 2011-05-05 06:14:19Z nanang $ */
/*
 * Copyright (C) 2008-2011 Teluu Inc. (http://www.teluu.com)
 * Copyright (C) 2003-2008 Benny Prijono <benny@prijono.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "client_main.h"

#define THIS_FILE	"client_main.c"
#define LOCAL_PORT	1998
#define BANDWIDTH	64		    /* -1 to disable */
#define LIFETIME	600		    /* -1 to disable */
#define REQ_TRANSPORT	-1		    /* 0: udp, 1: tcp, -1: disable */
#define REQ_PORT_PROPS	-1		    /* -1 to disable */
#define REQ_IP		0		    /* IP address string */

//#define OPTIONS		PJ_STUN_NO_AUTHENTICATE
#define OPTIONS		0


//ios log function
extern void ios_pj_log_func(int level, const char * data, int len);


static struct global g;

static struct options o;

static int worker_thread(void *unused);
static void turn_on_rx_data(pj_turn_sock *relay,
                            void *pkt,
                            unsigned pkt_len,
                            const pj_sockaddr_t *peer_addr,
                            unsigned addr_len);
static void turn_on_state(pj_turn_sock *relay, pj_turn_state_t old_state,
                          pj_turn_state_t new_state);
static pj_bool_t stun_sock_on_status(pj_stun_sock *stun_sock,
                                     pj_stun_sock_op op,
                                     pj_status_t status);
static pj_bool_t stun_sock_on_rx_data(pj_stun_sock *stun_sock,
                                      void *pkt,
                                      unsigned pkt_len,
                                      const pj_sockaddr_t *src_addr,
                                      unsigned addr_len);


static void my_perror(const char *title, pj_status_t status)
{
    char errmsg[PJ_ERR_MSG_SIZE];
    pj_strerror(status, errmsg, sizeof(errmsg));
    
    PJ_LOG(3,(THIS_FILE, "%s: %s", title, errmsg));
}

#define CHECK(expr)	status=expr; \
if (status!=PJ_SUCCESS) { \
my_perror(#expr, status); \
return status; \
}

struct global  * get_stun_data()
{
    return &g;
}


static int  start_rtcp_forwader(void * data_ptr )
{
    
    struct sockaddr_in  cliaddr ;
    int n  = 0;
    unsigned int  len ;
    char mesg[1024];
    pj_status_t  status ;
    struct peer * peer = (struct peer *) data_ptr;
    
    printf("RTCP FWD starting.. \n");
    len = sizeof(cliaddr);
    while ( g.quit != 1 )
    {
        printf("Waiting for packet..  \n");
        //after 1s it 'll timeout
        n = recvfrom(peer->local_serv_sock_r,mesg,1024,0,(struct sockaddr *)&cliaddr,&len);
        
        
         printf("Received %d bytes \n",n);
        //printf("%s",mesg);
        //forward to remote_peer
        
        if (n >0 && peer->remote_peer.sin_addr.s_addr != 0)
        {
            status = pj_stun_sock_sendto(peer->stun_sock, NULL, mesg, n, 0,
                                         &peer->remote_peer,
                                         pj_sockaddr_get_len(&peer->remote_peer));
            if (status != PJ_SUCCESS)
                my_perror("send RTCP to remote peer failed", status);
        }
    }
    
    printf("RTCP FWD Exiting.. \n");
    return 0; 
}



static int init()
{
    int i;
    pj_status_t status;
    
    CHECK( pj_init() );
    CHECK( pjlib_util_init() );
    CHECK( pjnath_init() );
    
    
    pj_thread_desc rtpdesc;
    pj_thread_t *thread = 0;
    
    // Register the thread with PJLIB, this is must for any external threads
    // which need to use the PJLIB framework
    if (!pj_thread_is_registered())
    {
        status = pj_thread_register("client_main", rtpdesc, &thread );
        if (status != PJ_SUCCESS)
        {
            return PJ_EINVAL;
        }
    }
    
    //20131002: phung : change log function
    pj_log_set_log_func(ios_pj_log_func); 
    
    
    /* Check that server is specified */
    if (!o.srv_addr) {
        printf("Error: server must be specified\n");
        return PJ_EINVAL;
    }
    
    pj_caching_pool_init(&g.cp, &pj_pool_factory_default_policy, 0);
    
    g.pool = pj_pool_create(&g.cp.factory, "main", 1000, 1000, NULL);
    
    /* Init global STUN config */
    pj_stun_config_init(&g.stun_config, &g.cp.factory, 0, NULL, NULL);
    
    /* Create global timer heap */
    CHECK( pj_timer_heap_create(g.pool, 1000, &g.stun_config.timer_heap) );
    
    /* Create global ioqueue */
    CHECK( pj_ioqueue_create(g.pool, 16, &g.stun_config.ioqueue) );
    
    /*
     * Create peers
     */
    for (i=0; i<(int)PJ_ARRAY_SIZE(g.peer); ++i)
    {
        pj_stun_sock_cb stun_sock_cb;
        char name[] = "peer0";
        pj_uint16_t port;
        pj_stun_sock_cfg ss_cfg;
        pj_str_t server;
        
        pj_bzero(&stun_sock_cb, sizeof(stun_sock_cb));
        stun_sock_cb.on_rx_data = &stun_sock_on_rx_data;
        stun_sock_cb.on_status = &stun_sock_on_status;
        
        g.peer[i].mapped_addr.addr.sa_family = pj_AF_INET();
        
        pj_stun_sock_cfg_default(&ss_cfg);
#if 1
        /* make reading the log easier */
        ss_cfg.ka_interval = 300;
#endif
        
        name[strlen(name)-1] = '0'+i;
        status = pj_stun_sock_create(&g.stun_config, name, pj_AF_INET(),
                                     &stun_sock_cb, &ss_cfg,
                                     &g.peer[i], &g.peer[i].stun_sock);
        if (status != PJ_SUCCESS) {
            my_perror("pj_stun_sock_create()", status);
            return status;
        }
        
        if (o.stun_server) {
            server = pj_str(o.stun_server);
            port = PJ_STUN_PORT;
        } else {
            server = pj_str(o.srv_addr);
            port = (pj_uint16_t)(o.srv_port?atoi(o.srv_port):PJ_STUN_PORT);
        }
        status = pj_stun_sock_start(g.peer[i].stun_sock, &server,
                                    port,  NULL);
        if (status != PJ_SUCCESS) {
            my_perror("pj_stun_sock_start()", status);
            return status;
        }
    }
    
    /* Start the worker thread */
    g.quit = 0;
    CHECK( pj_thread_create(g.pool, "stun", &worker_thread, NULL, 0, 0, &g.thread) );
    
    
    return PJ_SUCCESS;
}


static int client_shutdown()
{
    unsigned i;
    
    if (g.thread) {
        g.quit = 1;
        pj_thread_join(g.thread);
        pj_thread_destroy(g.thread);
        g.thread = NULL;
        
        //wait for fwder thread to die off too
        for (i=0; i<PJ_ARRAY_SIZE(g.peer); ++i)
        {
            if (g.peer[i].rtcp_thread != NULL)
            {
                pj_thread_join(g.peer[i].rtcp_thread);
                pj_thread_destroy(g.peer[i].rtcp_thread);
                g.peer[i].rtcp_thread = NULL;
            }
        }
    }
    if (g.relay) {
        pj_turn_sock_destroy(g.relay);
        g.relay = NULL;
    }
    for (i=0; i<PJ_ARRAY_SIZE(g.peer); ++i) {
        if (g.peer[i].stun_sock) {
            pj_stun_sock_destroy(g.peer[i].stun_sock);
            g.peer[i].stun_sock = NULL;
        }
    }
    if (g.stun_config.timer_heap) {
        pj_timer_heap_destroy(g.stun_config.timer_heap);
        g.stun_config.timer_heap = NULL;
    }
    if (g.stun_config.ioqueue) {
        pj_ioqueue_destroy(g.stun_config.ioqueue);
        g.stun_config.ioqueue = NULL;
    }
    if (g.pool) {
        pj_pool_release(g.pool);
        g.pool = NULL;
    }
    pj_pool_factory_dump(&g.cp.factory, PJ_TRUE);
    pj_caching_pool_destroy(&g.cp);
    pj_shutdown();
    return PJ_SUCCESS;
}


static int worker_thread(void *unused)
{
    PJ_UNUSED_ARG(unused);
    
    while (!g.quit) {
        const pj_time_val delay = {0, 10};
        
        /* Poll ioqueue for the TURN client */
        pj_ioqueue_poll(g.stun_config.ioqueue, &delay);
        
        /* Poll the timer heap */
        pj_timer_heap_poll(g.stun_config.timer_heap, NULL);
        
    }
    
    return 0;
}

static pj_status_t create_relay(void)
{
    pj_turn_sock_cb rel_cb;
    pj_stun_auth_cred cred;
    pj_str_t srv;
    pj_status_t status;
    
    if (g.relay) {
        PJ_LOG(1,(THIS_FILE, "Relay already created"));
        return -1;
    }
    
    /* Create DNS resolver if configured */
    if (o.nameserver) {
        pj_str_t ns = pj_str(o.nameserver);
        
        status = pj_dns_resolver_create(&g.cp.factory, "resolver", 0,
                                        g.stun_config.timer_heap,
                                        g.stun_config.ioqueue, &g.resolver);
        if (status != PJ_SUCCESS) {
            PJ_LOG(1,(THIS_FILE, "Error creating resolver (err=%d)", status));
            return status;
        }
        
        status = pj_dns_resolver_set_ns(g.resolver, 1, &ns, NULL);
        if (status != PJ_SUCCESS) {
            PJ_LOG(1,(THIS_FILE, "Error configuring nameserver (err=%d)", status));
            return status;
        }
    }
    
    pj_bzero(&rel_cb, sizeof(rel_cb));
    rel_cb.on_rx_data = &turn_on_rx_data;
    rel_cb.on_state = &turn_on_state;
    CHECK( pj_turn_sock_create(&g.stun_config, pj_AF_INET(),
                               (o.use_tcp? PJ_TURN_TP_TCP : PJ_TURN_TP_UDP),
                               &rel_cb, 0,
                               NULL, &g.relay) );
    
    if (o.user_name) {
        pj_bzero(&cred, sizeof(cred));
        cred.type = PJ_STUN_AUTH_CRED_STATIC;
        cred.data.static_cred.realm = pj_str(o.realm);
        cred.data.static_cred.username = pj_str(o.user_name);
        cred.data.static_cred.data_type = PJ_STUN_PASSWD_PLAIN;
        cred.data.static_cred.data = pj_str(o.password);
        //cred.data.static_cred.nonce = pj_str(o.nonce);
    } else {
        PJ_LOG(2,(THIS_FILE, "Warning: no credential is set"));
    }
    
    srv = pj_str(o.srv_addr);
    CHECK(pj_turn_sock_alloc(g.relay,				 /* the relay */
                             &srv,				 /* srv addr */
                             (o.srv_port?atoi(o.srv_port):PJ_STUN_PORT),/* def port */
                             g.resolver,				 /* resolver */
                             (o.user_name?&cred:NULL),		 /* credential */
                             NULL)				 /* alloc param */
          );
    
    return PJ_SUCCESS;
}

static void destroy_relay(void)
{
    if (g.relay) {
        pj_turn_sock_destroy(g.relay);
    }
}


static void turn_on_rx_data(pj_turn_sock *relay,
                            void *pkt,
                            unsigned pkt_len,
                            const pj_sockaddr_t *peer_addr,
                            unsigned addr_len)
{
    char addrinfo[80];
    
    pj_sockaddr_print(peer_addr, addrinfo, sizeof(addrinfo), 3);
    
    PJ_LOG(3,(THIS_FILE, "Client received %d bytes data from %s: %.*s",
              pkt_len, addrinfo, pkt_len, pkt));
}


static void turn_on_state(pj_turn_sock *relay, pj_turn_state_t old_state,
                          pj_turn_state_t new_state)
{
    PJ_LOG(3,(THIS_FILE, "State %s --> %s", pj_turn_state_name(old_state),
              pj_turn_state_name(new_state)));
    
    if (new_state == PJ_TURN_STATE_READY) {
        pj_turn_session_info info;
        pj_turn_sock_get_info(relay, &info);
        pj_memcpy(&g.relay_addr, &info.relay_addr, sizeof(pj_sockaddr));
    } else if (new_state > PJ_TURN_STATE_READY && g.relay) {
        PJ_LOG(3,(THIS_FILE, "Relay shutting down.."));
        g.relay = NULL;
    }
}

static pj_bool_t stun_sock_on_status(pj_stun_sock *stun_sock,
                                     pj_stun_sock_op op,
                                     pj_status_t status)
{
    struct peer *peer = (struct peer*) pj_stun_sock_get_user_data(stun_sock);
    
    if (status == PJ_SUCCESS) {
        PJ_LOG(4,(THIS_FILE, "peer%d: %s success", peer-g.peer,
                  pj_stun_sock_op_name(op)));
    } else {
        char errmsg[PJ_ERR_MSG_SIZE];
        pj_strerror(status, errmsg, sizeof(errmsg));
        PJ_LOG(1,(THIS_FILE, "peer%d: %s error: %s", peer-g.peer,
                  pj_stun_sock_op_name(op), errmsg));
        return PJ_FALSE;
    }
    
    if (op==PJ_STUN_SOCK_BINDING_OP || op==PJ_STUN_SOCK_KEEP_ALIVE_OP) {
        pj_stun_sock_info info;
        int cmp;
        
        pj_stun_sock_get_info(stun_sock, &info);
        cmp = pj_sockaddr_cmp(&info.mapped_addr, &peer->mapped_addr);
        
        if (cmp) {
            char straddr[PJ_INET6_ADDRSTRLEN+10];
            
            pj_sockaddr_cp(&peer->mapped_addr, &info.mapped_addr);
            pj_sockaddr_print(&peer->mapped_addr, straddr, sizeof(straddr), 3);
            PJ_LOG(3,(THIS_FILE, "peer%d: STUN mapped address is %s",
                      peer-g.peer, straddr));
            
        }
    }
    
    return PJ_TRUE;
}



/*
 Need:
 1 socket out - Send Keepalive, send dummy, rcv packet from caeram
 
 
 1 local socket - send aud/vid data to local port
 
 */

void set_destination_for_peer(struct peer * _peer, char * fwd_ip, int localPort)
{
    int camera_socket = -1 ;
    
    
    if ( (camera_socket=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) != 0 )        // create a client socket
    {
        _peer->local_serv_sock = camera_socket;
 

        memset(&_peer->local_serv_addr, 0, sizeof( struct sockaddr_in));
        _peer->local_serv_addr.sin_family = AF_INET;
        _peer->local_serv_addr.sin_addr.s_addr=inet_addr(fwd_ip); //Local host
        _peer->local_serv_addr.sin_port=htons(localPort);
        
        
    }
    
    
    int read_camera_socket = -1;
    pj_status_t status;
    
    if ((read_camera_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) != 0 )
    {
        _peer->local_serv_sock_r = read_camera_socket;
        
        memset(&_peer->local_serv_addr_r, 0, sizeof( struct sockaddr_in));
        _peer->local_serv_addr_r.sin_family = AF_INET;
        _peer->local_serv_addr_r.sin_addr.s_addr=htonl(INADDR_ANY); //inet_addr(fwd_ip); //Local host
        _peer->local_serv_addr_r.sin_port=htons(localPort+1); //RTCP port
        
        struct timeval tv;
        tv.tv_sec = 1;
        tv.tv_usec = 0;
        setsockopt(_peer->local_serv_sock_r, SOL_SOCKET, SO_RCVTIMEO,&tv,sizeof(struct timeval));
        
        
        bind( _peer->local_serv_sock_r,(struct sockaddr *)&_peer->local_serv_addr_r,sizeof(_peer->local_serv_addr_r));
        
        status =  pj_thread_create(g.pool, "RTCP FWDER" ,
                                   start_rtcp_forwader, _peer , 0, 0,
                                   &_peer->rtcp_thread) ;
        
        
    }

    
    
}

static pj_bool_t stun_sock_on_rx_data(pj_stun_sock *stun_sock,
                                      void *pkt,
                                      unsigned pkt_len,
                                      const pj_sockaddr_t *src_addr,
                                      unsigned addr_len)
{
    struct peer *peer = (struct peer*) pj_stun_sock_get_user_data(stun_sock);
    
#if 0 // test
    char straddr[PJ_INET6_ADDRSTRLEN+10];
    ((char*)pkt)[pkt_len] = '\0';
    
    pj_sockaddr_print(src_addr, straddr, sizeof(straddr), 3);
    PJ_LOG(3,(THIS_FILE, "peer%d: received %d bytes data from %s: %s",
              peer-g.peer, pkt_len, straddr, (char*)pkt));
    
    
#endif 
    
    int camera_socket = peer->local_serv_sock;

    //PJ_LOG(3,(THIS_FILE, "camera_socket:%d", camera_socket) );
    if (camera_socket != -1)
    {
        //Only when the camera_socket is ready
        // - send pkt to local socket at specify port
        pj_status_t status;
        //printf("addr->sin_addr.s_addr == %d \n", peer->local_serv_addr.sin_addr.s_addr);
        
        status = sendto(camera_socket ,  (char*) pkt,pkt_len, 0,
                        (struct sockaddr *)&peer->local_serv_addr, sizeof(struct sockaddr));
        
        if (status == -1)
        {
            int err = errno;
            printf("local Send failed %d : %s\n",err, strerror(err));
        }
        else
        {
           // printf("Local Send succeeded");
            
        }
        
        

    }
    
    return PJ_TRUE;
}


/**** Added    */


int start_stun_client_async(char* stunServer)
{
    pj_status_t status;
    o.stun_server = stunServer;
    o.srv_addr = stunServer;
    
    if ((status=init()) != 0)
    {
        return -1;
    }
    
    
    return 0;
}



/* */
int check_nat_type_async ( pj_stun_nat_detect_cb *cb, void* user_data, char* stun_server )
{
    pj_status_t status;
    
    
#if 0
    o.stun_server = stun_server;
    o.srv_addr = stun_server;
    
    if ((status=init()) != 0)
    {
        
        return status;
    }
#endif 
    
    
    printf("Start nat_type_check\n");
    
    
    /* Checking NAT type for global uses */
    
    
    static pj_sockaddr_in server;
    pj_str_t srv_adr;
    
    srv_adr = pj_str(o.stun_server);
    
    status = pj_sockaddr_in_init(&server, &srv_adr, STUN_PORT);
    if(status != PJ_SUCCESS)
    {
        //check_stun_error("pj_sockaddr_init()", status);
        printf("ERROR: pj_sockaddr_in_init\n");
        return status;
    }
    
    status = pj_stun_detect_nat_type(&server, &g.stun_config, user_data, cb);
    printf("cb: %p", cb);
    if(status != PJ_SUCCESS)
    {
        //check_stun_error("pj_stun_detect_nat_type()", status);
        printf("ERROR: pj_stun_detect_nat_type\n");
        return status;
    }
    
    
    
    return 0;
    
}

int cleanup_pj()
{
    
    
    
    
    client_shutdown();
    
    return 0;
}





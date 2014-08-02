//
//  BLEConnectionManager.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 20/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

typedef enum
{
    IDLE = 0,
    SCANNING,
    CONNECTING, 
    CONNECTED,
    DISCONNECTED,
} ConnectionState;


typedef enum
{
    LOGGING,
    RX,
    TX,
} ConsoleDataType;

#import <Foundation/Foundation.h>
#import "UARTPeripheral.h"
@protocol BLEConnectionManagerDelegate
@required
- (void) didReceiveData:(NSString *) string;


@optional
- (void) didConnectToBle:(CBUUID*) service_id ;
- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera;
- (void) didReceiveBLEList:(NSMutableArray *) bleLists;
- (void) bleDisconnected;
@end



#define SCAN_FOR_ANY_DEVICE 1
#define SCAN_FOR_SINGLE_DEVICE 2
@interface BLEConnectionManager : NSObject <CBCentralManagerDelegate, UARTPeripheralDelegate>

{
    
    CBCentralManager *_cm;
    
    ConnectionState _state;
    
    UARTPeripheral *_uartPeripheral;
    
    BOOL _isOnBLE;
    CBPeripheral *_myPeripheral;
    NSMutableArray *_listBLEs;
  
    BOOL needReconnect; 
    int scanMode;
    
}
@property (nonatomic) BOOL needReconnect;
@property (retain, nonatomic) CBCentralManager *cm;

@property (nonatomic, strong) CBPeripheral *myPeripheral;
@property (nonatomic, strong) NSMutableArray *listBLEs;
@property (assign) ConnectionState state;

@property (retain, nonatomic) UARTPeripheral *uartPeripheral;

@property (nonatomic,assign) BOOL isOnBLE;
@property (assign) id<BLEConnectionManagerDelegate> delegate;


+ (ConnectionState)checkStatusConnectBLE;
+ (BLEConnectionManager *) getInstanceBLE;
- (id) init;
- (void) reinit;
- (void)scan;
- (void)reScan;
- (void)stopScanBLE;
-(void) disconnect;
- (void)connectToBLEWithPeripheral:(CBPeripheral *)peripheral;
-(void) reScanForPeripheral:(CBUUID *) dev_service_id;

- (void) didConnect;
//- (void) didDisconnect;


@end


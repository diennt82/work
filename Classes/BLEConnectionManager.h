//
//  BLEConnectionManager.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 20/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UARTPeripheral.h"

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

@protocol BLEConnectionManagerDelegate

@required
- (void)didReceiveData:(NSString *)string;

@optional
- (void)didConnectToBle:(CBUUID*)serviceId ;
- (void)onReceiveDataError:(int)errorCode forCommand:(NSString *)commandToCamera;
- (void)didReceiveBLEList:(NSMutableArray *)bleLists;
- (void)bleDisconnected;

@end

#define SCAN_FOR_ANY_DEVICE 1
#define SCAN_FOR_SINGLE_DEVICE 2

@interface BLEConnectionManager : NSObject <CBCentralManagerDelegate, UARTPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *cm;
@property (nonatomic, strong) CBPeripheral *myPeripheral;
@property (nonatomic, strong) NSMutableArray *listBLEs;
@property (nonatomic, strong) UARTPeripheral *uartPeripheral;

@property (nonatomic, assign) id<BLEConnectionManagerDelegate> delegate;

@property (nonatomic) ConnectionState state;
@property (nonatomic) BOOL needReconnect;
@property (nonatomic) BOOL isOnBLE;

+ (BLEConnectionManager *)instanceBLE;
+ (ConnectionState)checkStatusConnectBLE;

- (id)init;
- (void)reinit;
- (void)scan;
- (void)reScan;
- (void)stopScanBLE;
- (void)disconnect;
- (void)connectToBLEWithPeripheral:(CBPeripheral *)peripheral;
- (void)reScanForPeripheral:(CBUUID *)devServiceId;
- (void)didConnect;

@end


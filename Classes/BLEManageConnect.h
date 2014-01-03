//

//  BLEManageConnect.h

//  BlinkHD_ios

//

//  Created by Jason Lee on 20/12/13.

//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.

//

typedef enum
{
    IDLE = 0,
    SCANNING,
    CONNECTED,
} ConnectionState;


typedef enum
{
    LOGGING,
    RX,
    TX,
} ConsoleDataType;

#import <Foundation/Foundation.h>
#import "UARTPeripheral.h"
@protocol BLEManageConnectDelegate
@required
- (void) didReceiveData:(NSString *) string;
@optional
- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera;
- (void) didReceiveBLEList:(NSMutableArray *) bleLists;
@end


@interface BLEManageConnect : NSObject <CBCentralManagerDelegate, UARTPeripheralDelegate>

{
    
    CBCentralManager *_cm;
    
    ConnectionState _state;
    
    UARTPeripheral *_uartPeripheral;
    
    BOOL _isOnBLE;
    CBPeripheral *_myPeripheral;
    NSMutableArray *_listBLEs;
    
}
@property (retain, nonatomic) CBCentralManager *cm;

@property (nonatomic, strong) CBPeripheral *myPeripheral;
@property (nonatomic, strong) NSMutableArray *listBLEs;
@property (assign) ConnectionState state;

@property (retain, nonatomic) UARTPeripheral *uartPeripheral;

@property (nonatomic,assign) BOOL isOnBLE;
@property (assign) id<BLEManageConnectDelegate> delegate;

+ (ConnectionState)checkStatusConnectBLE;
+ (BLEManageConnect *) getInstanceBLE;
- (id) init;
- (void)scan;
- (void)reScan;
- (void) didConnect;
- (void) didDisconnect;
- (void)connectToBLEWithPeripheral:(CBPeripheral *)peripheral;
@end


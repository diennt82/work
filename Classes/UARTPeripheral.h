//
//  UARTPeripheral.h
//  nRF UART
//
//  Created by Ole Morten on 1/12/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol UARTPeripheralDelegate
- (void) didReceiveData:(NSString *) string;
- (void) didReceiveRawData:(NSData *) data;
- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera;

@optional
- (void) didReadHardwareRevisionString:(NSString *) string;
-(void) readyToTxRx;
@end

#define SEQUENCE_MAX 0x7f
#define SEQUENCE_MIN 0x01


typedef enum response_ {
    WRITE_SUCCESS = 0,
    WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE,

    
    READ_SUCCESS = 100,
    READ_ERROR_ZERO_LEN = 101,
    READ_ON_GOING = 102,
    READ_TIME_OUT = 103
    
} ble_response_t;


@interface UARTPeripheral : NSObject <CBPeripheralDelegate>
{
    char sequence ;
    NSMutableData  * rx_buff;
    NSString * commandToCamera;
    ble_response_t read_error;
    int retry_count;
    NSTimer *_timeOutCommand;
    NSTimer * hello_timer;
    float timeout;
    
}
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (assign) id<UARTPeripheralDelegate> delegate;
@property BOOL isBusy, isFlushing, isDisconnected;
@property (nonatomic) NSTimer * hello_timer; 

+ (CBUUID *) uartServiceUUID;

- (UARTPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<UARTPeripheralDelegate>) delegate;

- (ble_response_t) writeString:(NSString *) string;
- (ble_response_t) writeString:(NSString *) string withTimeOut:(NSTimeInterval) time;
- (ble_response_t) flush;
- (ble_response_t) flush:(NSTimeInterval) time;
- (void) didConnect;
- (void) didDisconnect;
@end

//
//  UARTPeripheral.m
//  nRF UART
//
//  Created by Ole Morten on 1/12/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import "UARTPeripheral.h"

@interface UARTPeripheral ()
@property CBService *uartService;
@property CBCharacteristic *rxCharacteristic;
@property CBCharacteristic *txCharacteristic;

@end

@implementation UARTPeripheral

+ (CBUUID *) uartServiceUUID
{
    return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) txCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) rxCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

- (UARTPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<UARTPeripheralDelegate>) delegate
{
    if (self = [super init]) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        self.delegate = delegate;
    }
    return self;
}

- (void) didConnect
{
    [_peripheral discoverServices:@[self.class.uartServiceUUID, self.class.deviceInformationServiceUUID]];
    sequence = SEQUENCE_MIN;
    rx_buff = [[NSMutableData alloc] init];
    self.isDisconnected = NO;
    NSLog(@"Did start service discovery. start timer");
}

- (void)didDisconnect
{
    sequence = SEQUENCE_MIN;
    [rx_buff setLength: 0];
    self.isBusy = NO;
    
    if ( [_helloTimer isValid] ) {
        [_helloTimer invalidate];
        self.helloTimer = nil;
    }
    
    //invalidate time out
    if ( [_timeOutCommand isValid] ) {
        [_timeOutCommand invalidate];
        self.timeOutCommand = nil;
    }

    self.isDisconnected = YES;
    
    NSLog(@"UART PERI: didDisconnect, stop timer ");
}

-(void) retryOldCommand:(NSString *) string
{
    commandToCamera = string;
    [rx_buff setLength:0]; // clear all backlog
    read_error = READ_ON_GOING;
    
    NSMutableData * data = [[NSMutableData alloc] init];
    [data appendBytes:string.UTF8String length:string.length];
    
    unsigned char null_char  [] = {0x00};
    
    [data appendBytes:(const void *)null_char length:1];
    NSLog(@"data is: %@", data);

    if ( [data length] > 20) {
        int remain_len = [data length];
        int data_idx = 0;
        
        int len_to_send;
        NSData *chunk;
        NSRange range;
        
        while (remain_len > 0 ) {
            len_to_send = (remain_len > 20)?20:remain_len;
            
            // Split in multiple chunks
            range = NSMakeRange(data_idx, len_to_send) ;
            chunk = [data subdataWithRange:range];
            
            if ((self.txCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0) {
                [self.peripheral writeValue: (NSData *) chunk forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
            }
            else if ((self.txCharacteristic.properties & CBCharacteristicPropertyWrite) != 0) {
                [self.peripheral writeValue:  (NSData *) chunk forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            else {
                NSLog(@"No write property on TX characteristic, %d.", self.txCharacteristic.properties);
            }
            
            remain_len -= len_to_send;
            data_idx  += len_to_send;
        }
    }
    else {
        if ((self.txCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0) {
            [self.peripheral writeValue: (NSData *) data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if ((self.txCharacteristic.properties & CBCharacteristicPropertyWrite) != 0) {
            [self.peripheral writeValue:  (NSData *) data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else {
            NSLog(@"No write property on TX characteristic, %d.", self.txCharacteristic.properties);
        }
    }
    
    NSLog(@"Finish writing");
}

- (ble_response_t) flush
{
    if ( _isBusy ) {
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = YES;
    self.isFlushing = YES;
    retry_count =  0;
    
    //Purposely send empty command to flush the system
    [self retryOldCommand:@"01234567890123456"];
    
    return WRITE_SUCCESS;
}

- (ble_response_t) flush:(NSTimeInterval)time
{
    self.timeOutCommand = [NSTimer scheduledTimerWithTimeInterval:time
                                                           target:self
                                                         selector:@selector(receiveDataTimeOut:)
                                                         userInfo:nil
                                                          repeats:NO];
    if ( _isBusy ) {
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = YES;
    self.isFlushing = YES;
    retry_count =  0;
    
    //Purposely send empty command to flush the system
    [self retryOldCommand:@"01234567890123456"];
    
    return WRITE_SUCCESS;
}

- (void)sendHello:(NSTimer *)exp
{
    self.helloTimer = nil;
    
    if ( !_isBusy ) {
        self.isBusy = YES;
        self.isFlushing = YES;
        retry_count =  0;
        
        //Purposely send empty command to flush the system
        [self retryOldCommand:@"hello_hello"];
    }
}

- (ble_response_t)writeString:(NSString *)string
{
    if ( _isBusy ) {
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = YES;
    
    //Retry 10 times only if we hit the 0-len issue;
    retry_count =  10;
    
    [self retryOldCommand:string];
    
    return WRITE_SUCCESS;
}

- (ble_response_t) writeString:(NSString *) string withTimeOut:(NSTimeInterval) time
{
    if ( [_helloTimer isValid]) {
        [_helloTimer invalidate];
        self.helloTimer = nil;
    }
    
    // Here it could be sending the hello... so what we can do is wait for this to be over..
    // UI thread may be blocked
    if ( _isBusy ) {
        NSLog(@"wait for a while ");
        
        NSDate *date;
        while ( _isBusy ) {
            date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
            [[NSRunLoop currentRunLoop] runUntilDate:date];
        }
        
        if ( _isDisconnected) {
            NSLog(@"after waiting.. now disconnected ");
            return -1;
        }
    }
    
    timeout = time;
    self.timeOutCommand = [NSTimer scheduledTimerWithTimeInterval:time
                                                           target:self
                                                         selector:@selector(receiveDataTimeOut:)
                                                         userInfo:nil
                                                          repeats:NO];
    if ( _isBusy ) {
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = YES;
    
    //Retry 10 times only if we hit the 0-len issue;
    retry_count =  10;
    
    [self retryOldCommand:string];
    
    return WRITE_SUCCESS;
}

-(void) receiveDataTimeOut:(NSTimer *) timer
{
    // when timeout - just simply resend
    NSLog(@"retrying with timeout :%f & cmd is %@", timeout, commandToCamera);
        
    if ( [commandToCamera isEqualToString:@"get_wifi_connection_state"] && retry_count < 10 ) {
        //HACK
        self.timeOutCommand = [NSTimer scheduledTimerWithTimeInterval: timeout
                                                               target:self
                                                             selector:@selector(receiveDataTimeOut:)
                                                             userInfo:nil
                                                              repeats:NO];
        
        
        //commandToCamera = @"get_version";
        
        NSLog(@"retrying with timeout :%@", commandToCamera);
        [self retryOldCommand:commandToCamera];
    }
    else {
        self.timeOutCommand = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                               target:self
                                                             selector:@selector(receiveDataTimeOut:)
                                                             userInfo:nil
                                                              repeats:NO];
        [self retryOldCommand:commandToCamera];
    }
}

- (void)writeRawData:(NSData *)data
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", error);
        return;
    }
    
    for (CBService *s in [peripheral services]) {
        if ([s.UUID isEqual:self.class.uartServiceUUID]) {
            NSLog(@"Found correct service");
            self.uartService = s;
            
            [self.peripheral discoverCharacteristics:@[self.class.txCharacteristicUUID, self.class.rxCharacteristicUUID] forService:self.uartService];
        }
        else if ([s.UUID isEqual:self.class.deviceInformationServiceUUID]) {
            [self.peripheral discoverCharacteristics:@[self.class.hardwareRevisionStringUUID] forService:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", error);
        return;
    }
    
    for (CBCharacteristic *c in [service characteristics]) {
        if ([c.UUID isEqual:self.class.rxCharacteristicUUID]) {
            NSLog(@"Found RX characteristic");
            self.rxCharacteristic = c;
            
            [self.peripheral setNotifyValue:YES forCharacteristic:self.rxCharacteristic];
        }
        else if ([c.UUID isEqual:self.class.txCharacteristicUUID]) {
            NSLog(@"Found TX characteristic");
            self.txCharacteristic = c;
        }
        else if ([c.UUID isEqual:self.class.hardwareRevisionStringUUID]) {
            NSLog(@"Found Hardware Revision String characteristic");
            [self.peripheral readValueForCharacteristic:c];
        }
    }
    
    NSLog(@"Found TX & RX characteristic");
    if ( _delegate ) {
        [self.delegate readyToTxRx];
        
        if ( _helloTimer ) {
            [_helloTimer invalidate];
        }
        
        self.helloTimer = [NSTimer scheduledTimerWithTimeInterval:7.0
                                                           target:self
                                                         selector:@selector(sendHello:)
                                                         userInfo:nil
                                                          repeats:NO];
    }
}

- (int)checkBufferForNullChar:(NSData *)dataBuff
{
    BOOL found = NO;
    
    //find the 1 00
    int i;
    char * data_ptr =(char * ) [dataBuff bytes];
    for ( i = 0 ; i < dataBuff.length; i++ ) {
        if ( data_ptr[i] ==0x01) {
            found = YES;
            break;
        }
    }
    
    if (found == NO) {
        i = -1;
    }
    
    return i;
}

- (int)checkBuffer:(NSData *)dataBuff forSequence:(int)seq
{
    if ( dataBuff.length < 20 ) {
        return -1;
    }
    
    BOOL found = NO;
    
    // find the 20 00s
    char *dataPtr =(char *)dataBuff.bytes;
    int i;
    for ( i = 20 ; i < dataBuff.length; i++ ) {
        if ( dataPtr[i] != 0x00 &&
            dataPtr[i-1] == 0x00 &&
            dataPtr[i-2] == 0x00 &&
            dataPtr[i-3] == 0x00 &&
            dataPtr[i-4] == 0x00 &&
            dataPtr[i-5] == 0x00 &&
            dataPtr[i-6] == 0x00 &&
            dataPtr[i-7] == 0x00 &&
            dataPtr[i-8] == 0x00 &&
            dataPtr[i-9] == 0x00 &&
            dataPtr[i-10] == 0x00 &&
            dataPtr[i-11] == 0x00 &&
            dataPtr[i-12] == 0x00 &&
            dataPtr[i-13] == 0x00 &&
            dataPtr[i-14] == 0x00 &&
            dataPtr[i-15] == 0x00 &&
            dataPtr[i-16] == 0x00 &&
            dataPtr[i-17] == 0x00 &&
            dataPtr[i-18] == 0x00 &&
            dataPtr[i-19] == 0x00 &&
            dataPtr[i-20] == 0x00
            )
        {
            //Found it
            found = YES;
            break;
        }
    }
    
    if ( found ) {
        NSLog(@"found a matching sequence :%x %x %x", dataPtr[i-1], dataPtr[i], dataPtr[i+1]);
        if (seq  == dataPtr[i] ) {
            NSLog(@"found a matching sequence :%d", seq);
            return i;
        }
    }
    
    NSLog(@"No matching sequence %d", sequence);
    
    return -1;
}


- (int)checkBufferFor02char:(NSData *)dataBuff
{
    int last_index = -1;
    
    // find the 1 00
    int i;
    char * dataPtr =(char *)dataBuff.bytes;
    for ( i = 0 ; i < dataBuff.length; i++ ) {
        if ( dataPtr[i] ==0x02) {
            last_index = i;
        }
        else {
            break;
        }
    }
    
    return last_index;
}

// ff ff 00 57
- (int)checkBufferForSpecialSequence:(NSData *)dataBuff
{
    int lastIndex = -1;
    if ( dataBuff.length < 4 )
    {
        return lastIndex;
        
    }
    
    // find the 1 00
    int i;
    unsigned char * dataPtr = (unsigned char *)dataBuff.bytes;
    for ( i = 0 ; i < dataBuff.length - 3; i++ ) {
        if ( dataPtr[i] == 0xff &&
             dataPtr[i+1] == 0xff &&
             dataPtr[i+2] == 0x00 &&
             dataPtr[i+3] == 0x57)
        {
            lastIndex = i;
            break;
        }
    }
    
    return lastIndex;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    
    NSLog(@"Received data on a characteristic.");
    
    if (characteristic == self.rxCharacteristic) {
        unsigned char *rcvData = (unsigned char *)[[characteristic value] bytes];
        
        NSString *log = @"";
        
        for (int i = 0 ; i < ([[characteristic value] length] - 1); i++ ) {
            log = [log stringByAppendingFormat:@"%02x ", rcvData[i]];
        }
        
        NSLog(@"Raw:  %@" ,  log);
        
        int endblockIndex = [[characteristic value] length] - 1;
        
        for ( int i = 0 ; i < ([[characteristic value] length] - 2); i++ ) {
            if (rcvData[i] == 0x03 && rcvData[i+1] == 0x00 ) {
                NSLog(@"0x03 0x00 at  %d" ,  i);
                endblockIndex = i;
                break;
            }
        }
        
        [rx_buff appendBytes:[[characteristic value] bytes] length: endblockIndex  /*[characteristic value].length -1 */];
        
        // If the 0x0300 is in the middle, we still have some extra bytes.
        if ( endblockIndex  < ([[characteristic value] length] - 2) ) {
            NSLog(@"after 0x03 0x00 there is  %d" ,  [characteristic value].length -1 -2 - endblockIndex);
            [rx_buff appendBytes:[[characteristic value] bytes]+endblockIndex+2 length:( [characteristic value].length - 1 - 2 - endblockIndex )];
        }

        int garbage_seq_index = [self checkBufferForSpecialSequence:rx_buff];
        if ( garbage_seq_index != -1 ) {
            // Force disconnect BLE
            NSLog(@">>> found some garbage code.. Disconnect BLE!!");
            [self receiveDataTimeOut:nil];
            return;
        }

        // Find the end 0x01 char
        int sequence_index = [self checkBufferForNullChar:rx_buff];
        if ( sequence_index != -1 ) {
            int padding_index =[self checkBufferFor02char:rx_buff] ;
            //take the sub range starting from the latest index of 0x02 -
            NSRange range = NSMakeRange(padding_index+1, sequence_index-(padding_index+1));

            NSData *result_str = [rx_buff subdataWithRange:range];
            NSLog(@"Got enough data : %d, - commandToCamera: %@",[result_str length], commandToCamera);
            
            /*
             * Try to fix: Uncaught exception: *** +[NSString stringWithUTF8String:]: NULL cString
             */
            
            NSString *string = result_str ? [NSString stringWithUTF8String:[result_str bytes]] : nil;
            
            // invalidate time out
            if (_timeOutCommand && [_timeOutCommand isValid]) {
                [_timeOutCommand invalidate];
                _timeOutCommand = nil;
            }
            
            self.isBusy = NO;
            
            if ( [commandToCamera isEqualToString:@"hello_hello"] && [string isEqualToString:@"NA"] ) {
                NSLog(@"Got response for command hello_hello, just ignore delegate call ");
            }
            else {
                [self.delegate didReceiveData:string];
            }
            
            //cut this string away
            range = NSMakeRange(0, sequence_index+1);
            [rx_buff replaceBytesInRange:range
                               withBytes:NULL
                                  length:0];

            read_error = READ_SUCCESS;

            NSLog(@"start hello timer");
            
            [_helloTimer invalidate];
            self.helloTimer = [NSTimer scheduledTimerWithTimeInterval:7.0
                                                               target:self
                                                             selector:@selector(sendHello:)
                                                             userInfo:nil
                                                              repeats:NO];
        }
        else {
            NSLog(@"Not enough data  yet");
        }
    }
    else if ([characteristic.UUID isEqual:self.class.hardwareRevisionStringUUID]) {
        NSString *hwRevision = @"";
        const uint8_t *bytes = characteristic.value.bytes;
        for (int i = 0; i < characteristic.value.length; i++) {
            NSLog(@"%x", bytes[i]);
            hwRevision = [hwRevision stringByAppendingFormat:@"0x%02x, ", bytes[i]];
        }
        
        [self.delegate didReadHardwareRevisionString:[hwRevision substringToIndex:hwRevision.length-2]];
    }
}

// Return the last write error  ONLY valid if the isBusy is False
- (ble_response_t)getTransactionError
{
    return read_error;
}

- (void)retryNow:(NSTimer *)expired
{
    NSLog(@"retrying: %@ >>>>>>>>>>>>> NOW >>>> " , commandToCamera);
    NSString *cameraCmd = (NSString *)expired.userInfo;
    [self retryOldCommand:cameraCmd];
}

@end

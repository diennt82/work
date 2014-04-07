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
@synthesize peripheral = _peripheral;
@synthesize delegate = _delegate;

@synthesize uartService = _uartService;
@synthesize rxCharacteristic = _rxCharacteristic;
@synthesize txCharacteristic = _txCharacteristic;
@synthesize hello_timer, isDisconnected;

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
    if (self = [super init])
    {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        _delegate = delegate;
    }
    return self;
}

- (void) didConnect
{
    [_peripheral discoverServices:@[self.class.uartServiceUUID, self.class.deviceInformationServiceUUID]];
    
    sequence = SEQUENCE_MIN;
    
    rx_buff = [[NSMutableData alloc] init];
    
    
    isDisconnected = NO;
    NSLog(@"Did start service discovery. start timer");
}

- (void) didDisconnect
{
    
    sequence = SEQUENCE_MIN;
    [rx_buff setLength: 0];
    self.isBusy = NO;
    
    if (self.hello_timer != nil && [self.hello_timer isValid])
    {
        [self.hello_timer invalidate];
        self.hello_timer = nil;
    }
    //invalidate time out
    if (_timeOutCommand && [_timeOutCommand isValid])
    {
        [_timeOutCommand invalidate];
        _timeOutCommand = nil;
    }

    self.isDisconnected = YES;
    
    NSLog(@"UART PERI: didDisconnect, stop timer ");
}

-(void) retryOldCommand:(NSString *) string
{
    commandToCamera = string;
    
    
    [rx_buff setLength:0]; // clear all backlog
    read_error = READ_ON_GOING;
    
    
    NSMutableData * data = [[NSMutableData alloc]init];
    [data appendBytes:string.UTF8String length:string.length];
    
    unsigned char null_char  [] = {0x00};
    
    [data appendBytes:(const void *)null_char length:1];
    NSLog(@"data is: %@", data);

    
    if ( [data length] > 20)
    {
        
        
        int remain_len = [data length];
        int data_idx = 0;
        
        int len_to_send ;
        NSData * chunk;
        NSRange range;
        
        while (remain_len > 0 )
        {
            len_to_send = (remain_len > 20)?20:remain_len;
            
            // Split in multiple chunks
            range = NSMakeRange(data_idx, len_to_send) ;
            chunk = [data subdataWithRange:range];
            
            if ((self.txCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
            {
                [self.peripheral writeValue: (NSData *) chunk forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
            }
            else if ((self.txCharacteristic.properties & CBCharacteristicPropertyWrite) != 0)
            {
                [self.peripheral writeValue:  (NSData *) chunk forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            else
            {
                NSLog(@"No write property on TX characteristic, %d.", self.txCharacteristic.properties);
            }
            
            remain_len -= len_to_send;
            data_idx  += len_to_send;
            
            
            NSLog(@"Finish writing %d", len_to_send);
        }
        
        
        
    }
    else
    {
        
        if ((self.txCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
        {
            [self.peripheral writeValue: (NSData *) data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if ((self.txCharacteristic.properties & CBCharacteristicPropertyWrite) != 0)
        {
            [self.peripheral writeValue:  (NSData *) data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else
        {
            NSLog(@"No write property on TX characteristic, %d.", self.txCharacteristic.properties);
        }
    }
    NSLog(@"Finish writing");
    
}


- (ble_response_t) flush
{
    if (self.isBusy == TRUE)
    {
        
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = TRUE;
    self.isFlushing = TRUE;
    retry_count =  0;
    
    
    //Purposely send empty command to flush the system
    [self retryOldCommand:@"01234567890123456"];
    
    
    return WRITE_SUCCESS;
    
}


- (ble_response_t) flush:(NSTimeInterval)time
{
    //    if (self.)
    _timeOutCommand = [NSTimer scheduledTimerWithTimeInterval:time
                                                       target:self
                                                     selector:@selector(receiveDataTimeOut:)
                                                     userInfo:nil
                                                      repeats:NO];
    if (self.isBusy == TRUE)
    {
        
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = TRUE;
    self.isFlushing = TRUE;
    retry_count =  0;
    
    
    //Purposely send empty command to flush the system
    [self retryOldCommand:@"01234567890123456"];
    
    
    return WRITE_SUCCESS;
    
}




- (void) send_hello:(NSTimer *) exp
{

    
    self.hello_timer = nil ;
    
    
    if (self.isBusy == TRUE)
    {
        
    
    }
    else
    {
        self.isBusy = TRUE;
        self.isFlushing = TRUE;
        retry_count =  0;
        
        
        //Purposely send empty command to flush the system
        [self retryOldCommand:@"hello_hello"];
        
    }
    return ;
    
}

- (ble_response_t) writeString:(NSString *) string
{
    
    
    if (self.isBusy == TRUE)
    {
        
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = TRUE;
    
    //Retry 10 times only if we hit the 0-len issue;
    retry_count =  10;
    
    
    [self retryOldCommand:string];
    
    
    return WRITE_SUCCESS;
    
}

- (ble_response_t) writeString:(NSString *) string withTimeOut:(NSTimeInterval) time
{
    
    
    if (self.hello_timer !=  nil && [self.hello_timer isValid])
    {
        [self.hello_timer invalidate];
        self.hello_timer = nil;
    }
    
    //Here it could be sending the hello... so what we can do is wait for this to be over..
    // UI thread may be blocked
    if (self.isBusy == TRUE)
    {
        
        NSLog(@"wait for a while ");
        
        NSDate * date;
        while (self.isBusy == TRUE)
        {
            date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
            
            [[NSRunLoop currentRunLoop] runUntilDate:date];
        }
        
        
        if (self.isDisconnected == YES)
        {
            NSLog(@"after waiting.. now disconnected ");
            return -1;
        }
        
        
    }
    timeout = time;
    _timeOutCommand = [NSTimer scheduledTimerWithTimeInterval:time
                                                       target:self
                                                     selector:@selector(receiveDataTimeOut:)
                                                     userInfo:nil
                                                      repeats:NO];
    
    if (self.isBusy == TRUE)
    {
        
        return WRITE_ERROR_OTHER_TRANSACTION_IN_PLACE;
    }
    
    self.isBusy = TRUE;
    
    //Retry 10 times only if we hit the 0-len issue;
    retry_count =  10;
    
    
    [self retryOldCommand:string];
    
    
    return WRITE_SUCCESS;
    
}

-(void) receiveDataTimeOut:(NSTimer *) timer
{

    
    /* when timeout - just simply resend */
#if 1
    //retry_count --;
    //if (retry_count > 0)
    {
        
        NSLog(@"retrying with timeout :%f & cmd is %@", timeout, commandToCamera);
        
        if ([commandToCamera isEqualToString:@"get_wifi_connection_state"] && (retry_count < 10))
        {
            //HACK
            _timeOutCommand = [NSTimer scheduledTimerWithTimeInterval: timeout
                                                               target:self
                                                             selector:@selector(receiveDataTimeOut:)
                                                             userInfo:nil
                                                              repeats:NO];
            
            
            //commandToCamera = @"get_version";
            
              NSLog(@"retrying with timeout :%@", commandToCamera);
            [self retryOldCommand:commandToCamera];
        }
        else
        {
            
            _timeOutCommand = [NSTimer scheduledTimerWithTimeInterval: timeout
                                                               target:self
                                                             selector:@selector(receiveDataTimeOut:)
                                                             userInfo:nil
                                                              repeats:NO];
            
            
            
            [self retryOldCommand:commandToCamera];
        }
    }
  //  else
#endif
//    {
//        //tired --- disconnect now
//        _timeOutCommand = nil;
//        self.isBusy = FALSE;
//        retry_count = -1;
//        if (self.delegate)
//        {
//            [self.delegate onReceiveDataError:READ_TIME_OUT forCommand:commandToCamera];
//        }
//    }
    
    

}
- (void) writeRawData:(NSData *) data
{
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering services: %@", error);
        return;
    }
    
    for (CBService *s in [peripheral services])
    {
        if ([s.UUID isEqual:self.class.uartServiceUUID])
        {
            NSLog(@"Found correct service");
            self.uartService = s;
            
            [self.peripheral discoverCharacteristics:@[self.class.txCharacteristicUUID, self.class.rxCharacteristicUUID] forService:self.uartService];
        }
        else if ([s.UUID isEqual:self.class.deviceInformationServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[self.class.hardwareRevisionStringUUID] forService:s];
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering characteristics: %@", error);
        return;
    }
    
    for (CBCharacteristic *c in [service characteristics])
    {
        if ([c.UUID isEqual:self.class.rxCharacteristicUUID])
        {
            NSLog(@"Found RX characteristic");
            self.rxCharacteristic = c;
            
            [self.peripheral setNotifyValue:YES forCharacteristic:self.rxCharacteristic];
        }
        else if ([c.UUID isEqual:self.class.txCharacteristicUUID])
        {
            NSLog(@"Found TX characteristic");
            self.txCharacteristic = c;
        }
        else if ([c.UUID isEqual:self.class.hardwareRevisionStringUUID])
        {
            NSLog(@"Found Hardware Revision String characteristic");
            [self.peripheral readValueForCharacteristic:c];
        }
    }
    
    
    NSLog(@"Found TX & RX characteristic");
    if (self.delegate != nil)
    {
        [self.delegate readyToTxRx];
    }
    
}

-(int) checkBufferForNullChar:(NSData*) data_buff
{
    
    BOOL found  = FALSE;
    
    //find the 1 00
    int i;
    char * data_ptr =(char * ) [data_buff bytes];
    for ( i=0 ; i < [data_buff length]; i++)
    {
        if ( data_ptr[i] ==0x01) //0x00
        {
            found = TRUE;
            break;
        }
        
    }
    
    
    if (found == FALSE)
    {
        i = -1;
    }
    
    return i;
}

-(int) checkBuffer:(NSData *) data_buff forSequence:(int) seq
{
    if ([data_buff length] < 20)
    {
        return -1;
    }
    
    BOOL found  = FALSE;
    
    //find the 20 00s
    char * data_ptr =(char * ) [data_buff bytes];
    int i;
    for ( i=20 ; i < [data_buff length]; i++)
    {
        if ( data_ptr[i] !=0x00  &&
            data_ptr[i-1] ==0x00   &&
            data_ptr[i-2] ==0x00   &&
            data_ptr[i-3] ==0x00  &&
            data_ptr[i-4] ==0x00   &&
            data_ptr[i-5] ==0x00   &&
            data_ptr[i-6] ==0x00   &&
            data_ptr[i-7] ==0x00   &&
            data_ptr[i-8] ==0x00  &&
            data_ptr[i-9] ==0x00   &&
            data_ptr[i-10] ==0x00   &&
            data_ptr[i-11] ==0x00   &&
            data_ptr[i-12] ==0x00   &&
            data_ptr[i-13] ==0x00  &&
            data_ptr[i-14] ==0x00   &&
            data_ptr[i-15] ==0x00   &&
            data_ptr[i-16] ==0x00   &&
            data_ptr[i-17] ==0x00   &&
            data_ptr[i-18] ==0x00  &&
            data_ptr[i-19] ==0x00 &&
            data_ptr[i-20] ==0x00
            )
        {
            //Found it
            
            found = TRUE;
            break;
            
            
            
        }
    }
    
    
    if (found)
    {
        
        NSLog(@"found a matching sequence :%x %x %x", data_ptr[i-1], data_ptr[i], data_ptr[i+1]);
        if (seq  == data_ptr[i] )
        {
            NSLog(@"found a matching sequence :%d", seq);
            
            return i;
        }
    }
    
    NSLog(@"No matching sequence %d", sequence);
    
    
    // check the seq
    
    return -1;
}


-(int) checkBufferFor02char:(NSData *) data_buff
{
    int last_index = -1;
    

    
    //find the 1 00
    int i;
    char * data_ptr =(char * ) [data_buff bytes];
    for ( i=0 ; i < [data_buff length]; i++)
    {
        if ( data_ptr[i] ==0x02)
        {
            last_index = i;
        }
        else
        {
            break;
        }

    }
    
    
    return last_index;
}

// ff ff 00 57
-(int) checkBufferForSpecialSequence:(NSData *) data_buff
{
    int last_index = -1;
    
    if ([data_buff length] < 4)
    {
        return last_index;
        
    }
    
    //find the 1 00
    int i;
    unsigned char * data_ptr =(unsigned char * ) [data_buff bytes];
    for ( i=0 ; i < [data_buff length]-3; i++)
    {
        if ( data_ptr[i] ==0xff &&
             data_ptr[i+1] == 0xff &&
             data_ptr[i+2]  ==  0x00 &&
             data_ptr[i+3]  == 0x57)
        {
            last_index = i;
            break;
        }
        else
        {
        }
        
    }
    
    
    return last_index;
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    
    NSLog(@"Received data on a characteristic.");
    
    if (characteristic == self.rxCharacteristic)
    {
        
        
        unsigned char * rcv_data = (unsigned char * ) [[characteristic value] bytes] ;
        
        
        NSString * log = @"";
        
        for (int i =0 ; i < [[characteristic value] length] -1; i ++)
        {
            log = [log stringByAppendingFormat:@"%02x ", rcv_data[i]];
            
        }
        NSLog(@"Raw:  %@" ,  log);
        
        int endblock_index =[[characteristic value] length]-1 ;
        
        for (int i =0 ; i < [[characteristic value] length]-2 ; i ++)
        {
            if (rcv_data[i] == 0x03 && rcv_data[i+1] == 0x00)
            {
                endblock_index = i;
                 NSLog(@"0x03 0x00 at  %d" ,  i);
                break;
            }
            
        }
        
        [rx_buff appendBytes:[[characteristic value] bytes] length: endblock_index  /*[characteristic value].length -1 */];
        
        /*  if the 0x0300 is in the middle, we still have some extra bytes  */
        if (endblock_index  < [[characteristic value] length]-2)
        {
            NSLog(@"after 0x03 0x00 there is  %d" ,  [characteristic value].length -1 -2 - endblock_index);
            [rx_buff appendBytes:[[characteristic value] bytes]+endblock_index+2 length:(  [characteristic value].length -1 -2 - endblock_index )];
        }

        int garbage_seq_index = [self checkBufferForSpecialSequence:rx_buff];
        if (garbage_seq_index != -1)
        {
#if 0
            NSLog(@">>> found some garbage code.. cut it away");
            NSRange range1 = NSMakeRange(garbage_seq_index,4);
            
            //remove some bytes..
            [rx_buff replaceBytesInRange:range1
                               withBytes:NULL
                                  length:0];
#else 
            // Force disconnect BLE
            NSLog(@">>> found some garbage code.. Disconnect BLE!!");
            [self receiveDataTimeOut:nil];
            
            return;
#endif
        }

        

        /* Find the end 0x01 char */
        
        int sequence_index = [self checkBufferForNullChar:rx_buff];
        
#if 0
        //For Step debug
        sequence_index = rx_buff.length-1;
#endif
        if (sequence_index  != -1)
        {
         
           
            int padding_index =[self checkBufferFor02char:rx_buff] ;
            //take the sub range starting from the latest index of 0x02 -
            NSRange range = NSMakeRange(padding_index+1, sequence_index-(padding_index+1));

            
          
            
            NSData *result_str = [rx_buff subdataWithRange:range];
            
            NSLog(@"Got enough data : %d",[result_str length]);
            
            
            NSString *string = [NSString stringWithUTF8String:[result_str bytes] ];
            //invalidate time out
            if (_timeOutCommand && [_timeOutCommand isValid])
            {
                [_timeOutCommand invalidate];
                _timeOutCommand = nil;
            }
            
            
            [self.delegate didReceiveData:string];
            
            //cut this string away
            range = NSMakeRange(0, sequence_index+1);
            [rx_buff replaceBytesInRange:range
                               withBytes:NULL
                                  length:0];
            
            
            
            read_error = READ_SUCCESS;
            
            self.isBusy = FALSE;
           
#if 1
            NSLog(@"start hello timer");
            
            if (self.hello_timer != nil)
            {
                [self.hello_timer invalidate];
                self.hello_timer = nil;
            }
            
            self.hello_timer  =  [NSTimer scheduledTimerWithTimeInterval:7.0
                                                             target:self
                                                           selector:@selector(send_hello:)
                                                           userInfo:nil
                                                            repeats:NO];
#endif

        }
        else
        {
            NSLog(@"Not enough data  yet");
            //Do nothing
        }
        
    }
    else if ([characteristic.UUID isEqual:self.class.hardwareRevisionStringUUID])
    {
        NSString *hwRevision = @"";
        const uint8_t *bytes = characteristic.value.bytes;
        for (int i = 0; i < characteristic.value.length; i++)
        {
            NSLog(@"%x", bytes[i]);
            hwRevision = [hwRevision stringByAppendingFormat:@"0x%02x, ", bytes[i]];
        }
        
        [self.delegate didReadHardwareRevisionString:[hwRevision substringToIndex:hwRevision.length-2]];
    }
}

//Return the last write error  ONLY valid if the isBusy is False
-(ble_response_t) getTransactionError
{
    return read_error;
}

-(void)retryNow:(NSTimer * ) expired
{
    NSString * camera_cmd =  (NSString *)expired.userInfo;
    
    NSLog(@"retrying: %@ >>>>>>>>>>>>> NOW >>>> " , commandToCamera);
    [self retryOldCommand:camera_cmd];
    
}

@end

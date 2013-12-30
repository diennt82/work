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
    
    
    NSLog(@"Did start service discovery.");
}

- (void) didDisconnect
{
    
}

-(void) retryOldCommand:(NSString *) string
{
    commandToCamera = string;
    
    
    [rx_buff setLength:0]; // clear all backlog
    read_error = READ_ON_GOING;
    
#if 1
    
    if (sequence >= 0x7f)
        sequence = SEQUENCE_MIN;
    
    char len[] = {0,0,0};
    len[0] = sequence;
    len[1] = (string.length & 0xFF00) >> 8;
    len[2] = string.length & 0x00FF;
    
    
    
    NSMutableData * data = [[NSMutableData alloc]initWithBytes:len length:3];
    
    [data appendBytes:string.UTF8String length:string.length];
    
#else
    
    NSData *data = [NSData dataWithBytes:string.UTF8String length:string.length];
#endif
    
    if ( [data length] > 20)
    {
        
        int numberOfLf = ([data length] + 10)/20;
        
        int new_len = [data length] - 3 + numberOfLf ;
        
        len[0] = sequence;
        len[1] = (new_len & 0xFF00) >> 8;
        len[2] = (new_len & 0x00FF);
        NSRange len_range = NSMakeRange(0, 3);
        
        [data replaceBytesInRange:len_range withBytes:len length:3];
        
        
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
        
        
        [rx_buff appendBytes:[[characteristic value] bytes] length: [characteristic value].length -1];
        

        
        
        int sequence_index = [self checkBuffer:rx_buff forSequence:sequence];
        int total_data_len = [rx_buff length];
        
        if (sequence_index != -1  && (sequence_index +3) <= total_data_len) //we found the start of new sequence
        {
            
            //Need to check if we have rcved enough bytes
            unsigned char * len_ptr;
            
            len_ptr =  (( unsigned char *)[rx_buff bytes] )+ sequence_index +1;
            int len =  (len_ptr[0] << 8) + len_ptr[1];
            
           
            
            NSLog(@"data len is : %d ", len );
            
            NSLog(@"data start:%d len is : %d total: %d" ,  sequence_index, len, total_data_len);
            
            if (len >  0)
            {
                
                
                if ( (len + sequence_index + 3)  <=   total_data_len)
                {
                    //we do have enough data
                    NSRange range = NSMakeRange(sequence_index + 3, len);
                    NSData *result_str = [rx_buff subdataWithRange:range];
                    
                    NSLog(@"Got enough data : %d",[result_str length]);
                    
                    
                    NSString *string = [NSString stringWithUTF8String:[result_str bytes] ];
                    [self.delegate didReceiveData:string];
                    
                    //cut this string away
                    range = NSMakeRange(0, len + sequence_index + 3);
                    [rx_buff replaceBytesInRange:range
                                       withBytes:NULL
                                          length:0];

                    
                    
                    read_error = READ_SUCCESS;
                    
                    self.isBusy = FALSE;
                }
                else
                {
                    NSLog(@"Not enough data  yet");
                    //Do nothing
                }
                
            }
            else
            {
                
                // clean up & Retry
                NSLog(@"Before clean up : %d throw %d", [rx_buff length], len + sequence_index + 3);
                //cut this string away
                NSRange range ;
                range = NSMakeRange(0, len + sequence_index + 1);
                [rx_buff replaceBytesInRange:range
                                   withBytes:NULL
                                      length:0];
                
                NSLog(@"after clean up : %d", [rx_buff length]);
                
                read_error = READ_ERROR_ZERO_LEN;
                //retry
                
                if (retry_count -- > 0)
                {
                
               [ NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(retryNow:)
                                               userInfo:commandToCamera repeats:NO];
                }
                else
                {
                    NSLog(@"ERROR: 0-len issue, no more retry, returning");
                    self.isBusy = FALSE;
                    
                    [self.delegate onReceiveDataError:read_error forCommand:commandToCamera];
                }

            }
            
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

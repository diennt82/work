//

//  BLEManageConnect.m

//  BlinkHD_ios

//

//  Created by Jason Lee on 20/12/13.

//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.

//



#import "BLEManageConnect.h"



@implementation BLEManageConnect

@synthesize cm = _cm;

@synthesize uartPeripheral = _uartPeripheral;
@synthesize myPeripheral = _myPeripheral;
@synthesize listBLEs = _listBLEs;
@synthesize state = _state;

@synthesize isOnBLE = _isOnBLE;
@synthesize delegate = _delegate;


+ (BLEManageConnect *) getInstanceBLE
{
    static BLEManageConnect *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLEManageConnect alloc] init];
    });
    return _sharedInstance;
}

-(id) init

{
    self = [super init];
    if (self) {
        _state = IDLE;
        _isOnBLE = NO;
        _listBLEs = [[NSMutableArray alloc] init];
        _uartPeripheral = [[UARTPeripheral alloc] initWithPeripheral:nil delegate:self];
        _cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}



- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    NSLog(@"Error code is %d and command  %@***************************", error_code, commandToCamera);
    [self.delegate onReceiveDataError:error_code forCommand:commandToCamera];
}
-(void) dealloc
{
    [_myPeripheral release];
    _myPeripheral = nil;
    [_cm release];
    _cm = nil;
    [_listBLEs release];
    _listBLEs = nil;
    [super dealloc];
}

-(UARTPeripheral *) getUARTtPeripheral
{
    return _uartPeripheral;
}



/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    scanMode = SCAN_FOR_ANY_DEVICE;
    
    //    scanForPeripheralsWithServices:@[UARTPeripheral.uartServiceUUID]
    if (_cm.state == CBCentralManagerStatePoweredOn)
    {
        NSLog(@"Scanning started");
        [_cm scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
    }
    else{
        NSLog(@"can't scan");
    }
    [self.listBLEs removeAllObjects];
    
}

- (void)reScan
{
    [self.uartPeripheral didDisconnect];
    if (_cm)
    {
        [_cm release];
        _cm = nil;
        _cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
}



-(void) reScanForPeripheral:(CBUUID *) dev_service_id
{
    //TODO: Check? Whether BLE service id is different for each device OR the same for All Device
    
    //HACK!!!
    self.isOnBLE = YES;
    scanMode = SCAN_FOR_SINGLE_DEVICE;
    
    [_cm scanForPeripheralsWithServices:@[dev_service_id]
                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
    
}

-(void) disconnect
{
    
    if ([_uartPeripheral.peripheral isConnected])
    {
        [[BLEManageConnect getInstanceBLE].cm cancelPeripheralConnection:_uartPeripheral.peripheral];
    }
    
    
}


+ (ConnectionState)checkStatusConnectBLE
{
    return [BLEManageConnect getInstanceBLE].state;
}



/**
 * Call this when select a BLE in table to connect
 */
- (void)connectToBLEWithPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connect to BLE with name is %@", peripheral.name);
    [_cm stopScan];
    self.myPeripheral = peripheral;
    self.uartPeripheral = [[UARTPeripheral alloc] initWithPeripheral:self.myPeripheral delegate:self];
    [_cm connectPeripheral:self.myPeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
}



#pragma mark - Callbacks

- (void) didReceiveData:(NSString *) string
{
    [self.delegate didReceiveData:string];
}

- (void) didReceiveRawData:(NSData *)data
{
    
}

-(void) readyToTxRx
{
    //Ready or connected
    self.state = CONNECTED;
    
    //TODO: pass the correct service id
    [self.delegate  didConnectToBle:nil];
   
}


- (void)didDisConnect
{
    NSLog(@"Disconnect peripheral %@", self.uartPeripheral.peripheral.name);
    if ([_uartPeripheral.peripheral isConnected])
    {
        [[BLEManageConnect getInstanceBLE].cm cancelPeripheralConnection:_uartPeripheral.peripheral];
    }
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        NSLog(@"BLE IS ON ");
        self.isOnBLE = YES;
        [self scan];
    }
    else
    {
        NSLog(@"BLE not power on");
        self.isOnBLE = NO;
    }
}


- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI

{
    
    
    if (scanMode == SCAN_FOR_ANY_DEVICE)
    {
        NSLog(@"Did discover peripheral name %@ and peripheral is %@", peripheral.name, peripheral);
        
        if (![self.listBLEs containsObject:peripheral])
        {
            [self.listBLEs addObject:peripheral];
            [self.delegate didReceiveBLEList:self.listBLEs];
        }
    }
    else if ( scanMode == SCAN_FOR_SINGLE_DEVICE)
    {
        
        NSLog(@"Did discover Single device :  name %@ and peripheral is %@", peripheral.name, peripheral);
        NSLog(@"Connect again!!");
        
        //called if found that service id?
        [self connectToBLEWithPeripheral:peripheral];
        
    }
}
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect peripheral %@", peripheral.name);
  
    if ([_uartPeripheral.peripheral isEqual:peripheral])
    {
        [_uartPeripheral didConnect];
        
    }
  
    
   
    
}





/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error

{
    
    NSLog(@"didDisconnectPeripheral %@", peripheral.name);
    self.myPeripheral = peripheral;
    self.state = IDLE;
    self.isOnBLE = NO;
    
    [self.delegate bleDisconnected];
   
    
    
    if ([self.uartPeripheral.peripheral isEqual:self.myPeripheral])
        
    {
        
        
        [self.uartPeripheral didDisconnect];
        [self didDisConnect];
        
        
        
    }
}



@end


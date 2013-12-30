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

- (void) didReceiveData:(NSString *) string
{
    [self.delegate didReceiveData:string];
}

- (void) didReceiveRawData:(NSData *)data
{
    
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

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        self.isOnBLE = NO;
        return;
    }
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
//    scanForPeripheralsWithServices:@[UARTPeripheral.uartServiceUUID]
    if (_cm != nil)
    {
        [_cm release];
        _cm = nil;
    }
    _cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [_cm scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
    [self.listBLEs removeAllObjects];
    NSLog(@"Scanning started");
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI

{
    NSLog(@"Did discover peripheral name %@ and peripheral is %@", peripheral.name, peripheral);
    if (![self.listBLEs containsObject:peripheral])
    {
        [self.listBLEs addObject:peripheral];
        [self.delegate didReceiveBLEList:self.listBLEs];
    }
}
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect peripheral %@", peripheral.name);
    //Ready or connected
    self.state = CONNECTED;
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
    self.state = IDLE;
    if ([self.uartPeripheral.peripheral isEqual:peripheral])
        
    {
        [self didDisConnect];
    }
}

+ (ConnectionState)checkStatusConnectBLE
{
    return [BLEManageConnect getInstanceBLE].state;
}

- (void)didDisConnect
{
    NSLog(@"Disconnect peripheral %@", self.uartPeripheral.peripheral.name);
    if ([_uartPeripheral.peripheral isConnected])
    {
        [[BLEManageConnect getInstanceBLE].cm cancelPeripheralConnection:_uartPeripheral.peripheral];
    }
}

/** 
 * Call this when select a BLE in table to connect
 */
- (void)connectToBLEWithPeripheral:(CBPeripheral *)peripheral
{
    [_cm stopScan];
    self.myPeripheral = peripheral;
    self.uartPeripheral = [[UARTPeripheral alloc] initWithPeripheral:self.myPeripheral delegate:self];
    [_cm connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
}

@end


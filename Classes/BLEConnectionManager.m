//
//  BLEConnectionManager.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 20/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "BLEConnectionManager.h"

@interface BLEConnectionManager ()

@property (nonatomic) int scanMode;

@end

@implementation BLEConnectionManager

#pragma mark - Public static methods

+ (BLEConnectionManager *)instanceBLE
{
    static BLEConnectionManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLEConnectionManager alloc] init];
    });
    
    return _sharedInstance;
}

+ (ConnectionState)checkStatusConnectBLE
{
    return BLEConnectionManager.instanceBLE.state;
}

#pragma mark - Lifecycle methods

- (id)init
{
    self = [super init];
    if (self) {
        _state = IDLE;
        _isOnBLE = NO;
        _needReconnect = YES;
        _listBLEs = [[NSMutableArray alloc] init];
        _uartPeripheral = [[UARTPeripheral alloc] initWithPeripheral:nil delegate:self];
        _cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}

#pragma mark - Public instance methods

- (void)reinit
{
    _cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

/*
 * Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    self.scanMode = SCAN_FOR_ANY_DEVICE;
    
    if (_cm) {
        [_cm stopScan];
    }
    
    //    scanForPeripheralsWithServices:@[UARTPeripheral.uartServiceUUID]
    
    if ( _cm.state == CBCentralManagerStatePoweredOn ) {
        DLog(@"Scanning started");
        [_cm scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    }
    else {
        DLog(@"can't scan");
    }
    
    [_listBLEs removeAllObjects];
}

- (void)reScan
{
    [self.uartPeripheral didDisconnect];
    if (_cm) {
        _cm = nil;
        _cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
}

- (void)stopScanBLE
{
    DLog(@"Stop scanning!!");
    [self.cm stopScan];
}

- (void)reScanForPeripheral:(CBUUID *)devServiceId
{
    //TODO: Check? Whether BLE service id is different for each device OR the same for All Device
    
    //HACK!!!
    self.isOnBLE = YES;
    self.scanMode = SCAN_FOR_SINGLE_DEVICE;
    
    [_cm scanForPeripheralsWithServices:@[devServiceId]
                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
}

-(void) disconnect
{
    if (_uartPeripheral.peripheral.state == CBPeripheralStateConnected ) {
        [BLEConnectionManager.instanceBLE.cm cancelPeripheralConnection:_uartPeripheral.peripheral];
    }
}

/*
 * Call this when select a BLE in table to connect
 */
- (void)connectToBLEWithPeripheral:(CBPeripheral *)peripheral
{
    DLog(@"Connect to BLE with name is %@", peripheral.name);
    
    self.state = CONNECTING;
    self.uartPeripheral = [[UARTPeripheral alloc] initWithPeripheral:peripheral delegate:self];
    
    [_cm connectPeripheral:_uartPeripheral.peripheral
                   options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
}

#pragma mark - Callbacks

- (void)didReceiveData:(NSString *)string
{
    if ( _delegate ) {
        [_delegate didReceiveData:string];
    }
}

- (void)didReceiveRawData:(NSData *)data
{
    DLog(@"BLEManager - didReceiveRawData: %@", data);
}

- (void)onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    DLog(@"Error code is %d and command  %@***************************", error_code, commandToCamera);
    
    if (error_code == READ_TIME_OUT) {
        /*20140402_stephen request: dont disconnect, just re-send the command*/
        //[self disconnect];
    }
    else {
        if ( _delegate ) {
            [_delegate onReceiveDataError:error_code forCommand:commandToCamera];
        }
    }
}

-(void) readyToTxRx
{
    //Ready or connected
    self.state = CONNECTED;
    
    // pass the correct service id
    if ( _delegate ) {
        [_delegate didConnectToBle:nil];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        DLog(@"BLE IS ON ");
        self.isOnBLE = YES;
        [self scan];
    }
    else {
        DLog(@"BLE not power on");
        self.isOnBLE = NO;
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ( _scanMode == SCAN_FOR_ANY_DEVICE ) {
        if ([peripheral.name hasPrefix:@"MBP83"] ||
            [peripheral.name hasPrefix:@"CameraHD-0083"] ||
            [peripheral.name hasPrefix:@"CameraHD-0836"]  ||
            [peripheral.name hasPrefix:@"CameraHD-0854"] ||
            [peripheral.name hasPrefix:@"CameraHD-0085"])
        {
            DLog(@"Did discover peripheral name %@ and peripheral is %@", peripheral.name, peripheral);
            
            if ( ![_listBLEs containsObject:peripheral] ) {
                [_listBLEs addObject:peripheral];
                
                if ( _delegate ) {
                    [_delegate didReceiveBLEList:_listBLEs];
                }
                else {
                    DLog(@"BLE manager - didDiscoverPeripheral - self.delegate == nil");
                }
            }
            else {
                DLog(@"BLE manager - didDiscoverPeripheral - list contains peripheral");
            }
        }
    }
    else if ( _scanMode == SCAN_FOR_SINGLE_DEVICE ) {
        DLog(@"Did discover Single device :  name %@ and peripheral is %@", peripheral.name, peripheral);
        DLog(@"Connect again!!");
        
        //called if found that service id?
        [self connectToBLEWithPeripheral:peripheral];
    }
    else {
        DLog(@"BLE manager - didDiscoverPeripheral - scanMode: %d", _scanMode);
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    DLog(@"Did connect peripheral %@", peripheral.name);
    if ([_uartPeripheral.peripheral isEqual:peripheral]) {
        [_uartPeripheral didConnect];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DLog(@" FailToConnectPeripheral %@ with error: %@", peripheral.name , error.description);
    self.state = DISCONNECTED;
}

/*
 Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DLog(@"didDisconnectPeripheral %@ with error: %@", peripheral.name , error.description);
    
    self.state = DISCONNECTED;
    self.isOnBLE = NO;
    
    if ( _delegate) {
        if ([_uartPeripheral.peripheral isEqual:peripheral]) {
            [_uartPeripheral didDisconnect];
            [self disconnect];
        }
        
        //Maybe blocking sometimes
        [_delegate bleDisconnected];
    }
    else {
        if ([_uartPeripheral.peripheral isEqual:peripheral]) {
            [_uartPeripheral didDisconnect];
            [self disconnect];
        }
        
        if ( _needReconnect ) {
            DLog(@" delegate = nil, rescan myself");
            [self reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
        }
    }
}

// Just Clean a warning!
- (void)didConnect
{
    
}

@end


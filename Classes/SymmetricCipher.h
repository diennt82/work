
//
//  SymmetricCipher.h
//  MBP_ios
//
//  Created by NxComm on 7/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//


#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <crypto.h>
#include <openssl/aes.h>

@interface SymmetricCipher : NSObject {

}

+ (NSData *)AESEncryptWithKey:(NSString *)key data:(NSData*) input; 
+ (NSData *)_AESEncryptWithKey:(NSString *)key data:(NSData*) input; 
+ (NSData *)_AESDecryptWithKey:(NSString *)key data:(NSData*) input; 

+ (NSData *)AESDecryptWithKey:(NSString *)key;
@end

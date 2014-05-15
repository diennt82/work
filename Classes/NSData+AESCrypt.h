//
//  NSData+AESCrypt.h
//
//  AES128Encryption + Base64Encoding
//

#import <Foundation/Foundation.h>

@interface NSData (AESCrypt)

+(NSData*) gzipData: (NSData*)pUncompressedData;

- (NSData *)AES128EncryptWithKey:(NSString *)key;

- (NSString *)base64Encoding;

@end

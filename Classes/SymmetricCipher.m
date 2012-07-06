//
//  SymmetricCipher.m
//  MBP_ios
//
//  Created by NxComm on 7/4/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "SymmetricCipher.h"
#import "NSData+Base64.h"


@implementation SymmetricCipher

static const uint8_t iv[16] = {0x0a, 0x01, 0x02, 0x03, 0x04, 0x0b, 0x0c, 0x0d, 
						0x0a, 0x01, 0x02, 0x03, 0x04, 0x0b, 0x0c, 0x0d };


+(NSData *) _AESEncryptWithKey:(NSString *)base64key data:(NSData *)input
{
	NSData *keyData =  [NSData dataFromBase64String:base64key ];
	AES_KEY aes_key;
	unsigned int num = 0; 
	
	int ret ;
	
	ret = AES_set_encrypt_key((uint8_t *) [keyData bytes], 128, &aes_key);
	
	if (ret != 0 )
    {
		NSLog(@"set KEy error: %d", ret); 
		return nil;
	}
	
	int  dataLength = [input length];
	size_t bufferSize = dataLength + 16;
	uint8_t *buffer = malloc(bufferSize);
	uint8_t ecount[16]; 
	bzero(ecount, 16);
	
	 uint8_t _iv[16] = {0x0a, 0x01, 0x02, 0x03, 0x04, 0x0b, 0x0c, 0x0d, 
		0x0a, 0x01, 0x02, 0x03, 0x04, 0x0b, 0x0c, 0x0d };
	
	AES_ctr128_encrypt((uint8_t *)[input bytes], buffer, dataLength, &aes_key, _iv, ecount, &num);
		
	return [NSData dataWithBytesNoCopy:buffer length:dataLength];
}



+(NSData *) _AESDecryptWithKey:(NSString *)base64key data:(NSData *)input
{
	NSData *keyData =  [NSData dataFromBase64String:base64key ];
	AES_KEY aes_key;
	unsigned int num = 0; 
	
	int ret ;
	
	ret = AES_set_encrypt_key((uint8_t *) [keyData bytes], 128, &aes_key);
	
	if (ret != 0 )
    {
		NSLog(@"set KEy error: %d", ret); 
		return nil;
	}
	
	int  dataLength = [input length];
	size_t bufferSize = dataLength + 16;
	uint8_t *buffer = malloc(bufferSize);
	uint8_t ecount[16]; 
	bzero(ecount, 16);
	num = 0; 
	uint8_t _iv[16] = {0x0a, 0x01, 0x02, 0x03, 0x04, 0x0b, 0x0c, 0x0d, 
		0x0a, 0x01, 0x02, 0x03, 0x04, 0x0b, 0x0c, 0x0d};
	

	
	AES_ctr128_encrypt((uint8_t *)[input bytes], buffer, dataLength, &aes_key, _iv, ecount, &num);

	

	
	return [NSData dataWithBytesNoCopy:buffer length:dataLength];
}



////// NOT USED
+ (NSData *)AESEncryptWithKey:(NSString *)base64key data:(NSData*) input 
{
	
	NSData *keyData =  [NSData dataFromBase64String:base64key ];
	//char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
	//bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)

	// fetch key data
	//[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [input length];
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
	
    if(diff > 0)
    {
        newSize = dataLength + diff;
    }
	
    char dataPtr[newSize];
    memcpy(dataPtr, [input bytes], [input length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x20;
    }
	
	
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
										  kCCAlgorithmAES128,
										  0x0000, //kCCOptionPKCS7Padding,
										  [keyData bytes], 
										  kCCKeySizeAES128,
										  iv/* initialization vector (optional) */,
										  dataPtr, sizeof(dataPtr), /* input */
										  //[input bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	
	NSLog(@"encrypt failed : %d",cryptStatus);
	
	free(buffer); //free the buffer;
	return nil;
}

//// NOT USED
+ (NSData *)AESDecryptWithKey:(NSString *)base64key data:(NSData*)input
{
	NSData *keyData =  [NSData dataFromBase64String:base64key ];
	
		
	//char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
	//bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	//[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [input length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
										  kCCOptionECBMode,
										  [keyData bytes], kCCKeySizeAES128,
										  iv /* initialization vector (optional) */,
										  [input bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
	
}

@end

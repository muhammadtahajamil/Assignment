//
//  WrappingKeyRequester.m
//  FolderLock
//
//  Created by MacBook on 06/08/2024.
//

#import <Foundation/Foundation.h>
#import "WrappingKeyRequester.h"
#import "WrappingKeyCache.h"
#import "CryptLib.h"


@implementation WrappingKeyRequester : NSObject

+ (NSString *)getWrappingKeyForUserId:(NSString *)userId folderId:(NSString *)folderId {
    WrappingKeyCacheValue *wrappingKeyCacheValue = [WrappingKeyCache getWithUserId:userId folderId:folderId];

    if (wrappingKeyCacheValue != nil) {
        if ([wrappingKeyCacheValue.status isEqualToString:@"Success"]) {
            return wrappingKeyCacheValue.encWrappingKey;
        }
        // Although cache exists but for the same userId & folderId the status can be following so we are not calling API again:
        // 1: Invalid User/Folder
        // 2: Invalid Parameters
        // 3: Deprecated
        return @"";
    }
    
    // Get Wrapping Key from API
    NSString *jsonString = [self callWrappingKeyAPI:userId folderId:folderId];
    
    if ([jsonString isEqualToString:@"deprecated"]) {
        WrappingKeyCacheValue *cacheValue = [[WrappingKeyCacheValue alloc] initWithStatus:@"deprecated" encWrappingKey:@""];
        [WrappingKeyCache putWithUserId:userId folderId:folderId cacheValue:cacheValue];
        return @"";
    }
    
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error) {
        return @"";
    } else {
        // Put wrapping key in the cache
        NSString* status = jsonDict[@"status"];
        NSString* encWrappingKey = jsonDict[@"wrappingKey"];
        
        WrappingKeyCacheValue *cacheValue = [[WrappingKeyCacheValue alloc] initWithStatus:status encWrappingKey:encWrappingKey];
        [WrappingKeyCache putWithUserId:userId folderId:folderId cacheValue:cacheValue];
        
        if (![status isEqualToString:@"Success"]) {
            return @"";
        }
        
        return encWrappingKey;
    }
}

+ (NSString *)callWrappingKeyAPI:(NSString *)userId folderId:(NSString *)folderId {
    
    NSDictionary *jsonDictionary = @{
        @"userId": userId,
        @"folderId": folderId
    };
    
    // Convert dictionary to JSON data
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
    
    if (!jsonData) {
        // Handle JSON creation error
        NSLog(@"Error creating JSON data: %@", error);
        return @"";
    }
    
    // Convert JSON data to string (for logging or debugging purposes)
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        
//    NSString *rnStr = [HelperClass randomStringWithLength:15];
//    CryptLib *c = [[CryptLib alloc] init];
//    NSString *cipherText = [c encryptPlainTextRandomIVWithPlainText:jsonString key:rnStr];
//    
//    NSMutableArray *arr = [NSMutableArray array];
//    int j = 0;
//    for (int i = 0; i < [cipherText length]; i++) {
//        if (i == 8 && j == 1) {
//            j = j + 1;
//            i = i - 1;
//            for (int k = 0; k < [rnStr length]; k++) {
//                NSString *ch2 = [rnStr substringWithRange:NSMakeRange(k, 1)];
//                [arr addObject:ch2];
//            }
//        } else {
//            NSString *ch = [cipherText substringWithRange:NSMakeRange(i, 1)];
//            [arr addObject:ch];
//            if (i == 7) {
//                j = j + 1;
//            }
//        }
//    }
//    
//    NSString *updatedStr = [arr componentsJoinedByString:@""];
//    
//    NSMutableString *newStr = [NSMutableString string];
//    
//    NSString *url1 = [HelperClass globalBaseUrl:@"readSharingStatus.php"];
//    
//    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url1]];
//    [urlReq setHTTPMethod:@"POST"];
//    NSData *dt = [updatedStr dataUsingEncoding:NSUTF8StringEncoding];
//    [urlReq setHTTPBody:dt];
//    
//    // Use dispatch_group for synchronous-like behavior
//    __block NSData *responseData = nil;
//    __block NSURLResponse *response = nil;
//    __block NSError *responseError = nil;
//    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    config.URLCache = nil;
//    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable responseObj, NSError * _Nullable error) {
//        responseData = data;
//        response = responseObj;
//        responseError = error;
//        
//        // Signal the semaphore to indicate that the task is complete
//        dispatch_semaphore_signal(semaphore);
//    }];
//    
//    [dataTask resume];
//    
//    // Wait for the task to complete
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    
//    if (responseError) {
//        // Handle error
//        return @"";
//    } else {
//        NSString *newStr2 = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        [newStr appendString:newStr2];
//        
//        NSString *decStr = newStr2;
//        CryptLib *c = [[CryptLib alloc] init];
//        NSMutableArray *arrDecStr = [NSMutableArray array];
//        NSMutableArray *arrKey = [NSMutableArray array];
//        for (int i = 0; i < [decStr length]; i++) {
//            if (i == 8) {
//                for (int j = 0; j <= 14; j++) {
//                    NSString *ch = [decStr substringWithRange:NSMakeRange(i, 1)];
//                    [arrKey addObject:ch];
//                    i = i + 1;
//                }
//                i = i - 1;
//            } else {
//                NSString *ch = [decStr substringWithRange:NSMakeRange(i, 1)];
//                [arrDecStr addObject:ch];
//            }
//        }
//        
//        NSString *ky = [arrKey componentsJoinedByString:@""];
//        NSString *newDecStr = [arrDecStr componentsJoinedByString:@""];
//        NSString *apiResponse = [c decryptCipherTextRandomIVWithCipherText:newDecStr key:ky];
//        
//        if (apiResponse == nil) {
            return @"";
//        }else{
//            return apiResponse;
//        }
//    }
}

@end


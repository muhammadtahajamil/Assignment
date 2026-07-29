//
//  WrappingKeyCache.m
//  FolderLock
//
//  Created by MacBook on 06/08/2024.
//

#import <Foundation/Foundation.h>

#import "WrappingKeyCache.h"

@interface WrappingKeyCache ()

@property (class, nonatomic, strong, readonly) NSMutableDictionary<NSString *, WrappingKeyCacheValue *> *cache;

@end

@implementation WrappingKeyCache

static NSMutableDictionary<NSString *, WrappingKeyCacheValue *> *_cache = nil;

+ (void)initialize {
    if (self == [WrappingKeyCache class]) {
        _cache = [NSMutableDictionary dictionary];
    }
}

+ (NSMutableDictionary<NSString *, WrappingKeyCacheValue *> *)cache {
    return _cache;
}

+ (void)putWithUserId:(NSString *)userId folderId:(NSString *)folderId cacheValue:(WrappingKeyCacheValue *)cacheValue {
    NSString *key = [self generateCacheKeyWithUserId:userId folderId:folderId];
    @synchronized (self) {
        _cache[key] = cacheValue;
    }
}

+ (WrappingKeyCacheValue *)getWithUserId:(NSString *)userId folderId:(NSString *)folderId {
    NSString *key = [self generateCacheKeyWithUserId:userId folderId:folderId];
    @synchronized (self) {
        return _cache ? _cache[key] : nil;
    }
}

+ (NSString *)generateCacheKeyWithUserId:(NSString *)userId folderId:(NSString *)folderId {
    return [userId stringByAppendingString:folderId];
}

+ (void)clearCache{
    if (_cache){
        [_cache removeAllObjects];
    }
}

@end


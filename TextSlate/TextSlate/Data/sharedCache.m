//
//  sharedCache.m
//  Knit
//
//  Created by Anjaly Mehla on 2/6/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "sharedCache.h"

static sharedCache *sharedInstance;


@interface sharedCache()

@property (strong,nonatomic) NSCache *imageCache;

@end

@implementation sharedCache
+ (sharedCache*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[sharedCache alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)cacheImage:(UIImage*)image forKey:(NSString*)key {
    [self.imageCache setObject:image forKey:key];
}

- (UIImage*)getCachedImageForKey:(NSString*)key {
    return [self.imageCache objectForKey:key];
}
@end

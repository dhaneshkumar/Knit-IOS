//
//  sharedCache.h
//  Knit
//
//  Created by Anjaly Mehla on 2/6/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<UIKit/UIKit.h>

@interface sharedCache : NSObject

+ (sharedCache*)sharedInstance;

// set
- (void)cacheImage:(UIImage*)image forKey:(NSString*)key;
// get
- (UIImage*)getCachedImageForKey:(NSString*)key;

@end

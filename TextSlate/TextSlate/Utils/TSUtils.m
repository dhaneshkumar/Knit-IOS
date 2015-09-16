//
//  TSUtils.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation TSUtils

+(void) applyRoundedCorners:(UIButton *)button {
    CALayer *layer = button.layer;
    [layer setCornerRadius:3.0f];
}

+(NSString*)safe_string:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    return @"";
}

+(int)safe_int:(id) object {
    if ([object respondsToSelector:@selector(intValue)]) {
        return [object intValue];
    }
    return 0;
}

+(CGFloat)getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}

+(CGFloat)getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    return screenWidth;
}

+(float)getOSVersion {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(NSString *)getFileTypeFromFileName:(NSString *)fileName {
    NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    if(range.location != NSNotFound) {
        NSString *extension = [fileName substringFromIndex:range.location+1];
        extension = [extension lowercaseString];
        
        if([extension isEqualToString:@"pdf"]) {
            return @"pdf";
        }
        else if([extension hasPrefix:@"pp"]) {
            return @"presentation";
        }
        else if([extension hasPrefix:@"xl"]) {
            return @"sheet";
        }
        else if([extension hasPrefix:@"do"] || [extension isEqualToString:@"word"] || [extension isEqualToString:@"rtf"]) {
            return @"document";
        }
        else if([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"]) {
            return @"image";
        }
        else {
            return @"others";
        }
    }
    else {
        return @"others";
    }
}


+(NSString *)createURL:(NSString *)imageURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *urlString = [paths firstObject];
    urlString = [urlString stringByAppendingPathComponent:@"Images"];
    urlString = [urlString stringByAppendingPathComponent:urlString];
    return urlString;
}

@end

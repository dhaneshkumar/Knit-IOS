//
//  TSUtils.m
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import "TSUtils.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

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
        NSString * UTI = (__bridge NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
        NSString *type = (__bridge NSString *)MIMEType;
        if([type hasPrefix:@"video"]) {
            return @"video";
        }
        else if([type hasPrefix:@"audio"]) {
            return @"audio";
        }
        else if([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"png"]) {
            return @"image";
        }
        else if([extension isEqualToString:@"pdf"]) {
            return @"pdf";
        }
        else if([extension hasPrefix:@"pp"]) {
            return @"slides";
        }
        else if([extension hasPrefix:@"xl"]) {
            return @"sheet";
        }
        else if([extension hasPrefix:@"do"] || [extension isEqualToString:@"word"] || [extension isEqualToString:@"rtf"]) {
            return @"doc";
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
    NSCharacterSet *slashes = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    imageURL = [[imageURL componentsSeparatedByCharactersInSet: slashes] componentsJoinedByString: @"_"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *urlString = [paths firstObject];
    urlString = [urlString stringByAppendingPathComponent:imageURL];
    return urlString;
}

+(void)playAudio:(NSString *)path {
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    [audioPlayer play];
}


+(void)playVideo:(NSString *)path controller:(UIViewController *)parentController {
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:path]];
    [parentController presentViewController:moviePlayer animated:NO completion:nil];
}

@end

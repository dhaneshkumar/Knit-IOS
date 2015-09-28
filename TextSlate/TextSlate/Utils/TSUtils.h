//
//  TSUtils.h
//  TextSlate
//
//  Created by Ravi Vooda on 11/21/14.
//  Copyright (c) 2014 Ravi Vooda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface TSUtils : NSObject

+(void) applyRoundedCorners:(UIButton*)button;

+(NSString *) safe_string:(id) object;

+(int) safe_int:(id) object;

+(CGFloat) getScreenHeight;

+(CGFloat) getScreenWidth;

+(float) getOSVersion;

+(NSString *)getFileTypeFromFileName:(NSString *)fileName;

+(NSString *)createURL:(NSString *)imageURL;

+(void)playAudio:(NSString *)path audioPlayer:(AVAudioPlayer *)audioPlayer;

+(void)playVideo:(NSString *)path controller:(UIViewController *)parentController;

+(BOOL)isChutiyaUser;

+(BOOL)isOldUser;

+(NSString *)stripMessage:(NSString *)message;

@end


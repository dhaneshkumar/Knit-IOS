//
//  AudioPlayerViewController.m
//  Knit
//
//  Created by Hardik Kothari on 26/09/15.
//  Copyright (c) 2015 Trumplab Edusolutions Pvt. Ltd. All rights reserved.
//

#import "AudioPlayerViewController.h"

@interface AudioPlayerViewController ()

@property (nonatomic) BOOL isPlaying;

@end

@implementation AudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isPlaying = false;
    _audioPlayer.volume = 0.5;
    _volumeSlider.value = 0.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonTapped:(id)sender {
    [_audioPlayer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playButtonTapped:(id)sender {
    if(_isPlaying) {
        [_audioPlayer pause];
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
        _isPlaying = false;
    }
    else {
        [_audioPlayer play];
        [_playButton setTitle:@"Pause" forState:UIControlStateNormal];
        _isPlaying = true;
    }
}

- (IBAction)stopButtonTapped:(id)sender {
    [_audioPlayer stop];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    _isPlaying = false;
}

- (IBAction)volumeSliderStateChanged:(id)sender {
    _audioPlayer.volume = _volumeSlider.value;
}


@end

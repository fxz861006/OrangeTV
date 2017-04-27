//
//  OrangeAVPlayerHelper.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/9.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "OrangeAVPlayerHelper.h"

@interface OrangeAVPlayerHelper ()
{
 AVPlayer *player;
}
@end

@implementation OrangeAVPlayerHelper
- (AVPlayer *)getAVPlayer {
    if (player) {
        return player;
    }
    return nil;
}

- (void)initAVPlayerWithAVPlayerItem:(AVPlayerItem *)item {
    player = [[AVPlayer alloc] initWithPlayerItem:item];
}

- (void)setAVPlayerVolume:(float)volume {
    [player setVolume:volume];
}

@end

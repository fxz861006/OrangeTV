//
//  OrangeAVPlayerHelper.h
//  OrangeTV
//
//  Created by PengchengWang on 16/3/9.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface OrangeAVPlayerHelper : NSObject

- (AVPlayer *)getAVPlayer;
- (void)initAVPlayerWithAVPlayerItem:(AVPlayerItem *)item;
- (void)setAVPlayerVolume:(float)volume;

@end

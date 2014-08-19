//
//  CAAvatarLayer.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/16/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAvatarLayer : CALayer

@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) TGChat *chat;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSCache *cacheDictionary;

- (void) redraw;

@end

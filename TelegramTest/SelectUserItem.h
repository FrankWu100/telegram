//
//  SelectUserItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectUserItem : TMRowItem

@property (nonatomic, strong) NSMutableAttributedString *title;
@property (nonatomic) NSSize titleSize;
@property (nonatomic, strong) NSMutableAttributedString *lastSeen;
@property (nonatomic) NSSize lastSeenSize;
@property (nonatomic) NSPoint lastSeenPoint;
@property (nonatomic) NSPoint titlePoint;
@property (nonatomic) NSPoint avatarPoint;
@property (nonatomic, strong) TGContact *contact;

@property (nonatomic) BOOL isSelected;

@end

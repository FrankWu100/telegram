//
//  MessageTableCellGeoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellGeoView.h"
#import "UIImageView+AFNetworking.h"


@interface MessageTableCellGeoView()
@property (nonatomic, strong) NSImageView *geoImageView;
@end

@implementation MessageTableCellGeoView

- (NSString *)urlEncoded:(NSString *)stringOld {
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)stringOld,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                    kCFStringEncodingUTF8 );
    
    NSString *string = [NSString stringWithString:(__bridge NSString *)urlString];
    CFRelease(urlString);

    return string;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        self.geoImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 250, 130)];
        __block dispatch_block_t block = ^{
            MessageTableItemGeo *geoItem = (MessageTableItemGeo *)weakSelf.item;
            
            TGUser *user = [[UsersManager sharedManager] find:geoItem.message.from_id];
            
            NSString *fullName = user.fullName ? [weakSelf urlEncoded:user.fullName] : @"";
            
            NSString *path = [NSString stringWithFormat:@"https://maps.google.com/maps?q=Location+(%@)+@%f,%f", fullName,  geoItem.message.media.geo.lat, geoItem.message.media.geo.n_long];
             
            
            open_link(path);
        };
        [self.geoImageView setWantsLayer:YES];
        [self.geoImageView.layer setCornerRadius:3];
        [self.geoImageView.layer setBorderWidth:0.5];
        [self.geoImageView.layer setBorderColor:NSColorFromRGB(0xcecece).CGColor];
        [self.geoImageView setCallback:block];
        [self.containerView addSubview:self.geoImageView];
        
        BTRButton *button = [[BTRButton alloc] initWithFrame:CGRectZero];
        [button setFrameSize:image_MessageMapPin().size];
        [button setCenterByView:self.geoImageView];
        [button setBackgroundImage:image_MessageMapPin() forControlState:BTRControlStateNormal];
        [button setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        [button addBlock:^(BTRControlEvents events) {
            block();
        } forControlEvents:BTRControlEventClick];
        [self.containerView addSubview:button];
    }
    return self;
}

- (void) setItem:(MessageTableItemGeo *)item {
    [super setItem:item];
    
    [self.geoImageView setImageWithURL:item.geoUrl];
}


@end

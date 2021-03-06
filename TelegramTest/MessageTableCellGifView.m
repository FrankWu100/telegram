//
//  MessageTableCellGifView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellGifView.h"
#import "TMGifImageView.h"
#import "ImageUtils.h"
#import "TMCircularProgress.h"
#import "MessageTableCellVideoView.h"
#import "GifAnimationLayer.h"
#import "TGImageView.h"
#import "FLAnimatedImage.h"
#import "TGModernAnimatedImagePlayer.h"
//#import "TelegramImageView.h"


@interface MessageTableCellGifView()

@property (nonatomic, strong) TGImageView *imageView;
@property (nonatomic, assign) BOOL needOpenAfterDownload;

@property (nonatomic,strong) TGModernAnimatedImagePlayer *animatedPlayer;

@property (nonatomic,strong) NSImageView *playImage;

@end

@implementation MessageTableCellGifView


static NSImage *playImage() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGBWithAlpha(0x000000, 0.5) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        [image_PlayIconWhite() drawInRect:NSMakeRect(roundf((48 - image_PlayIconWhite().size.width)/2) + 2, roundf((48 - image_PlayIconWhite().size.height)/2) , image_PlayIconWhite().size.width, image_PlayIconWhite().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return image;//image_VideoPlay();
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
        [self.imageView setRoundSize:4];
        [self.imageView setBlurRadius:60];
        
        [self.imageView setTapBlock:^{
            
            [weakSelf checkOperation];
            
        }];
        
        self.imageView.borderWidth = 1;
        self.imageView.borderColor = NSColorFromRGB(0xf3f3f3);
        
        [self setProgressToView:self.imageView];
        [self.containerView addSubview:self.imageView];
        
        self.playImage = imageViewWithImage(playImage());
        
        [self.imageView addSubview:self.playImage];
        
        
        [self.playImage setCenterByView:self.imageView];
        [self.playImage setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
        
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
    }
    return self;
}

-(void)checkOperation {
    [super checkOperation];
    self.needOpenAfterDownload = YES;
}

- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Documents menu"];
    
    if([self.item isset]) {
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.OpenInFinder", nil) withBlock:^(id sender) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:((MessageTableItemDocument *)self.item).path]]];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [self performSelector:@selector(saveAs:) withObject:self];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [self performSelector:@selector(copy:) withObject:self];
        }]];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}

-(void)setEditable:(BOOL)editable animation:(BOOL)animation
{
    [super setEditable:editable animation:animation];
    self.imageView.isNotNeedHackMouseUp = editable;
}


- (void)playAnimation {
    
    
    
    MessageTableItemGif *item = (MessageTableItemGif *)self.item;
    
    if([item isset]) {
        
        weak();
        
        if(!self.animatedPlayer) {
            self.animatedPlayer = [[TGModernAnimatedImagePlayer alloc] initWithSize:self.imageView.frame.size path:item.path];
            
            [self.animatedPlayer setFrameReady:^(NSImage *image) {
                weakSelf.imageView.image = image;
            }];
            
            [self.animatedPlayer play];
            
            [self.playImage setHidden:YES];
        } else {
            [self animationDidStop:nil finished:YES];
        }
    }
    
}

- (void)animationDidStart:(CAAnimation *)theAnimation {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    [self.animatedPlayer stop];
    self.animatedPlayer = nil;
    
    MessageTableItemGif *item = (MessageTableItemGif *)self.item;
    
    if(item.cachedThumb) {
        [self.imageView setImage:item.cachedThumb];
    } else {
        self.imageView.object = item.imageObject;
    }
    
    [self.playImage setHidden:NO];
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    const int borderOffset = self.imageView.borderWidth;
    const int borderSize = borderOffset*2;
    
    NSRect rect = NSMakeRect(self.containerView.frame.origin.x-borderOffset, self.containerView.frame.origin.y-borderOffset, NSWidth(self.imageView.frame)+borderSize, NSHeight(self.containerView.frame)+borderSize);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.imageView.roundSize yRadius:self.imageView.roundSize];
    [path addClip];
    
    
    [self.imageView.borderColor set];
    NSRectFill(rect);
}


-(void)doAfterDownload {
    if(self.visibleRect.size.width > 0 && self.visibleRect.size.height > 0 && self.needOpenAfterDownload) {
        [self open];
    }
}

- (void)open {
    if(!self.animatedPlayer.isPlaying) {
        [self playAnimation];
    } else {
        [self animationDidStop:nil finished:YES];
    }
}

- (void)resumeAnimation {
   // [self.gifAnimationLayer resumeAnimating];
    [self.animatedPlayer play];
}

- (void)pauseAnimation {
  //  [self.gifAnimationLayer pauseAnimating];
    [self.animatedPlayer pause];
}

- (void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    [self.playImage setHidden:!(cellState == CellStateNormal)];
    
    [self.progressView setState:cellState];
}

- (void) setItem:(MessageTableItemGif *)item {
    [super setItem:item];
    
    self.needOpenAfterDownload = NO;
    
    [self updateDownloadState];
    
    
    [self.animatedPlayer stop];
    self.animatedPlayer = nil;
    
    
    
    [self.imageView setFrameSize:item.blockSize];
    
    [self.progressView setCenterByView:self.imageView];
    
    if(item.cachedThumb) {
        [self.imageView setImage:item.cachedThumb];
    } else {
        self.imageView.object = item.imageObject;
    }
}



@end

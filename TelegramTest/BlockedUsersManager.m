//
//  BlockedUsersManager.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BlockedUsersManager.h"

@implementation BlockedUsersManager

+ (id)sharedManager {
    static BlockedUsersManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BlockedUsersManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(NSArray *)all {
    __block NSArray *object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = self->keys.allValues;
    } synchronous:YES];
    
    return object;
}

- (void)remoteLoad {    
    if(![SettingsArchiver checkMaskedSetting:BlockedContactsSynchronized]) {
         [self _remoteLoadWithOffset:0 limit:100 array:nil];
    } else {
        [[Storage manager] blockedList:^(NSArray *users) {
            [self add:users];
        }];
    }
}

- (void)_remoteLoadWithOffset:(int)offset limit:(int)limit array:(NSMutableArray *)array {
    
    if(!array)
        array = [[NSMutableArray alloc] init];
    
    [RPCRequest sendRequest:[TLAPI_contacts_getBlocked createWithOffset:offset limit:limit] successHandler:^(RPCRequest *request, TL_contacts_blocked *response) {
        
        [array addObjectsFromArray:response.blocked];
        
        
        [SharedManager proccessGlobalResponse:response];
        
        if([response isKindOfClass:[TL_contacts_blockedSlice class]]) {
            [self _remoteLoadWithOffset:offset + limit limit:limit array:array];
        } else {
            [self _compleRemoteLoad:array];
        }
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        DLog(@"RpcError %@", error.error_msg);
    }];
}

- (void)_compleRemoteLoad:(NSArray *)array {
    [self->keys removeAllObjects];
    [[Storage manager] insertBlockedUsers:array];
    [SettingsArchiver addSetting:BlockedContactsSynchronized];
    [self add:array];
}

- (void)add:(NSArray *)all {
    [ASQueue dispatchOnStageQueue:^{
        for (TGContactBlocked *blockedContact in all) {
            [self->keys setObject:blockedContact forKey:@(blockedContact.user_id)];
        }
    }];
}

- (BOOL)isBlocked:(int)user_id {
    return [self find:user_id] != nil;
}

-(void)updateBlocked:(int)user_id isBlocked:(BOOL)isBlocked {
    
    [ASQueue dispatchOnStageQueue:^{
        TL_contactBlocked *contact;
        if(isBlocked) {
            contact = [TL_contactBlocked createWithUser_id:user_id date:[[MTNetwork instance] getTime]];
            [[Storage manager] insertBlockedUsers:@[contact]];
            [self->keys setObject:contact forKey:@(user_id)];
        } else {
            contact = [self->keys objectForKey:@(user_id)];
            if(contact) {
                [[Storage manager] deleteBlockedUsers:@[contact]];
            }
            [self->keys removeObjectForKey:@(user_id)];
        }
        
        if(contact)
            [Notification perform:USER_BLOCK data:@{KEY_USER:contact}];
    }];
}

- (void)unblock:(int)user_id completeHandler:(BlockedHandler)block {
    [self block:NO user_id:user_id completeHandler:block];
}

- (void)block:(int)user_id completeHandler:(BlockedHandler)block {
    [self block:YES user_id:user_id completeHandler:block];
}

- (void)block:(BOOL)isBlock user_id:(int)user_id completeHandler:(BlockedHandler)block {
    TGUser *user = [[UsersManager sharedManager] find:user_id];
    if(!user) {
        block(NO);
        return;
    }
    
    id request = isBlock ? [TLAPI_contacts_block createWithN_id:user.inputUser] : [TLAPI_contacts_unblock createWithN_id:user.inputUser];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
        
        [self updateBlocked:user_id isBlocked:isBlock];
        
        if(block)
            block(YES);
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(block)
            block(NO);
        
    }];
}

-(id)find:(NSInteger)_id withCustomKey:(NSString *)key {
    __block id object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = [self->keys objectForKey:@(_id)];
    } synchronous:YES];
    
    return object;
}

@end

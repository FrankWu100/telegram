//
//  PrivacyViewController.m
//  Telegram
//
//  Created by keepcoder on 19.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PrivacyViewController.h"
#import "GeneralSettingsRowItem.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
@interface PrivacyViewController () <TMTableViewDelegate>
@property (nonatomic,strong) TMTextField *centerTextField;
@property (nonatomic,strong) TMTableView *tableView;

@property (nonatomic,strong) GeneralSettingsRowItem *lastSeenRowItem;
@property (nonatomic,strong) GeneralSettingsRowItem *blockedUsersRowIten;
@end

@implementation PrivacyViewController

-(void)loadView {
    [super loadView];
    
    _centerTextField = [TMTextField defaultTextField];
    [self.centerTextField setAlignment:NSCenterTextAlignment];
    [self.centerTextField setAutoresizingMask:NSViewWidthSizable];
    [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.centerTextField setDrawsBackground:NO];
    
    [self.centerTextField setStringValue:NSLocalizedString(@"PrivacyAndSecurity.Header", nil)];
    
    [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, -12)];
    
    self.centerNavigationBarView = (TMView *) self.centerTextField;
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
    
    GeneralSettingsBlockHeaderItem *privacyHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"PrivacyAndSecurity.PrivacyHeader", nil)];
    
    privacyHeader.height = 61;
    
    [self.tableView insert:privacyHeader atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    self.blockedUsersRowIten = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        [[Telegram rightViewController] showBlockedUsers];
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.BlockedUsers", nil) height:42 stateback:nil];
    
    [self.tableView insert:self.blockedUsersRowIten atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    
    
    self.lastSeenRowItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        if(!self.lastSeenRowItem.locked)
            [[Telegram rightViewController] showLastSeenController];
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.LastSeen", nil) subdesc:@"" height:42 stateback:nil];
    
    [self.tableView insert:self.lastSeenRowItem atIndex:self.tableView.list.count tableRedraw:NO];
    

    
    GeneralSettingsBlockHeaderItem *security = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"PrivacyAndSecurity.SecurityHeader", nil)];
    
    security.height = 51;
    
    [self.tableView insert:security atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    
    GeneralSettingsRowItem *terminateSessions = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        [self terminateSessions];
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.TerminateSessions", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoGroupAudio]);
    }];
    
    [self.tableView insert:terminateSessions atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    GeneralSettingsRowItem *logout = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        [self logOut];
        
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.Logout", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoGroupAudio]);
    }];
    
    [self.tableView insert:logout atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    GeneralSettingsBlockHeaderItem *deleteAccountHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"PrivacyAndSecurity.DeleteAccountHeader", nil)];
//    
//    deleteAccountHeader.height = 61;
//    
//    [self.tableView insert:deleteAccountHeader atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    GeneralSettingsRowItem *deleteAccount = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
//        
//    } description:NSLocalizedString(@"PrivacyAndSecurity.DeleteAccount", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:EmojiReplaces]);
//    }];
//    
//    [self.tableView insert:deleteAccount atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    [self.tableView reloadData];
    
}




- (void)terminateSessions {
    
    confirm(NSLocalizedString(@"Confirm", nil), NSLocalizedString(@"Confirm.TerminateSessions", nil), ^ {
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_auth_resetAuthorizations create] successHandler:^(RPCRequest *request, id response) {
            
            alert(NSLocalizedString(@"Success", nil), NSLocalizedString(@"Confirm.SuccessResetSessions", nil));
            
            [self hideModalProgress];
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            alert(NSLocalizedString(@"Alert.Error", nil), NSLocalizedString(@"Auth.CheckConnection", nil));
            
             [self hideModalProgress];
            
        } timeout:5];
    },nil);
    
    
}
- (void)logOut {
    confirm(NSLocalizedString(@"Confirm", nil),NSLocalizedString(@"Confirm.ConfirmLogout", nil), ^ {
        [[Telegram delegate] logoutWithForce:NO];
    },nil);
    
}

-(void)updatePrivacyDescription:(NSNotification *)notification {
    
    
    
    PrivacyArchiver *lsPrivacy = [PrivacyArchiver privacyForType:kStatusTimestamp];
    
    
    NSString * subdesc = @"";
    
    NSString *adc = @"";
    
    if(lsPrivacy.disallowUsers.count > 0) {
        adc = [adc stringByAppendingFormat:@" (-%lu",lsPrivacy.disallowUsers.count];
    }
    
    if(lsPrivacy.allowUsers.count > 0) {
        adc = [adc stringByAppendingFormat:@"%@+%lu",adc.length > 0 ? @", " : @" (", lsPrivacy.allowUsers.count];
    }
    
    if(adc.length > 0)
        adc = [adc stringByAppendingString:@")"];
    
    switch (lsPrivacy.allowType) {
        case PrivacyAllowTypeContacts:
            
            subdesc = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PrivacySettingsController.MyContacts", nil),adc];
            break;
        case PrivacyAllowTypeEverbody:
            subdesc = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PrivacySettingsController.Everbody", nil),adc];
            break;
        case PrivacyAllowTypeNobody:
            subdesc = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PrivacySettingsController.Nobody", nil),adc];
            break;
            
        default:
            break;
    }
    
    self.lastSeenRowItem.subdesc = subdesc;

    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self updatePrivacyDescription:nil];
    
    [Notification addObserver:self selector:@selector(updatePrivacyDescription:) name:PRIVACY_UPDATE];
    
    
    
    if([PrivacyArchiver privacyForType:kStatusTimestamp] == nil && !self.lastSeenRowItem.locked) {
        
        [self.lastSeenRowItem setLocked:YES];
        
        [self.tableView reloadData];
        
        [RPCRequest sendRequest:[TLAPI_account_getPrivacy createWithN_key:[TL_inputPrivacyKeyStatusTimestamp create]] successHandler:^(RPCRequest *request, TL_account_privacyRules *response) {
            
            [SharedManager proccessGlobalResponse:response];
            
            PrivacyArchiver *privacy = [PrivacyArchiver privacyFromRules:[response rules] forKey:kStatusTimestamp];
            
            [privacy _save];
            
            [self.lastSeenRowItem setLocked:NO];
            [self.tableView reloadData];
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
        
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsRowViewClass"];
    }
    
    return nil;
    
}

- (void)selectionDidChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}


@end

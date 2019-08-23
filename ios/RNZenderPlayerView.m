#import "RNZenderPlayerView.h"

@import Zender;

// Note: We prefix our object with RN here to avoid clashes
@implementation RNZenderPlayerView {
    NSString *environment;
    NSString *deviceToken;
    NSString *redeemCode;
    NSString *backgroundColor;
    BOOL debugEnabled;
    
}

- (instancetype)init
{
    
    if (self = [super init]) {
        
        // Create a Zender Player
        if (_player == nil) {
            _player= [ZenderPlayer new];
        }
        
        // Create a player configuration
        ZenderPlayerConfig* settingsConfig = [ZenderPlayerConfig configWithTargetId:targetId channelId:channelId];
        _player.config = settingsConfig;
        
        // Use authentication
        _player.authentication = nil;
        
        // Set this class as a ZenderPlayerDelegate
        _player.delegate = self;
        
        _player.view.frame = self.webView.frame;
        _player.view.hidden = false;
        
        [self addSubview:_player.view];
        // NOTE: we can't start the player during init
        // This is because TargetId & ChannelId are only initialized in the setters
        //  [_player start];
        
    }
    
    return self;
}


// This makes sure the view gets resized correctly
-(void)layoutSubviews
{
    [super layoutSubviews];
    _player.view.frame = self.frame;
}

#pragma marker Zender Setters

-(void)setTargetId:(NSString*) targetId {
    _targetId = targetId;
    _player.config.targetId = targetId;
    
    [self startZenderPlayerWhenSettersComplete];
}

-(void)setChannelId:(NSString*) channelId {
    _channelId = channelId;
    _player.config.channelId = channelId;
    
    [self startZenderPlayerWhenSettersComplete];
}

-(void)setAuthentication:(NSDictionary *)authentication {
    
    // If config is nil, skip
    if (authentication == nil) {
        return;
    }
    
    /*
     ZenderAuthentication *deviceAuthentication = [ZenderAuthentication authenticationWith:@{
     @"token": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
     @"name": username,
     @"avatar": @"https://example.com/myavatar.png"
     } provider:@"device"];
     */
    
    NSString *authenticationProvider = [authentication objectForKey:@"provider"];
    NSDictionary *authenticationPayload = [authentication objectForKey:@"payload"];
    
    // Check if we got both payload & provider
    if ((authenticationProvider!=nil) && (authenticationPayload!=nil)) {
        _player.authentication = [ZenderAuthentication authenticationWith:authenticationPayload provider:authenticationProvider];
    }
    
    [self startZenderPlayerWhenSettersComplete];
}

-(void)setConfig:(NSDictionary *)config {
    
    // If config is nil, skip
    if (config == nil) {
        return;
    }
    
    // Set debug
    NSNumber *checkDebugEnabled = [config objectForKey:@"debugEnabled"];
    if (checkDebugEnabled!=nil) {
        BOOL debugEnabled = [config objectForKey:@"debugEnabled"];
        //     NSLog(@"BOOL DebugEnabled : %@", debugEnabled ? @"Yes" : @"No");
        
        if (debugEnabled) {
            [[ZenderLogger sharedInstance] setLevel:ZenderLogger_LEVEL_DEBUG];
            [_player.config enableDebug:debugEnabled];
        }
    }
    
    // Register device
    NSNumber *checkDeviceToken = [config objectForKey:@"deviceToken"];
    if (checkDeviceToken!=nil) {
        deviceToken = [config objectForKey:@"deviceToken"];
        
        ZenderUserDevice *userDevice = [ZenderUserDevice new];
        userDevice.token = _deviceToken;
        [_player.config setUserDevice:userDevice];
        
    }
    
    // Check Environment
    // Override endpoints if needed
    NSNumber *checkEnvironment = [config objectForKey:@"environment"];
    if (checkEnvironment!=nil) {
        environment = [config objectForKey:@"environment"];
        
        if ([environment isEqualToString:@"staging"]) {
            NSString *playerEndpoint=@"https://player2-native.staging.zender.tv";
            NSString *apiEndpoint=@"https://api.staging.zender.tv";
            NSString *logEndpoint=@"https://logs.staging.zender.tv/v1/ingest/batch";
            
            [settingsConfig overridePlayerEndpointPrefix:playerEndpoint];
            [settingsConfig overrideApiEndpointUrl:apiEndpoint];
            [[ZenderLogger sharedInstance] overrideEndpoint:logEndpoint];
            
        }
    }
    
    // Redeem quiz code if needed
    NSNumber *checkRedeemCode = [config objectForKey:@"redeemCode"];
    if (checkRedeemCode!=nil) {
        redeemCode = [config objectForKey:@"redeemCode"];
        [_player redeemCodeQuiz:redeemCode];
    }
    
    // Set the background
    NSNumber *checkBackgroundColor = [config objectForKey:@"backgroundColor"];
    
    if (checkBackgroundColor!=nil) {
        backgroundColor = [config objectForKey:@"backgroundColor"];
        _player.view.backgroundColor = [self colorWithHexString:backgroundColor];
    } else {
        _player.view.backgroundColor = [UIColor blackColor];
    }
    
    [self startZenderPlayerWhenSettersComplete];
}

// Currently we check to see if we got all setters before starting the player
- (void) startZenderPlayerWhenSettersComplete {
    if (_targetId == nil) { return; }
    if (_channelId == nil) { return; }
    if (_authentication == nil) { return ; }
    if (_config == nil) { return ; }
    
    _player.view.frame = self.frame;
    
    //[self setupApiSubscribeDevice];
    [_player start];
}

- (void)dealloc
{
    //NSLog(@"alloc dealloc");
    [_player stop];
    _player = nil;
}


- (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}


#pragma mark Zender Events

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerClose:(NSDictionary *)payload {
    
    if(self.onIosZenderPlayerClose){
        self.onIosZenderPlayerClose(@{});
    }
}

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizShareCode:(NSDictionary *)payload {
    
    NSString *shareCode = [payload valueForKey:@"shareCode"];
    NSString *shareText = [payload valueForKey:@"shareText"];
    NSString *text = [payload valueForKey:@"text"];
    
    NSMutableDictionary *shareDict = [NSMutableDictionary new];
    
    if(self.onIosZenderPlayerQuizShareCode){
        if (shareText != nil) {
            [shareDict setValue:shareText forKey:@"shareText"];
        }
        if (text != nil) {
            [shareDict setValue:text forKey:@"shareText"];
        }
        if (shareCode != nil) {
            [shareDict setValue:shareCode forKey:@"shareCode"];
        }
        self.onIosZenderPlayerQuizShareCode([NSDictionary dictionaryWithDictionary:shareDict]);
    }
}



/*
 - (void)setupApiSubscribeDevice {
 
 if (_deviceToken == nil) {
 return;
 }
 
 ZenderApiClient *apiClient = [[ZenderApiClient alloc] initWithTargetId:_targetId channelId:_channelId ];
 
 apiClient.authentication = self.player.authentication;
 
 ZenderUserDevice *userDevice = [ZenderUserDevice new];
 userDevice.token = _deviceToken;
 
 [apiClient login:^(NSError *error, ZenderSession *session) {
 ZLog_Debug(@"RNZenderPlayer", @"api login callback completed");
 
 if (error == nil) {
 [apiClient registerDevice:userDevice andCompletionHandler:^(NSError *error) {
 if (error == nil) {
 ZLog_Debug(@"RNZenderPlayer", @"api registerDevice callback completed");
 } else {
 ZLog_Error(@"RNZenderPlayer", @"api registerDevice callback failed");
 }
 }];
 } else {
 ZLog_Error(@"RNZenderPlayer", @"failed in example %@",error);
 }
 }];
 
 }
 */


@end


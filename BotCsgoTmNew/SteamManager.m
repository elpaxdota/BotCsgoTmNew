//
//  SteamManager.m
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 23.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import "SteamManager.h"
#import "AFNetworking.h"

@interface SteamManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation SteamManager


+ (SteamManager*) sharedManager
{
    static SteamManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SteamManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSError *error = nil;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"JSONData" ofType:@"txt"];
        
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
        NSArray *jsonArray = [NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingAllowFragments
                              error:&error];
        
        
        for (NSDictionary *dict in jsonArray)
        {
            NSMutableDictionary *prop = [[NSMutableDictionary alloc] init];
            
            [prop setObject:[dict objectForKey:@"domain"] forKey:NSHTTPCookieDomain];
            [prop setObject:[dict objectForKey:@"session"] forKey:NSHTTPCookieDiscard];
            [prop setObject:[dict objectForKey:@"path"] forKey:NSHTTPCookiePath];
            [prop setObject:[dict objectForKey:@"name"] forKey:NSHTTPCookieName];
            [prop setObject:[dict objectForKey:@"value"] forKey:NSHTTPCookieValue];
            [prop setObject:[dict objectForKey:@"hostOnly"] forKey:NSHTTPCookieOriginURL];
            [prop setObject:[dict objectForKey:@"secure"] forKey:NSHTTPCookieSecure];
            
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:prop];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
    }
    return self;
}


- (void) getTradeOfferWithId:(NSString*)offerId
                   onSuccess:(void(^)(NSString *response))success
                   onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://steamcommunity.com/tradeoffer/%@/", offerId];
    
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies: cookiesArray];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfig.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
    self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [self.sessionManager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Acept-Encoding"];
    [self.sessionManager.requestSerializer setValue:@"ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4" forHTTPHeaderField:@"Acept-Language"];
    [self.sessionManager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [self.sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self.sessionManager.requestSerializer setValue:@"1" forHTTPHeaderField:@"DNT"];
    [self.sessionManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [self.sessionManager.requestSerializer setValue:@"https://steamcommunity.com" forHTTPHeaderField:@"Origin"];
    [self.sessionManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [self.sessionManager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.sessionManager.requestSerializer setValue:[cookieHeaders objectForKey: @"Cookie" ] forHTTPHeaderField:@"Cookie"];
    
    //NSLog(@"%@", self.sessionManager.requestSerializer.HTTPRequestHeaders);
    
    [self.sessionManager POST:urlString
              parameters:nil
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     
                     NSString *response = [NSString stringWithUTF8String:[responseObject bytes]];

                     if (success)
                     {
                         success(response);
                     }
                     
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     
                     if (failure)
                     {
                         failure(error);
                     }
                 }];
}

- (void) acceptTradeOfferWithTradeOfferId:(NSString*)offerId
                                sessionId:(NSString*)sessionId
                                partnerId:(NSString*)partnerId
                                onSuccess:(void(^)(NSString *response))success
                                onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://steamcommunity.com/tradeoffer/%@/accept", offerId];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:sessionId,        @"sessionid",
                                offerId,     @"tradeofferid",
                                @"1",                  @"serverid",
                                partnerId,    @"partner",
                                @"",                   @"captcha", nil];
    
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies: cookiesArray];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    sessionConfig.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [sessionManager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Acept-Encoding"];
    [sessionManager.requestSerializer setValue:@"ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4" forHTTPHeaderField:@"Acept-Language"];
    [sessionManager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [sessionManager.requestSerializer setValue:@"104" forHTTPHeaderField:@"Content-Length"];
    [sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [sessionManager.requestSerializer setValue:@"1" forHTTPHeaderField:@"DNT"];
    [sessionManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [sessionManager.requestSerializer setValue:@"https://steamcommunity.com" forHTTPHeaderField:@"Origin"];
    [sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"https://steamcommunity.com/tradeoffer/%@", offerId] forHTTPHeaderField:@"Referer"];
    [sessionManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [sessionManager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [sessionManager.requestSerializer setValue:[cookieHeaders objectForKey: @"Cookie" ] forHTTPHeaderField:@"Cookie"];
    
    [sessionManager POST:urlString
              parameters:parameters
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     
                     NSString *response = [NSString stringWithUTF8String:[responseObject bytes]];
                     
                     if (success)
                     {
                         success(response);
                     }
                     
                     
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     
                     if (failure)
                     {
                         failure(error);
                     }
                     
                 }];
}


@end
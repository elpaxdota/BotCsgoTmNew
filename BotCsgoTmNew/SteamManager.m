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

@property (strong, nonatomic) AFHTTPSessionManager *getOfferManager;
@property (strong, nonatomic) AFHTTPSessionManager *acceptOfferManager;
@property (strong, nonatomic) AFHTTPSessionManager *loadInventoryManager;

@property (strong, nonatomic) NSURLSessionConfiguration* sessionConfig;

@property (strong, nonatomic) NSArray *cookiesArray;
@property (strong, nonatomic) NSDictionary *cookieHeaders;



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
        //добавляем куки из файла JSONData.txt
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
    
    /*
    инициализируем для каждого метода отдельный менеджер,
    т.к. для каждого нужны уникальные параметры
    */
    self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    self.sessionConfig.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    self.cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    self.cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies: self.cookiesArray];
    
    //getOfferManager initialization
    self.getOfferManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:self.sessionConfig];
    self.getOfferManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.getOfferManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.getOfferManager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [self.getOfferManager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Acept-Encoding"];
    [self.getOfferManager.requestSerializer setValue:@"ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4" forHTTPHeaderField:@"Acept-Language"];
    [self.getOfferManager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [self.getOfferManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self.getOfferManager.requestSerializer setValue:@"1" forHTTPHeaderField:@"DNT"];
    [self.getOfferManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [self.getOfferManager.requestSerializer setValue:@"https://steamcommunity.com" forHTTPHeaderField:@"Origin"];
    [self.getOfferManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [self.getOfferManager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.getOfferManager.requestSerializer setValue:[self.cookieHeaders objectForKey: @"Cookie" ] forHTTPHeaderField:@"Cookie"];
    
    
    //acceptOfferManager initialization
    self.acceptOfferManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:self.sessionConfig];
    self.acceptOfferManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.acceptOfferManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.acceptOfferManager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [self.acceptOfferManager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Acept-Encoding"];
    [self.acceptOfferManager.requestSerializer setValue:@"ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4" forHTTPHeaderField:@"Acept-Language"];
    [self.acceptOfferManager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [self.acceptOfferManager.requestSerializer setValue:@"104" forHTTPHeaderField:@"Content-Length"];
    [self.acceptOfferManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self.acceptOfferManager.requestSerializer setValue:@"1" forHTTPHeaderField:@"DNT"];
    [self.acceptOfferManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [self.acceptOfferManager.requestSerializer setValue:@"https://steamcommunity.com" forHTTPHeaderField:@"Origin"];
    [self.acceptOfferManager.requestSerializer setValue:@"steamcommunity.com" forHTTPHeaderField:@"Host"];
    [self.acceptOfferManager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.acceptOfferManager.requestSerializer setValue:[self.cookieHeaders objectForKey: @"Cookie" ] forHTTPHeaderField:@"Cookie"];
    
    
    //loadInventoryManager initialization
    self.loadInventoryManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:self.sessionConfig];
    
    return self;
}


- (void) getTradeOfferWithId:(NSString*)offerId
                   onSuccess:(void(^)(NSString *response))success
                   onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://steamcommunity.com/tradeoffer/%@/", offerId];
    
    [self.getOfferManager POST:urlString
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
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                            sessionId,          @"sessionid",
                                                                            offerId,            @"tradeofferid",
                                                                            @"1",               @"serverid",
                                                                            partnerId,          @"partner",
                                                                            @"",                @"captcha", nil];
    
    [self.acceptOfferManager.requestSerializer setValue:[NSString stringWithFormat:@"https://steamcommunity.com/tradeoffer/%@", offerId] forHTTPHeaderField:@"Referer"];
    
    [self.acceptOfferManager POST:urlString
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

- (void) checkSteamInventoryonSuccess:(void(^)(NSDictionary *steamItems))success
                                                        onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = @"http://steamcommunity.com/profiles/76561198275654943/inventory/json/730/2/";
    
    [self.loadInventoryManager
     GET:urlString
     parameters:nil
     progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
         NSDictionary *items = [responseObject objectForKey:@"rgInventory"];
         
         if (success)
         {
             success(items);
         }
         
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         NSLog(@"Steam error = %@", error);
         
     }];
}


@end

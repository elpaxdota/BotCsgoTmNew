//
//  ServerManager.m
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 08.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import "ServerManager.h"
#import "AFNetworking.h"
#import "ItemModel.h"

@interface ServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation ServerManager

+ (ServerManager*) sharedManager
{
    static ServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSURL *url = [NSURL URLWithString:@"https://csgo.tm/api/"];
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    return self;
}

//==============   Отправка вещи от бота   =======================

- (void) sendItemFromBotWithAPIKey:(NSString*)apiKey
                           fromBot:(BOOL)fromBot
                             botId:(NSString*)botId
                         onSuccess:(void(^)(NSString *offerId))success
                         onFailure:(void(^)(NSError *error))failure
{
    NSString *inOrOut;
    
    if (fromBot == YES)
    {
        inOrOut = @"out";
    }
    else
    {
        inOrOut = @"in";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"ItemRequest/%@/%@/", inOrOut, botId];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"key", nil];
    
    [self.sessionManager GET:urlString
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSString *tradeOfferId = nil;
                         
                         tradeOfferId = [responseObject objectForKey:@"trade"];
                         
                         if (success)
                         {
                             success(tradeOfferId);
                         }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

//==============   Проверяю статус вещей   =======================

- (void) checkItemsStatusWithAPIKey:(NSString*)apiKey
                          onSuccess:(void(^)(NSArray *trades))success
                          onFailure:(void(^)(NSError *error))failure
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"key", nil];
   
    [self.sessionManager GET:@"Trades/"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
                         NSArray *ordersArray = responseObject;
                         
                         if (success)
                         {
                             success(ordersArray);
                         }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure)
        {
            failure(error);
        }
    }];
}


//==============   Изменяю цену на ордер   =======================

- (void) changeOrderWithInstanceId:(NSString*)instanceId
                           classId:(NSString*)classId
                            apiKey:(NSString*)apiKey
                             price:(NSString*)price
                         onSuccess:(void(^)(NSString *message))success
                         onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"UpdateOrder/%@/%@/%@/", classId, instanceId, price];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"key", nil];
    
    [self.sessionManager GET:urlString
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"изменение ордера:  %@", responseObject);
        
        NSString *message = nil;
        
        if (success)
        {
            success(message);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

//==============   Выставляю новый ордер   =======================

- (void) getNewOrderWithInstanceId:(NSString*)instanceId
                           classId:(NSString*)classId
                            apiKey:(NSString*)apiKey
                             price:(NSString*)price
                              hash:(NSString*)hash
                         onSuccess:(void(^)(NSString *message))success
                         onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"InsertOrder/%@/%@/%@/%@/", classId, instanceId, price, hash];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"key", nil];
    
    [self.sessionManager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"getNewOrderWithInstanceId = %@", responseObject);
        
        NSString *message = nil;
        
        if (success)
        {
            success(message);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

//==============   Получаю список выставленных ордеров   ================

- (void) getOrdersWithApiKey:(NSString*)apiKey
                   onSuccess:(void(^)(NSMutableArray *orders))success
                   onFailure:(void(^)(NSError *error))failure
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"key", nil];
    
    [self.sessionManager
     GET:@"GetOrders/"
     parameters:params
     progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
         NSMutableArray *allOrders = [NSMutableArray array];
         // если нет ни одного ордера - ничего не передаем
         if ([[responseObject objectForKey:@"Orders"] isKindOfClass:[NSArray class]])
         {
             [allOrders addObjectsFromArray:[responseObject objectForKey:@"Orders"]];
         }
         
         if (success)
         {
             success(allOrders);
         }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

//==============   Получаю информацию о предмете для добавления в таблицу   ================

- (void) getItemInfoWithInstanceId:(NSString*)instanceId
                           classId:(NSString*)classId
                            apiKey:(NSString*)apiKey
                         onSuccess:(void(^)(ItemModel *item))success
                         onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"ItemInfo/%@_%@/ru/", classId, instanceId];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"key", nil];
    
   [self.sessionManager
    GET:urlString
    parameters:params
    progress:nil
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        ItemModel *item = [[ItemModel alloc] initWithServerResponse:responseObject];
        
        if (success)
        {
            success(item);
        }
        
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
       if (failure)
       {
           failure(error);
       }
       
   }];
}

//==============   Обновляю информацию о предмете   ================

- (void) getRefreshPriceAndOrderWithInstanceId:(NSString*)instanceId
                                       classId:(NSString*)classId
                                        apiKey:(NSString*)apiKey
                                     onSuccess:(void(^)(ItemModel *item))success
                                     onFailure:(void(^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"ItemInfo/%@_%@/ru/", classId, instanceId];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, @"key", nil];
    
    [self.sessionManager
     GET:urlString
     parameters:params
     progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
         ItemModel *item = [[ItemModel alloc] initWithServerResponse:responseObject];
         
         if (success)
         {
             success(item);
         }
         
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         if (failure)
         {
             failure(error);
         }
         
     }];
}

@end























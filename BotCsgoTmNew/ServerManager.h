//
//  ServerManager.h
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 08.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ItemModel;

@interface ServerManager : NSObject

// SingleTone
+ (ServerManager*) sharedManager;


//======================   API Methods   ========================

- (void) updateInventoryWithAPIKey:(NSString*)apiKey
                         onSuccess:(void(^)(NSString *message))success
                         onFailure:(void(^)(NSError *error))failure;

- (void) itemToSellWithInstanceId:(NSString*)instanceId
                          classId:(NSString*)classId
                           apiKey:(NSString*)apiKey
                            price:(NSString*)price
                        onSuccess:(void(^)(NSString *message))success
                        onFailure:(void(^)(NSError *error))failure;

- (void) pingPongWithAPIKey:(NSString*)apiKey;

- (void) sendItemFromBotWithAPIKey:(NSString*)apiKey
                           fromBot:(BOOL)fromBot
                             botId:(NSString*)botId
                         onSuccess:(void(^)(NSString *offerId))success
                         onFailure:(void(^)(NSError *error))failure;

- (void) checkItemsStatusWithAPIKey:(NSString*)apiKey
                          onSuccess:(void(^)(NSArray *trades))success
                          onFailure:(void(^)(NSError *error))failure;

- (void) getItemInfoWithInstanceId:(NSString*)instanceId
                           classId:(NSString*)classId
                            apiKey:(NSString*)apiKey
                         onSuccess:(void(^)(ItemModel *item))success
                         onFailure:(void(^)(NSError *error))failure;

- (void) getRefreshPriceAndOrderWithInstanceId:(NSString*)instanceId
                           classId:(NSString*)classId
                            apiKey:(NSString*)apiKey
                         onSuccess:(void(^)(ItemModel *item))success
                         onFailure:(void(^)(NSError *error))failure;

- (void) getOrdersWithApiKey:(NSString*)apiKey
                   onSuccess:(void(^)(NSMutableArray *orders))success
                   onFailure:(void(^)(NSError *error))failure;

- (void) getNewOrderWithInstanceId:(NSString*)instanceId
                           classId:(NSString*)classId
                            apiKey:(NSString*)apiKey
                             price:(NSString*)price
                              hash:(NSString*)hash
                         onSuccess:(void(^)(NSString *message))success
                         onFailure:(void(^)(NSError *error))failure;

- (void) changeOrderWithInstanceId:(NSString*)instanceId
                           classId:(NSString*)classId
                            apiKey:(NSString*)apiKey
                             price:(NSString*)price
                         onSuccess:(void(^)(NSString *message))success
                         onFailure:(void(^)(NSError *error))failure;

@end

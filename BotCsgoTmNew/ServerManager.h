//
//  ServerManager.h
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 08.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item, ItemModel;

@interface ServerManager : NSObject

// SingleTone
+ (ServerManager*) sharedManager;


//======================   API Methods   ========================

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

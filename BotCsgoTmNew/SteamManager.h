//
//  SteamManager.h
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 23.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SteamManager : NSObject

// SingleTone
+ (SteamManager*) sharedManager;


//======================   Accept Trades   ========================

- (void) getTradeOfferWithId:(NSString*)offerId
                   onSuccess:(void(^)(NSString *response))success
                   onFailure:(void(^)(NSError *error))failure;

- (void) acceptTradeOfferWithTradeOfferId:(NSString*)offerId
                                sessionId:(NSString*)sessionId
                                partnerId:(NSString*)partnerId
                                onSuccess:(void(^)(NSString *response))success
                                onFailure:(void(^)(NSError *error))failure;

- (void) checkSteamInventoryonSuccess:(void(^)(NSDictionary *steamItems))success
                            onFailure:(void(^)(NSError *error))failure;



@end

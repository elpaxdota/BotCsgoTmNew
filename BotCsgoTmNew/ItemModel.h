//
//  ItemModel.h
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 12.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Realm/Realm.h>

@interface ItemModel : RLMObject

@property NSString *classId;
@property NSString *instanceId;
@property NSString *marketName;
@property NSString *hashName;
@property NSInteger minPrice;
@property NSInteger maxOrder;
@property NSInteger quantity;
@property NSInteger budget;
@property NSInteger buyerPays;
@property NSInteger youReceive;

- (id) initWithServerResponse:(NSDictionary*)responseObject;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ItemModel>
RLM_ARRAY_TYPE(ItemModel)

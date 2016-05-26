//
//  ItemModel.m
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 12.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import "ItemModel.h"

@implementation ItemModel

- (id) initWithServerResponse:(NSDictionary*)responseObject
{
    self = [super init];
    if (self)
    {
        self.classId = [responseObject objectForKey:@"classid"];
        self.instanceId = [responseObject objectForKey:@"instanceid"];
        self.marketName = [responseObject objectForKey:@"market_name"];
        self.hashName = [responseObject objectForKey:@"hash"];
        self.minPrice = [[responseObject objectForKey:@"min_price"] integerValue];
        self.quantity = 0;
        self.budget = 0;
        self.buyerPays = 0;
        self.youReceive = 0;
        self.sellOrNot = 1;
        
        NSArray *buyOffers = [responseObject objectForKey:@"buy_offers"];
        
        if ([buyOffers count] > 0)
        {
            NSDictionary *dic = [buyOffers objectAtIndex:0];
            
            self.maxOrder = [[dic objectForKey:@"o_price"] integerValue];
        }
    }
    return self;
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end

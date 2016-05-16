//
//  ItemModel.h
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 12.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Realm/Realm.h>

@interface ItemModel : RLMObject
<# Add properties here to define the model #>
@end

// This protocol enables typed collections. i.e.:
// RLMArray<ItemModel>
RLM_ARRAY_TYPE(ItemModel)

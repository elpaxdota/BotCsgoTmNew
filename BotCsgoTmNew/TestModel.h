//
//  TestModel.h
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 11.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Realm/Realm.h>

@interface TestModel : RLMObject

@end

// This protocol enables typed collections. i.e.:
// RLMArray<TestModel>
RLM_ARRAY_TYPE(TestModel)

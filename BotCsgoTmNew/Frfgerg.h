//
//  Frfgerg.h
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 11.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Realm/Realm.h>

@interface Frfgerg : RLMObject
<# Add properties here to define the model #>
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Frfgerg>
RLM_ARRAY_TYPE(Frfgerg)

//
//  ViewController.m
//  BotCsgoTmNew
//
//  Created by Nikolay Berlioz on 08.05.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import "MainViewController.h"
#import "ServerManager.h"
#import "SteamManager.h"
#import "ItemModel.h"

//==========   Keys for Save and Load   =======
static NSString *kSaveApiKey         = @"KeyAPI";
static NSString *kSaveDiscountKey    = @"KeyDiscount";
static NSString *kSaveComissionKey   = @"KeyComission";

@interface MainViewController () <NSTableViewDataSource, NSControlTextEditingDelegate>

//==============   IBOutlets   ================
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *urlField;
@property (weak) IBOutlet NSTextField *apiKeyField;
@property (weak) IBOutlet NSTextField *yourDiscountField;
@property (weak) IBOutlet NSTextField *yourComissionField;

//==============   IBActions   ================
- (IBAction)addItemActions:(NSButton *)sender;
- (IBAction)delRowAction:(NSButton *)sender;
- (IBAction)startBotAction:(NSButton *)sender;
- (IBAction)stopBotAction:(NSButton *)sender;

- (IBAction)testButtonAction:(NSButton *)sender;

//==============   Data for TableView   =======
@property RLMResults<ItemModel *> *items;

//==============   Help Properties   ==========
@property (assign, nonatomic) NSInteger countItemsIndex;
@property (strong, nonatomic) NSString *offerId;


//==============   Timers   ===================
@property (strong, nonatomic) NSTimer *mainRefreshDataTimer;
@property (strong, nonatomic) NSTimer *receiptTradeOffersTimer;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //берем все объекты сохраненные в Realm
    self.items = [ItemModel allObjects];

    
    [self loadTextFields];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.countItemsIndex = 0;
        
        self.mainRefreshDataTimer = nil;
    }
    return self;
}

#pragma mark - Steam API

- (void) getTradeOfferWithOfferId:(NSString*)offerId
{
    [[SteamManager sharedManager] getTradeOfferWithId:offerId onSuccess:^(NSString *response) {
        
       // NSLog(@"%@", response);
        
        NSRange range = [response rangeOfString:@"О не-е-е-е-е-е-е-т!"];
        
        if (range.location != NSNotFound)
        {
            NSLog(@"PartnerId or SessionId is NIL!");
        }
        else
        {
            NSString *partnerId = [self getPartnerIdWithResponse:response];
            NSString *sessionId = [self getSessionIdWithResponse:response];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self acceptTradeOfferWithOfferId:self.offerId sessionId:sessionId partnerId:partnerId];
                
            });
        }
        
        
        
    } onFailure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void) acceptTradeOfferWithOfferId:(NSString*)offerId
                           sessionId:(NSString*)sessionId
                           partnerId:(NSString*)partnerId
{
    [[SteamManager sharedManager] acceptTradeOfferWithTradeOfferId:offerId
                                                         sessionId:sessionId
                                                         partnerId:partnerId
    onSuccess:^(NSString *response) {
        
        if (response)
        {
            NSLog(@"Accept offer response: %@", response);
        }
        else
        {
            NSLog(@"Trade is accepted!");
        }
        
    } onFailure:^(NSError *error) {
        NSLog(@"acceptTradeOfferWithTradeOfferId error = %@", [error localizedDescription]);
    }];
}

#pragma mark - Csgo.tm API

- (void) checkItemStatus
{
    [[ServerManager sharedManager]
     checkItemsStatusWithAPIKey:self.apiKeyField.stringValue
     onSuccess:^(NSArray *trades) {
         
         if ([trades count] > 0)
         {
             for (NSDictionary *dict in trades)
             {
                 //если статус предмета = 4(вещь готова к выводу)
                 if ([[dict objectForKey:@"ui_status"] isEqualToString:@"4"])
                 {
                     //получаем ид бота
                     NSString *botId = [dict objectForKey:@"ui_bid"];
                     BOOL fromBot = YES;
                     
                     //получаем вещь от бота
                     [self sendItemFromBotWithBotId:botId fromBot:fromBot];
                     
                     break;
                 }
             }
         }
         
     }
     onFailure:^(NSError *error) {
         NSLog(@"changeOrderWithItem %@", [error description]);
     }];
}

- (void) sendItemFromBotWithBotId:(NSString*)botId
                          fromBot:(BOOL)fromBot
{
    [[ServerManager sharedManager]
     sendItemFromBotWithAPIKey:self.apiKeyField.stringValue
     fromBot:fromBot
     botId:botId
     onSuccess:^(NSString *offerId) {
         
         //если офферид уже готов принимаем его
         if (offerId != nil)
         {
             self.offerId = offerId;
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 //через 5 сек делаем первый запрос к стиму
                 [self getTradeOfferWithOfferId:offerId];
                 
             });
         }
        
    } onFailure:^(NSError *error) {
        NSLog(@"changeOrderWithItem %@", [error description]);
    }];
}

- (void) changeOrderWithItem:(ItemModel*)item
{
    if (item.maxOrder < item.budget)
    {
        [[ServerManager sharedManager]
         changeOrderWithInstanceId:item.instanceId
         classId:item.classId
         apiKey:self.apiKeyField.stringValue
         price:[NSString stringWithFormat:@"%ld", item.maxOrder + 1]
         onSuccess:^(NSString *message) {
            
        } onFailure:^(NSError *error) {
            NSLog(@"changeOrderWithItem %@", [error description]);
        }];
    }
}

- (void) newOrderWithItem:(ItemModel*)item
{
    if (item.maxOrder < item.budget)
    {
        [[ServerManager sharedManager]
         getNewOrderWithInstanceId:item.instanceId
         classId:item.classId
         apiKey:self.apiKeyField.stringValue
         price:[NSString stringWithFormat:@"%ld", item.maxOrder + 1]
         hash:item.hashName
         onSuccess:^(NSString *message) {
             
         } onFailure:^(NSError *error) {
             NSLog(@"newOrderWithItem %@", [error description]);
         }];
    }
}

- (void) checkOrdersWithItem:(ItemModel*)item
{
    [[ServerManager sharedManager]
     getOrdersWithApiKey:self.apiKeyField.stringValue
     onSuccess:^(NSMutableArray *orders) {
        
         BOOL orderExist = NO;
         
         // если нет ни одного ордера - сразу вызываем newOrderWithItem
         if ([orders count] > 0)
         {
             for (NSDictionary *dict in orders)
             {
                 //если такой ордер уже существует - orderExist = YES и прерываем цикл
                 if ([[dict objectForKey:@"i_market_name"] isEqualToString:item.marketName])
                 {
                     orderExist = YES;
                     
                     //меняю если нужно цену ордера
                     [self changeOrderWithItem:item];
                     break;
                 }
             }
             //если цикл закончился без прерываний и orderExist = NO, тогда добавляем ордер
             if (!orderExist)
             {
                 [self newOrderWithItem:item];
             }
         }
         else
         {
             [self newOrderWithItem:item];
         }
        
    } onFailure:^(NSError *error) {
        NSLog(@"checkOrdersWithItem %@", [error description]);
    }];
}

- (void) refreshPriceAndOrderWithItem:(ItemModel*)existItem
{
    [[ServerManager sharedManager]
     getRefreshPriceAndOrderWithInstanceId:existItem.instanceId
     classId:existItem.classId
     apiKey:self.apiKeyField.stringValue
     onSuccess:^(ItemModel *item) {
         
         //проверка: выставлен ли такой ордер
         [self checkOrdersWithItem:existItem];
         
         //если значения изменились - перезаписываем их
         if (existItem.minPrice != item.minPrice || existItem.maxOrder != item.maxOrder)
         {
             // Получаем ссылку на Realm по умолчанию
             RLMRealm *realm = [RLMRealm defaultRealm];
             
             // Изменяем цену и ордер объекта, затем записываем новые значения
             [realm beginWriteTransaction];
             
             existItem.minPrice = item.minPrice;
             existItem.maxOrder = item.maxOrder;
             
             [realm commitWriteTransaction];
             
             [self.tableView reloadData];
         }
        
    } onFailure:^(NSError *error) {
        
        NSLog(@"%@", [error description]);
        
    }];
}

- (void) getItemInfo
{
    NSString *classId = [self getClassId];
    NSString *instanceId = [self getInstanceId];
    
    [[ServerManager sharedManager]
     getItemInfoWithInstanceId:instanceId
                       classId:classId
                        apiKey:self.apiKeyField.stringValue
                     onSuccess:^(ItemModel *item) {
                         
                         // Получаем ссылку на Realm по умолчанию
                         RLMRealm *realm = [RLMRealm defaultRealm];
                         
                         // Добавляем объект в Realm транзакцией:
                         [realm beginWriteTransaction];
                         [realm addObject:item];
                         [realm commitWriteTransaction];
                         
                         [self.tableView reloadData];
                         
    }
                    onFailure:^(NSError *error) {
        
                        NSLog(@"%@", [error description]);
        
    }];
}

#pragma mark - NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    /*
    Если хотим редактировать ячейки buyerPays, quantity или budget - разрешаем,
    иначе - не разрешаем.
    */
    if ([tableColumn.identifier isEqualToString:@"buyerPays"] ||
        [tableColumn.identifier isEqualToString:@"quantity"] ||
        [tableColumn.identifier isEqualToString:@"budget"])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == self.tableView)
    {
        return self.items.count;
    }
    
    return 0;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row;
{
    if (tableView == self.tableView)
    {
        NSString *ident = tableColumn.identifier; // Получаем значение Identifier колонки
        
        ItemModel* item = self.items[row]; // получаем объект данных для строки
        
        return [item valueForKey:ident]; // Возвращаем значение соответствующего свойства
    }
    
    return nil;
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row != -1)
    {
        if(tableView == self.tableView)
        {
            NSString* ident = tableColumn.identifier;
            
            ItemModel* item = self.items[row];
            
            // Получаем ссылку на Realm по умолчанию
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            
            [realm beginWriteTransaction];
            
            [item setValue:object forKey:ident]; //Устанавливаем значение для соответствующего свойства
            
            /*
            Когда значение меняется в ячейке buyerPays - меняем так же и значение ячейки youReceive
            с учетом нашей комиссии. И записываем все в Realm
            */
            if ([tableColumn.identifier isEqualToString:@"buyerPays"])
            {
                CGFloat buyerPays = [object doubleValue];
                
                NSInteger youReceive = buyerPays - ((buyerPays / 100) * self.yourComissionField.doubleValue);
                
                NSNumber *numbBuyerYouReceive = [NSNumber numberWithInteger:youReceive];
                
                [item setValue:numbBuyerYouReceive forKey:@"youReceive"];
            }
            
            [realm commitWriteTransaction];  // затем сохраняем новое значение объекта в Realm
        }
    }
}

#pragma mark - Private Methods

- (void) launchRefreshItemInfo
{
    ItemModel *item = self.items[self.countItemsIndex];
    
    // каждый раз при запуске таймером этого метода обновляем по порядку каждый итем
    if (self.items.count)
    {
        [self refreshPriceAndOrderWithItem:item];
        
        self.countItemsIndex++;
        
        // когда индекс станет равным количеству объектов в Realm - обнуляем его
        if (self.countItemsIndex == self.items.count)
        {
            self.countItemsIndex = 0;
        }
    }
}

- (NSString*) getSessionIdWithResponse:(NSString*)response
{
    NSString *result = response;
    
    //ищем "var g_sessionID" в ответе
    NSRange range = [result rangeOfString:@"var g_sessionID"];
    
    //обрезаем от "var g_sessionID" + 19 символа
    if (range.location != NSNotFound)
    {
        result = [result substringFromIndex:range.location + 19];
    }
    
    //ищем ";"
    NSRange range2 = [result rangeOfString:@";"];
    
    //обрезаем по ";"
    if (range2.location != NSNotFound)
    {
        result = [result substringToIndex:range2.location - 1];
    }
    
    return result;
}

- (NSString*) getPartnerIdWithResponse:(NSString*)response
{
    NSString *result = response;
    
    //ищем "var g_ulTradePartnerSteamID" в ответе
    NSRange range = [result rangeOfString:@"var g_ulTradePartnerSteamID"];
    
    //обрезаем от "var g_ulTradePartnerSteamID" + 31 символа
    if (range.location != NSNotFound)
    {
        result = [result substringFromIndex:range.location + 31];
    }
    
    //ищем "'"
    NSRange range2 = [result rangeOfString:@"'"];
    
    //обрезаем по "'"
    if (range2.location != NSNotFound)
    {
        result = [result substringToIndex:range2.location];
    }
    
    return result;
}

- (NSString*) getInstanceId
{
    NSString *instanceId = self.urlField.stringValue;
    
    //ищем "-"
    NSRange range = [instanceId rangeOfString:@"-"];
    
    //обрезаем от "-"
    if (range.location != NSNotFound)
    {
        instanceId = [instanceId substringFromIndex:range.location + 1];
    }
    
    //еще раз ищем "-"
    NSRange range2 = [instanceId rangeOfString:@"-"];
    
    //обрезаем по "-"
    if (range2.location != NSNotFound)
    {
        instanceId = [instanceId substringToIndex:range2.location];
    }
    
    return instanceId;
}

- (NSString*) getClassId
{
    NSString *classId = self.urlField.stringValue;
    
    NSCharacterSet *decimalSet = [NSCharacterSet decimalDigitCharacterSet];
    
    //ищем начало первую цифру
    NSRange range = [classId rangeOfCharacterFromSet:decimalSet];
    
    //если нашли такой элемент обрезаем начало строки
    if (range.location != NSNotFound)
    {
        classId = [classId substringFromIndex:range.location];
    }
    
    //ищем "-"
    NSRange range2 = [classId rangeOfString:@"-"];
    
    //обрезаем до "-"
    if (range.location != NSNotFound)
    {
        classId = [classId substringToIndex:range2.location];
    }
    
    return classId;
}

#pragma mark - Actions

- (IBAction)addItemActions:(NSButton*)sender
{
    [self getItemInfo];
    
    self.urlField.stringValue = @"";
}

- (IBAction)delRowAction:(NSButton*)sender
{
    NSInteger row = self.tableView.selectedRow; //берем номер выбранной строки
    
    if(row != -1)
    {
        [self.tableView abortEditing];
        
        // Получаем ссылку на Realm по умолчанию
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        [realm beginWriteTransaction];
        [realm deleteObject:self.items[row]]; //удаляем выбранный объект
        [realm commitWriteTransaction];  // записываем 
        
        [self.tableView reloadData];
    }
}

- (IBAction)startBotAction:(NSButton *)sender
{
    self.mainRefreshDataTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                                 target:self
                                                               selector:@selector(launchRefreshItemInfo)
                                                               userInfo:nil
                                                                repeats:YES];
    self.receiptTradeOffersTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                                    target:self
                                                                  selector:@selector(checkItemStatus)
                                                                  userInfo:nil
                                                                   repeats:YES];
}

- (IBAction)stopBotAction:(NSButton *)sender
{
    if ([self.mainRefreshDataTimer isValid])
    {
        [self.mainRefreshDataTimer invalidate];
        self.mainRefreshDataTimer = nil;
    }
    
    if ([self.receiptTradeOffersTimer isValid])
    {
        [self.receiptTradeOffersTimer invalidate];
        self.receiptTradeOffersTimer = nil;
    }
}

- (IBAction)testButtonAction:(NSButton *)sender
{
    //call test method
    
}


#pragma mark - Save and Load TextFields

- (void) saveTextFields
{
    [[NSUserDefaults standardUserDefaults] setObject:self.apiKeyField.stringValue forKey:kSaveApiKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.yourDiscountField.stringValue forKey:kSaveDiscountKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.yourComissionField.stringValue forKey:kSaveComissionKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadTextFields
{
    self.apiKeyField.stringValue = [self getValueFromDefaultWith:kSaveApiKey];
    self.yourDiscountField.stringValue = [self getValueFromDefaultWith:kSaveDiscountKey];
    self.yourComissionField.stringValue = [self getValueFromDefaultWith:kSaveComissionKey];
}

- (NSString *)getValueFromDefaultWith:(NSString *)key
{
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    return result.length > 0 ? result : @""; //если длинна строки меньше 0, возвр пустую строку
}

#pragma  mark - NSControlTextEditingDelegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    [self saveTextFields];
    
    return YES;
}


@end





































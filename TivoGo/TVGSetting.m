//
//  TVGSetting.m
//  TivoGo
//
//  Created by BiXiaopeng on 14-1-24.
//  Copyright (c) 2014年 BiXiaopeng. All rights reserved.
//

#import "TVGSetting.h"

@interface TVGSetting ()

@property (nonatomic)NSMutableDictionary* storageDic;
@property (nonatomic)NSString *settingFilePath;
@end

@implementation TVGSetting
@synthesize storageDic = _storageDic;
@synthesize settingFilePath = _settingFilePath;
@synthesize sum=_sum;
static TVGSetting *sInstance=nil;

+(TVGSetting *)getInstnce{
    if (sInstance==nil) {
        sInstance = [[TVGSetting alloc]init];
    }
    return  sInstance;
}

-(NSString *)settingFilePath{
    if (_settingFilePath==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
       _settingFilePath= [docDir stringByAppendingString:@"/game_settings.plist"];
    }
    return _settingFilePath;
}

-(BOOL)useBGM{
    return    [self getBoolPropForKey:@"bgm" withDefault:YES];
}
-(BOOL)useCountTime{
    return    [self getBoolPropForKey:@"time" withDefault:NO];
}
-(BOOL)useKomi{
    return    [self getBoolPropForKey:@"komi" withDefault:YES];
}
-(BOOL)useSound{
    return    [self getBoolPropForKey:@"sound" withDefault:YES];
}
-(BOOL)isChineseRule{
    return    [self getBoolPropForKey:@"chinese" withDefault:YES];
}
-(BOOL)useBlack{
    return    [self getBoolPropForKey:@"useBlack" withDefault:YES];
}

-(BOOL)firstOpen{
    if ([self getBoolPropForKey:@"firstOpen" withDefault:YES]) {
        [self.storageDic setObject:[NSNumber numberWithBool:NO] forKey:@"firstOpen"];
        [self flush];
        return YES;
    }
    return NO;
}

-(void)setUseBGM:(BOOL)useBGM{
    [self.storageDic setObject:[NSNumber numberWithBool:useBGM] forKey:@"bgm"];
}
-(void)setUseCountTime:(BOOL)useCountTime{
    [self.storageDic setObject:[NSNumber numberWithBool:useCountTime] forKey:@"time"];
}
-(void)setUseKomi:(BOOL)useKomi{
    [self.storageDic setObject:[NSNumber numberWithBool:useKomi] forKey:@"komi"];
}
-(void)setUseSound:(BOOL)useSound{
    [self.storageDic setObject:[NSNumber numberWithBool:useSound] forKey:@"sound"];
}
-(void)setIsChineseRule:(BOOL)isChineseRule{
    [self.storageDic setObject:[NSNumber numberWithBool:isChineseRule] forKey:@"chinese"];
}
-(void)setUseBlack:(BOOL)useBlack{
    [self.storageDic setObject:[NSNumber numberWithBool:useBlack] forKey:@"useBlack"];
}


-(BOOL)getBoolPropForKey:(NSString *)key withDefault:(BOOL)defVal{
    NSNumber* rtn = [self.storageDic objectForKey:key];
    return rtn?[rtn boolValue]:defVal;
}

-(void)flush{
    [self.storageDic writeToFile:self.settingFilePath atomically:YES];
}
-(TVGSetting *)init{
    self  = [super init];
    if (self) {
        if ([[NSFileManager defaultManager]fileExistsAtPath:self.settingFilePath]) {
            self.storageDic = [[NSMutableDictionary alloc]initWithContentsOfFile:self.settingFilePath];
            NSLog(@"%@",self.settingFilePath);
        }else{
            self.storageDic = [[NSMutableDictionary alloc]init];
        }
    }
    return self;
}
- (NSString *) sum
{
    NSMutableString* sum = [NSMutableString stringWithCapacity:4];
    [sum appendString:self.useBlack?@"1":@"0"];
    [sum appendString:self.useCountTime?@"1":@"0"];
    [sum appendString:self.isChineseRule?@"1":@"0"];
    [sum appendString:self.useKomi?@"1":@"0"];

    return sum;
}
@end

//
//  TVGSettingViewController.m
//  TivoGo
//
//  Created by BiXiaopeng on 14-1-4.
//  Copyright (c) 2014年 BiXiaopeng. All rights reserved.
//

#import "TVGSettingViewController.h"
#import "TVGSetting.h"
@interface TVGSettingViewController ()

@end

@implementation TVGSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    TVGSetting *stg = [TVGSetting getInstnce];
    self.bgm.on = stg.useBGM ;
self.countTime.on =     stg.useCountTime;
self.komi.on    =stg.useKomi;
self.sound.on=    stg.useSound;
    self.rule.selectedSegmentIndex = stg.isChineseRule?0:1;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPushed:(UIButton *)sender {
    [self save];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)save{
    TVGSetting *stg = [TVGSetting getInstnce];
    stg.useBGM = self.bgm.on;
    stg.useCountTime=self.countTime.on;
    stg.useKomi=self.komi.on;
    stg.useSound=self.sound.on;
    NSLog(@"%d is set",self.rule.selectedSegmentIndex);
    stg.isChineseRule =(self.rule.selectedSegmentIndex==0);
    [stg flush];
}

@end

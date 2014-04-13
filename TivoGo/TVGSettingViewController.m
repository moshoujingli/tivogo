//
//  TVGSettingViewController.m
//  TivoGo
//
//  Created by BiXiaopeng on 14-1-4.
//  Copyright (c) 2014年 BiXiaopeng. All rights reserved.
//

#import "TVGSettingViewController.h"
#import "TVGSetting.h"
#import "UIImage+Tint.h"

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
    self.useBlack.on = stg.useBlack;
    self.rule.selectedSegmentIndex = stg.isChineseRule?0:1;
    UIImage *image = self.backBtn.image;
    self.backBtn.image = [image imageWithTintColor:[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]];
    self.backBtn.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backPushed:)];
    [self.backBtn addGestureRecognizer:tapBack];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPushed:(id )sender {
    [self save];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)save{
    TVGSetting *stg = [TVGSetting getInstnce];
    stg.useBGM = self.bgm.on;
    stg.useCountTime=self.countTime.on;
    stg.useKomi=self.komi.on;
    stg.useSound=self.sound.on;
    stg.isChineseRule =(self.rule.selectedSegmentIndex==0);
    stg.useBlack = self.useBlack.on;
    [stg flush];
}

@end

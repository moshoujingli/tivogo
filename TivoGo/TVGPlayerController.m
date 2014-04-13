//
//  TVGSinglePlayerController.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-11.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGPlayerController.h"
#import "TVGSetting.h"
@interface TVGPlayerController ()
@property (nonatomic,readonly) int whoPlayThisMove;
@property  (nonatomic)Gameinfo gameInfo;
@property (nonatomic)dispatch_queue_t computeQueue;
@property (nonatomic)BOOL isThingking;
@property (nonatomic)NSThread *thinkThread;
@property (nonatomic)int whiteTime;
@property (nonatomic)int blackTime;
@property AVAudioPlayer *bgmSound;
@property SystemSoundID makePieceSound;
@property SystemSoundID killSound;
@property NSArray *timeCounterLabels;
@property NSTimeInterval *timeCounters;
@property NSTimeInterval timer;
@property NSDateFormatter *dateFormatter;
@property NSTimer* timerTic;
@property int passPushedCount;
@property (nonatomic)TVGSetting *settingStroge;
@end

@implementation TVGPlayerController
@synthesize whoPlayThisMove=_whoPlayThisMove;
@synthesize isSingle=_isSingle;
@synthesize gameInfo=_gameInfo;
@synthesize computeQueue=_computeQueue;
@synthesize isThingking=_isThingking;
@synthesize settingStroge=_settingStroge;

-(TVGSetting *)settingStroge{
    return [TVGSetting getInstnce];
}
-(CGPoint)translateLocToIndex:(CGPoint)pos{
    float spec = self.board.spec;
    pos.x=(int)((pos.x-PIECE_OUTSIDE_SPEC)/spec+0.5);
    pos.y=(int)((pos.y-PIECE_OUTSIDE_SPEC)/spec+0.5);
    return pos;
}

- (void)makeMoveTo:(CGPoint)pos withColor:(int)color {
    pos=[self translateLocToIndex:pos];
    BOOL do_play= [self.board setPiece:color at:pos.x and:pos.y];
    [self.board indicate:EMPTY at:0 and:0];
    if(do_play) {
        //change time counter
        [self refreshTimerLabel];
        AudioServicesPlaySystemSound(self.makePieceSound);
        _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
        if (self.isSingle) {
            self.isThingking=YES;
            self.thinkThread = [[NSThread alloc]initWithTarget:self selector:@selector(getMove) object:nil];
            [self.thinkThread setStackSize:(4096*512*20)];
            [self.thinkThread start];
        }
    }
}


-(void)refreshTimerLabel{
    NSTimeInterval nowTime = [[NSDate date]timeIntervalSince1970];
    NSTimeInterval time_use = nowTime-self.timer;
    self.timer = nowTime;
    self.timeCounters[self.whoPlayThisMove]+=time_use;
    if (self.timeCounters[self.whoPlayThisMove]>=3600*2) {
        
    }
    NSString *timeNowPlayer = [self.dateFormatter stringFromDate:
                               [NSDate dateWithTimeIntervalSince1970:(3600*2-self.timeCounters    [self.whoPlayThisMove])]];
    UILabel *curConterLabel = [self.timeCounterLabels objectAtIndex:self.whoPlayThisMove-1];
    curConterLabel.text = timeNowPlayer;
}

-(void)timeIsOver{
    [self.timerTic invalidate];
    //alert
}

-(void)refresh:(NSNumber *)move{
    [self.board setPiece:self.whoPlayThisMove at:I(move.intValue) and:J(move.intValue)];
    [self refreshTimerLabel];
    _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
    [self.board setNeedsDisplay];
    self.isThingking=NO;
    AudioServicesPlaySystemSound(self.makePieceSound);
}

-(void)getMove{
    int move = genmove(self.whoPlayThisMove, NULL, NULL);
    [self performSelectorOnMainThread:@selector(refresh:) withObject:[[NSNumber alloc]initWithInt:move] waitUntilDone:YES];
}

-(void)makeIndicateTo:(CGPoint)pos withColor:(int)color{
    pos=[self translateLocToIndex:pos];
    [self.board indicate:color at:pos.x and:pos.y];
}


- (IBAction)tap:(UITapGestureRecognizer *)sender {
    if (self.isThingking) {
        return;
    }
    if (sender.state==UIGestureRecognizerStateEnded) {
        [self makeMoveTo:[sender locationInView:self.board] withColor:self.whoPlayThisMove];
    }
}
- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    if (self.isThingking) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint pos = [sender locationInView:self.board];
        [self    makeIndicateTo:pos withColor:self.whoPlayThisMove];
    }else if(sender.state == UIGestureRecognizerStateEnded){
        [self makeMoveTo:[sender locationInView:self.board] withColor:self.whoPlayThisMove];
    }
}
- (IBAction)retractPushed:(UIButton *)sender {
    if (self.isThingking) {
        return;
    }
    if (self.isSingle) {
        [self.board undo:2];
    }else{
        [self.board undo:1];
        _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
    }
    

}
- (IBAction)reportCountPUshed:(UIButton *)sender {
    
    __weak TVGPlayerController *ctx = self;
    __weak UIButton* tricker  = sender;
    self.isThingking=true;
    [sender setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        float score = gnugo_estimate_score(NULL,NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Title" message:@"message" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            
            NSString *part = @"白";
            float scoreShow = score;
            if (score<0) {
                part = @"黑";
                scoreShow = -score;
            }
            scoreShow = ((int)(scoreShow/0.5))*0.5;
            alertView.title = @"数子结果";
            
            alertView.message = [NSString stringWithFormat:@"%@当前胜%.1f目",part,scoreShow ];
            [alertView show];
            ctx.isThingking = false;
            [tricker setEnabled:YES];
        });
        
    });
}


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
    CGAffineTransform at =CGAffineTransformMakeScale(1, -1);
    [self.whiteHint setTransform:at];
    [self.blackHint setTransform:at];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"HH:mm:ss"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [self initGame];
    if (self.isSingle) {
        //[alert show];
        //time!
        
    }else{
        at =CGAffineTransformMakeRotation(M_PI);
        [self.whiteCounterLabel setTransform:at];
    }
    [self.countBtn setTitleColor:[UIColor colorWithRed:121/255.0 green:121/255.0 blue:121/255.0 alpha:1.0] forState:UIControlStateDisabled];
    [self.countBtn setTitle:@"数子中" forState:UIControlStateDisabled];
}
- (IBAction)passPushed:(UIButton *)sender {
    self.passPushedCount++;
    [self makeMoveTo:CGPointMake(0, 0) withColor:PASS_MOVE];
    if (self.passPushedCount>=5) {
        [sender setEnabled:NO];
        [sender setTitleColor:[UIColor colorWithRed:121/255.0 green:121/255.0 blue:121/255.0 alpha:1.0] forState:UIControlStateDisabled];
        return;
    }

}
-(void)initGame{
    _whoPlayThisMove=BLACK;
    gameinfo_clear(&(_gameInfo));
    

    
    SystemSoundID soundID=0;
    NSURL *url = [NSURL fileURLWithPath:[NSString
                                         stringWithFormat:@"%@/move.wav",  [[NSBundle mainBundle]  resourcePath]]];
    if (self.settingStroge.useSound) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &(soundID));
        self.makePieceSound  = soundID;
        url = [NSURL fileURLWithPath:[NSString
                                      stringWithFormat:@"%@/kill.wav",  [[NSBundle mainBundle]  resourcePath]]];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &(soundID));
        self.killSound = soundID;
        url = [NSURL fileURLWithPath:[NSString
                                      stringWithFormat:@"%@/city.mp3",  [[NSBundle mainBundle]  resourcePath]]];
        
        
        self.board.removeDelegate = self;
    }

    if (self.settingStroge.useBGM) {
        self.bgmSound = [[AVAudioPlayer alloc]initWithContentsOfURL:url fileTypeHint:@"mp3" error:NULL];
        self.bgmSound.volume = 0.05f;
        [self.bgmSound play];
        
    }
    
    self.timeCounters = calloc(3, sizeof(NSTimeInterval));
    self.timeCounters[0]=self.timeCounters[1]=0;
    self.timer  = [[NSDate date]timeIntervalSince1970];
    self.timerTic = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshTimerLabel) userInfo:nil repeats:YES];
    if (!self.settingStroge.useCountTime) {
        [self.timerTic invalidate];
    }
    if (self.settingStroge.useKomi) {
        komi=7.5;
    }
    if (self.settingStroge.isChineseRule) {
        chinese_rules=1;
    }else{
        chinese_rules=0;
    }
    if (self.isSingle&&!self.settingStroge.useBlack) {
        self.isThingking=YES;
        self.thinkThread = [[NSThread alloc]initWithTarget:self selector:@selector(getMove) object:nil];
        [self.thinkThread setStackSize:(4096*512*20)];
        [self.thinkThread start];
        UIImage *blackImg = self.blackHint.image;
        self.blackHint.image = self.whiteHint.image;
        self.whiteHint.image = blackImg;
        self.timeCounterLabels = [NSArray arrayWithObjects:self.blackCounterLabel,self.whiteCounterLabel, nil];
    }else{
        self.timeCounterLabels = [NSArray arrayWithObjects:self.whiteCounterLabel,self.blackCounterLabel, nil];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPushed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.thinkThread cancel];

    [self.timerTic invalidate];
    
    if (self.settingStroge.useBGM) {
        [self.bgmSound stop];
    }
    if (self.settingStroge.useSound) {
        AudioServicesRemoveSystemSoundCompletion(self.killSound);
        AudioServicesRemoveSystemSoundCompletion(self.makePieceSound);
    }

}

-(void)eatOccur{
    AudioServicesPlaySystemSound(self.killSound);
}

@end

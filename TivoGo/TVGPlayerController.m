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
@property NSData* saveData;
@property int* stepRecord;
@property int stepCount;
@end

@implementation TVGPlayerController
@synthesize whoPlayThisMove=_whoPlayThisMove;
@synthesize isSingle=_isSingle;
@synthesize gameInfo=_gameInfo;
@synthesize computeQueue=_computeQueue;
@synthesize isThingking=_isThingking;
@synthesize settingStroge=_settingStroge;
@synthesize timeCounters = _timeCounters;

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
        AudioServicesPlaySystemSound(self.makePieceSound);
        [self refreshTimerLabel];
        self.stepRecord[self.stepCount++]=POS(pos.x, pos.y);
        [self saveGame];
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
    NSString *timeNowPlayer;
    NSString *timeOtherPlayer;
    UIColor* curCounterColor;
    if (self.settingStroge.useCountTime) {
        NSTimeInterval nowTime = [[NSDate date]timeIntervalSince1970];
        NSTimeInterval time_use = nowTime-self.timer;
        self.timer = nowTime;
        self.timeCounters[self.whoPlayThisMove]+=time_use;
        if (self.timeCounters[self.whoPlayThisMove]>=3600*2) {
            self.timeCounters[self.whoPlayThisMove] = 3600*2;
        }
        curCounterColor = [self getColorByTime:self.timeCounters[self.whoPlayThisMove]];
        timeNowPlayer = [self.dateFormatter stringFromDate:
                         [NSDate dateWithTimeIntervalSince1970:(3600*2-self.timeCounters[self.whoPlayThisMove])]];
        timeOtherPlayer = [self.dateFormatter stringFromDate:
                         [NSDate dateWithTimeIntervalSince1970:(3600*2-self.timeCounters[OTHER_COLOR(self.whoPlayThisMove)])]];
    }else{
        timeNowPlayer = NSLocalizedString(@"Thinking", nil);
        timeOtherPlayer =NSLocalizedString(@"Waiting", nil);
        curCounterColor =[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0];
    }
    UILabel* otherConterLabel = [self.timeCounterLabels objectAtIndex:self.whoPlayThisMove%2];
    otherConterLabel.textColor =[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] ;
    otherConterLabel.text = timeOtherPlayer;
    
    UILabel *curConterLabel = [self.timeCounterLabels objectAtIndex:self.whoPlayThisMove-1];
    curConterLabel.text = timeNowPlayer;
    curConterLabel.textColor = curCounterColor;
}

-(UIColor* )getColorByTime:(NSTimeInterval) time{
    UIColor* color;
    if (time>=(3600*2-60)) {
        color =[UIColor colorWithRed:145/255.0 green:29/255.0 blue:81/255.0 alpha:1.0];
    }else if (time>=(3600*2-60*15)){
        color =[UIColor colorWithRed:146/255.0 green:142/255.0 blue:27/255.0 alpha:1.0];
    }else{
        color =[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0];
    }
    return color;
}

-(void)timeIsOver{
    [self.timerTic invalidate];
    //alert
}

-(void)refresh:(NSNumber *)move{
    [self.board setPiece:self.whoPlayThisMove at:I(move.intValue) and:J(move.intValue)];
    _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
    [self refreshTimerLabel];
    [self.board setNeedsDisplay];
    self.isThingking=NO;
    AudioServicesPlaySystemSound(self.makePieceSound);
    self.stepRecord[self.stepCount++]=move.intValue;
    [self saveGame];

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
        [self.view makeToast:NSLocalizedString(@"isThinking", nil) duration:1 position: [NSValue valueWithCGPoint:CGPointMake(933-50, 768/2)]];
        return;
    }
    if (self.isSingle) {
        if ([self.board undo:2]) {
            self.stepRecord[--self.stepCount]=0;
            self.stepRecord[--self.stepCount]=0;
        }
    }else{
        if ([self.board undo:1]) {
            _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
            self.stepRecord[--self.stepCount]=0;
        }
    }
    

}
- (IBAction)reportCountPushed:(UIButton *)sender {
    
    __weak TVGPlayerController *ctx = self;
    __weak UIButton* tricker  = sender;
    self.isThingking=true;
    [sender setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        float score = gnugo_estimate_score(NULL,NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *part = NSLocalizedString(@"White", nil);
            float scoreShow = score;
            if (score<0) {
                part = NSLocalizedString(@"Black", nil);
                scoreShow = -score;
            }
            scoreShow = ((int)(scoreShow/0.5))*0.5;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CountResult", nil)message:[NSString stringWithFormat:NSLocalizedString(@"WinFormat", nil),part,scoreShow ] delegate:nil cancelButtonTitle:NSLocalizedString(@"ConfirmResult", nil) otherButtonTitles:nil];
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
    self.isThingking=YES;
    CGAffineTransform at =CGAffineTransformMakeScale(1, -1);
    [self.whiteHint setTransform:at];
    [self.blackHint setTransform:at];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"HH:mm:ss"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    if (!self.isSingle) {
        at =CGAffineTransformMakeRotation(M_PI);
        [self.whiteCounterLabel setTransform:at];
    }
    [self.countBtn setTitleColor:[UIColor colorWithRed:121/255.0 green:121/255.0 blue:121/255.0 alpha:1.0] forState:UIControlStateDisabled];
    [self.countBtn setTitle:NSLocalizedString(@"IsCounting", nil) forState:UIControlStateDisabled];
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

    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.saveData = [self getSavedData];
    if ([self.saveData length]==(400*sizeof(int)+3*sizeof(NSTimeInterval)+sizeof(short)+sizeof(_whoPlayThisMove))) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StartGame", nil) message:NSLocalizedString(@"IfRestore", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NewGame", nil) otherButtonTitles:NSLocalizedString(@"ConfirmLoad", nil), nil];
        [alertView show];
    }else{
        self.isThingking=NO;
        [self initGame];
    }
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
    self.stepRecord = calloc(400, sizeof(int));
    self.stepCount = 0;
    self.timeCounters = calloc(3, sizeof(NSTimeInterval));
    self.timeCounters[0] = self.timeCounters[1]=self.timeCounters[2]=0;
    self.timer  = [[NSDate date]timeIntervalSince1970];
    self.timerTic = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(refreshTimerLabel) userInfo:nil repeats:YES];
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
    if (!self.settingStroge.useCountTime) {
        [self.timerTic invalidate];
        [self refreshTimerLabel];
    }
    
}
-(void)saveGame{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName;
    if (self.isSingle) {
        fileName = @"board_info_single";
    }else{
        fileName = @"board_info";
    }
    fileName = [fileName stringByAppendingString:self.settingStroge.sum];
    NSString *myFile = [documentsDirectory stringByAppendingPathComponent:fileName];

    NSData *timeData = [NSData dataWithBytes:_timeCounters length:3*sizeof(NSTimeInterval)];
    NSData *whoData = [NSData dataWithBytes:&(_whoPlayThisMove) length:sizeof(_whoPlayThisMove)];
    NSData *playData = [NSData dataWithBytes:self.stepRecord length:400*sizeof(int)];
    short status=self.isThingking?1:0;

    NSMutableData* dataToSave = [NSMutableData dataWithData:playData];
    [dataToSave appendData:timeData];
    [dataToSave appendData:whoData];
    [dataToSave appendBytes:&status length:sizeof(short)];
    
    if ([dataToSave writeToFile:myFile atomically:YES]) {
        return;
    } else {
        [NSException raise:@"Write Error" format:@"Cannot write to %@", myFile];
    }

}
-(NSData *)getSavedData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName;
    if (self.isSingle) {
        fileName = @"board_info_single";
    }else{
        fileName = @"board_info";
    }
    fileName = [fileName stringByAppendingString:self.settingStroge.sum];
    NSString *myFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *savedData = [NSData dataWithContentsOfFile:myFile];
    return savedData;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backPushed:(UIButton *)sender {
    if (self.isThingking) {
        [self.view makeToast:NSLocalizedString(@"isThinking", nil) duration:1 position: [NSValue valueWithCGPoint:CGPointMake(933-65, 768/2)]];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.thinkThread cancel];

    [self.timerTic invalidate];
    [self saveGame];
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.isThingking=NO;
    if (buttonIndex) {

        gameinfo_clear(&(_gameInfo));
        self.stepCount=0;
        self.stepRecord =calloc(400, sizeof(int));
        short to_paly=BLACK;
        int loc=0;
        [self.saveData getBytes:self.stepRecord range:NSMakeRange(0, 400*sizeof(int))];
        while ((loc=self.stepRecord[self.stepCount])) {
            [self.board setPiece:to_paly at:I(loc) and:J(loc)];
            to_paly = OTHER_COLOR(to_paly);
            self.stepCount++;
        }
        self.timeCounters = calloc(3, sizeof(NSTimeInterval));
        [self.saveData getBytes: _timeCounters range:NSMakeRange(400*sizeof(int), 3*sizeof(NSTimeInterval))];
        
        [self.saveData getBytes:&_whoPlayThisMove range:NSMakeRange(400*sizeof(int)+3*sizeof(NSTimeInterval), sizeof(_whoPlayThisMove))];
        _whoPlayThisMove = to_paly;
        self.timer  = [[NSDate date]timeIntervalSince1970];
        self.timerTic = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(refreshTimerLabel) userInfo:nil repeats:YES];
        short isComputerPlay=0;
        [self.saveData getBytes:&isComputerPlay range:NSMakeRange(400*sizeof(int)+3*sizeof(NSTimeInterval)+sizeof(_whoPlayThisMove), sizeof(short))];

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
            UIImage *blackImg = self.blackHint.image;
            self.blackHint.image = self.whiteHint.image;
            self.whiteHint.image = blackImg;
            self.timeCounterLabels = [NSArray arrayWithObjects:self.blackCounterLabel,self.whiteCounterLabel, nil];
        }else{
            self.timeCounterLabels = [NSArray arrayWithObjects:self.whiteCounterLabel,self.blackCounterLabel, nil];
        }
        if (isComputerPlay) {
            self.isThingking=YES;
            self.thinkThread = [[NSThread alloc]initWithTarget:self selector:@selector(getMove) object:nil];
            [self.thinkThread setStackSize:(4096*512*20)];
            [self.thinkThread start];
        }
        if (!self.settingStroge.useCountTime) {
            [self.timerTic invalidate];
            [self refreshTimerLabel];
        }
        [self.board sync];
        [self.board setNeedsDisplay];
    }else{
        [self initGame];
    }
}


@end

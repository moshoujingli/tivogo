//
//  TVGWatchSGFViewController.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-3.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGWatchSGFViewController.h"
#import "TVGSetting.h"
@interface TVGWatchSGFViewController ()
@property (nonatomic)NSArray *sgfFileListDataSrc;
@property (nonatomic)NSArray *orgSgfFileList;

@end

@implementation TVGWatchSGFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"now is %@",searchText);
    [self changeListByKeyWord:searchText];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //copy bundles to storage
    if (([TVGSetting getInstnce]).firstOpen) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/sgf"] withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *bundlePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"sgf"];
        for (int i=1; i<40; i++) {
            NSString *fileName = [bundlePath stringByAppendingPathComponent:[ [NSString alloc]initWithFormat:@"%d.sgf",i]];
            TVGSGFTree* testTree=[[TVGSGFTree alloc]initWithFile:fileName];
            NSMutableDictionary *info = testTree.gameInfo;
            NSString * key = @"GN";
            NSString *content = [info objectForKey:key];
            if ([key isEqualToString:@"GN"]) {
                NSString *fileRealNameWithPath = [NSHomeDirectory() stringByAppendingString:[[NSString alloc]initWithFormat:@"/Documents/sgf/%@.sgf",content]];
                if ([[NSFileManager defaultManager]fileExistsAtPath:fileRealNameWithPath]) {
                    continue;
                }
                NSData *sgfcontent = [NSData dataWithContentsOfFile:fileName];
                [sgfcontent writeToFile:fileRealNameWithPath atomically:YES];
            }
            
        }
 
    }
    //check all in storage(md5)
     NSString *fileRealNameWithPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/sgf"];
    NSArray *rawFileSet = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:fileRealNameWithPath error:nil];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[d] %@",@".sgf"];
    self.orgSgfFileList = [rawFileSet filteredArrayUsingPredicate:filter];
    self.sgfFileListDataSrc = self.orgSgfFileList;
    
    [self.sgfFileList reloadData];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"sgfListItem"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sgfListItem"];
    }
    NSString *fileName = [[NSString alloc]initWithFormat:@"%@",[self.sgfFileListDataSrc objectAtIndex:indexPath.row]];
    NSString *showName = [fileName substringToIndex:[fileName length]-4];
    cell.textLabel.text= showName;
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(void)changeListByKeyWord:(NSString *)keyword{
    if ([keyword length]>0) {
        self.sgfFileListDataSrc = [self.orgSgfFileList filteredArrayUsingPredicate:[NSPredicate     predicateWithFormat:@"SELF contains[cd] %@",keyword ]];
    }else{
        self.sgfFileListDataSrc = self.orgSgfFileList;
    }
    [self.sgfFileList reloadData];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count= [self.sgfFileListDataSrc count];
    return  count;
}

- (IBAction)backPushed:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath    {
    gnugo_clear_board(19);
    NSString *fileName = [[NSHomeDirectory() stringByAppendingString:@"/Documents/sgf/"] stringByAppendingString:[self.sgfFileListDataSrc objectAtIndex:indexPath.row]];
    NSLog(@"%@ is select in section",fileName);
    TVGSGFTree *tree = [[TVGSGFTree alloc]initWithFile:fileName];
    TVGSGFNode * node;
    node = [tree getNodeById:[tree getRootNode].nextStepID];
    for (; !node.isLeaf; node=[tree getNodeById:node.nextStepID]) {
        if (node.isMoveNode) {
            //get move locate and color
            NSArray* move = [node getPropertyByName:@"move"];
            TVGMove *mvPoint =  ((TVGSGFProperty *)[move objectAtIndex:0]).propValue;
            [self.board setPiece:mvPoint.player at:mvPoint.x and:mvPoint.y];
        }
    }
}
@end

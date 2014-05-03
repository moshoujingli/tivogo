//
//  TVGWatchSGFViewController.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-3.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGWatchSGFViewController.h"
#import "TVGSetting.h"
#import "UIImage+Tint.h"
#import <objc/runtime.h>

#define PREVTENPASS 1
#define NEXTTENPASS 2
#define PREV 3
#define NEXT 4
#define END 5


@interface TVGWatchSGFViewController ()
@property (nonatomic)NSArray *sgfFileListDataSrc;
@property (nonatomic)NSArray *orgSgfFileList;
@property (nonatomic)NSArray *searchSideBar;
@property (nonatomic)CGFloat sideSpec;
@property (nonatomic)BOOL lookStatus;
@property (nonatomic)TVGSGFTree *curPlayingTree;
@property (nonatomic)TVGSGFNode *curNode;
@property (nonatomic)NSString* curFile;
@property (nonatomic)NSArray* detailCtrls;

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
    // Get the instance of the UITextField of the search bar
    UITextField *searchField = [self.sgfSearchBar valueForKey:@"_searchField"];
    
    // Change search bar text color
    searchField.textColor = [UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0];
    self.searchSideBar  =[ [NSArray alloc]initWithObjects:self.sgfTable,self.sgfSearchBar, nil];
    self.sideSpec = self.sgfSearchBar.frame.origin.x;
    self.lookStatus = NO;
    [self.sgfFileList setBackgroundColor:[UIColor clearColor]];
    [self.sgfSearchBar setBackgroundColor:[UIColor clearColor]];
    self.sgfTitle.text=@"";
    self.sgfDetail.text=@"";
    UIImage *image = self.backBtn.image;
    self.backBtn.image = [image imageWithTintColor:[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]];
    self.backBtn.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backPushed:)];
    [self.backBtn addGestureRecognizer:tapBack];
    
    image = self.toStart.image;
    self.toStart.image = [image imageWithTintColor:[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]];
    image = self.nextTenPass.image;
    self.nextTenPass.image = [image imageWithTintColor:[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]];
    image = self.prevTenPass.image;
    self.prevTenPass.image = [image imageWithTintColor:[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]];
    image = self.nextBtn.image;
    self.nextBtn.image = [image imageWithTintColor:[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]];
    
    
    
    tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(controlPush:)];
    
    self.toStart.userInteractionEnabled=YES;
    [self.toStart addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(controlPush:)]];
    
    self.prevTenPass.userInteractionEnabled=YES;
    [self.prevTenPass addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(controlPush:)]];
    
    self.nextBtn.userInteractionEnabled=YES;
    [self.nextBtn addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(controlPush:)]];
    
    self.nextTenPass.userInteractionEnabled=YES;
    [self.nextTenPass addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(controlPush:)]];

//    self.toEnd.userInteractionEnabled=YES;
//    [self.toEnd addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(controlPush:)]];
    
    self.toStart.tag = PREVTENPASS;
    self.nextTenPass.tag = NEXTTENPASS;
    self.prevTenPass.tag = PREV;
    self.nextBtn.tag = NEXT;
//    self.toEnd.tag = END;
    self.detailCtrls = [[NSArray alloc]initWithObjects:self.toStart ,self.nextTenPass,self.prevTenPass,self.nextBtn, self.sgfComment,self.player,nil];
    for (UIView* view in self.detailCtrls) {
       view.alpha = 0;
    }
}





-(void)controlPush:(UIGestureRecognizer *)gestureRecognizer {
    UIView *tappedView = gestureRecognizer.view;//[gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
    int loop=9;

    switch(tappedView.tag){
        case  PREVTENPASS :
            while (loop--) {
                if ([self.board undo:1]) {
                    self.curNode = [self.curPlayingTree getNodeById:self.curNode.parentID];
                }else{
                    break;
                }
            }
        case PREV:
            loop=2;
            while (loop--) {
                if ([self.board undo:1]) {
                    self.curNode = [self.curPlayingTree getNodeById:self.curNode.parentID];
                }else{
                    break;
                }
            }
        case NEXT:[self moveNext:1];break;

        case NEXTTENPASS:[self moveNext:10];break;
    }
}
-(void)moveNext:(int)stepCount{
    TVGSGFTree *tree = self.curPlayingTree;
    TVGSGFNode *node = self.curNode;
    for (; !node.isLeaf; node=[tree getNodeById:node.nextStepID]) {
        if (node.isMoveNode) {
            //get move locate and color
            NSArray* move = [node getPropertyByName:@"move"];
            TVGMove *mvPoint = ((TVGSGFProperty *)[move objectAtIndex:0]).propValue;
            [self.board setPiece:mvPoint.player at:mvPoint.x and:mvPoint.y];
            NSArray *comment = [node getPropertyByName:@"comment"];
            if ([comment count]!=0) {
                
                self.sgfComment.text = ((TVGSGFProperty *)[comment objectAtIndex:0]).propValue;
                self.sgfComment.textColor = [UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0];
                self.sgfComment.font = [UIFont systemFontOfSize:20];
            }else{
                self.sgfComment.text=@"";
            }
            if (!(--stepCount))
            {
                break;
            }
        }
    }
    if (node.isLeaf) {
        self.curNode=node;
        return;
    }
    self.curNode = [tree getNodeById:node.nextStepID];
}







-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"sgfListItem"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sgfListItem"];
    }
    UIButton *accessoryButton = (UIButton *)cell.accessoryView;
    if (accessoryButton ==nil) {
        accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44 , 44)];
        [accessoryButton setBackgroundColor:[UIColor clearColor]];
        UIImage *nextImage = [[UIImage imageNamed:@"icon-ios7-arrow-right-128.png"] imageWithTintColor:[UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]];
        [accessoryButton setImage:nextImage forState:UIControlStateNormal];
        [accessoryButton addTarget:self action:@selector(lookSwitchPushed:) forControlEvents:UIControlEventTouchUpInside];

        
    }
    [self setAssociatedIndexPath:indexPath forThumbnailButton:accessoryButton];
    [cell setAccessoryView:accessoryButton];
    NSString *fileName = [[NSString alloc]initWithFormat:@"%@",[self.sgfFileListDataSrc objectAtIndex:indexPath.row]];
    NSString *showName = [fileName substringToIndex:[fileName length]-4];
    cell.textLabel.text= showName;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if (self.lookStatus) {
        [self lookSwitchPushed:sender];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}
- (IBAction)lookSwitchPushed:(UIButton *)sender {
    __weak TVGWatchSGFViewController* ctx = self;
    if (self.lookStatus==NO) {
        [self tableView:self.sgfTable didSelectRowAtIndexPath:[self associatedIndexPathForThumbnailButton:sender]];
        self.curNode = [self.curPlayingTree getRootNode];
        self.sgfComment.text=@"";
        self.lookStatus = YES;
        gnugo_clear_board(19);
        [self.board sync];
        [self.board cleanStepHint];
        [self.board showStepHint];
        [UIView animateWithDuration:0.5 animations:^{
            for (UIView *view in ctx.searchSideBar) {
                CGPoint origin = view.frame.origin;
                [view setFrame:CGRectMake(-view.frame.size.width, origin.y, view.frame.size.width, view.frame.size.height)];
            }
            for (UIView* view in ctx.detailCtrls) {
                view.alpha = 1.0;
            }
            
        } completion:^(BOOL finished) {
        }];
    }else{
        self.lookStatus = NO;
        self.curNode=nil;
        [UIView animateWithDuration:0.5 animations:^{
            for (UIView *view in ctx.searchSideBar) {
                CGPoint origin = view.frame.origin;
                [view setFrame:CGRectMake(ctx.sideSpec, origin.y, view.frame.size.width, view.frame.size.height)];
            }
            for (UIView* view in ctx.detailCtrls) {
                view.alpha=0;
            }
            
        } completion:^(BOOL finished) {
        }];
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath    {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.curFile!=nil && [self.curFile isEqualToString:cell.textLabel.text]) {
        return;
    }
    self.curFile = cell.textLabel.text;
    gnugo_clear_board(19);
    self.sgfTitle.text = cell.textLabel.text;

    NSString *fileName = [[NSHomeDirectory() stringByAppendingString:@"/Documents/sgf/"] stringByAppendingString:[self.sgfFileListDataSrc objectAtIndex:indexPath.row]];
    NSLog(@"%@ is select in section",fileName);
    TVGSGFTree *tree = [[TVGSGFTree alloc]initWithFile:fileName];
    TVGSGFNode * node = [tree getRootNode];
    NSArray *prop = [node getPropertyByName:@"comment"];
    NSString *detail = ((TVGSGFProperty *)[prop objectAtIndex:0]).propValue;
    self.sgfDetail.text = detail;
    self.sgfDetail.textColor = [UIColor colorWithRed:((float) 24/ 255.0f)
                                               green:((float) 153/ 255.0f)
                                                blue:((float) 251/ 255.0f)
                                               alpha:1.0f];
    node = [tree getNodeById:node.nextStepID];
    for (; !node.isLeaf; node=[tree getNodeById:node.nextStepID]) {
        if (node.isMoveNode) {
            //get move locate and color
            NSArray* move = [node getPropertyByName:@"move"];
            TVGMove *mvPoint =  ((TVGSGFProperty *)[move objectAtIndex:0]).propValue;
            [self.board setPiece:mvPoint.player at:mvPoint.x and:mvPoint.y];
        }
    }
    self.curPlayingTree  = tree;

}



static char kThumbnailButtonAssociatedPhotoKey;

// ...

- (void)setAssociatedIndexPath:(NSIndexPath *)associatedIndexPath
        forThumbnailButton:(UIButton *)thumbnailButton
{
    objc_setAssociatedObject(thumbnailButton,
                             &kThumbnailButtonAssociatedPhotoKey,
                             associatedIndexPath,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath *)associatedIndexPathForThumbnailButton:(UIButton *)thumbnailButton
{
    return objc_getAssociatedObject(thumbnailButton,
                                    &kThumbnailButtonAssociatedPhotoKey);
}
@end

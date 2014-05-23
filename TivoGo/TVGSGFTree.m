//
//  TVGSGFPlayer.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-23.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGSGFTree.h"
#include "sgftree.h"

@interface TVGSGFTree ()
@property (nonatomic,readonly) SGFTree sgftree;
@property (nonatomic,readonly)BOOL useChild;
@property (nonatomic)SGFNode* curNode;
@property (nonatomic,readonly) NSMutableArray *nodeTreeArray;
@property (nonatomic)TVGSGFNode *prevGenNode;
@end

@implementation TVGSGFTree
@synthesize sgftree=_sgftree;
@synthesize gameInfo=_gameInfo;
@synthesize useChild=_useChild;
@synthesize curNode=_curNode;
@synthesize nodeTreeArray=_nodeTreeArray;
@synthesize prevGenNode=_prevGenNode;

-(NSMutableDictionary *)gameInfo{
    if (_gameInfo==nil) {
        NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
        SGFNode *root = self.sgftree.root;
        if (root==NULL) {
            return nil;
        }
        char *tmpc=NULL;
        NSStringEncoding curEncoding;
        if ([NSLocalizedString(@"LanguageCode", nil) isEqualToString:@"ja"]) {
            curEncoding = NSShiftJISStringEncoding;
        }else{
            curEncoding = NSUTF8StringEncoding;
        }
        
        if (sgfGetCharProperty(root, "HA", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"HA"];
        if (sgfGetCharProperty(root, "RU", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"RU"];
        if (sgfGetCharProperty(root, "GN", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"GN"];
        if (sgfGetCharProperty(root, "DT", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"DT"];
        if (sgfGetCharProperty(root, "GC", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"GC"];
        if (sgfGetCharProperty(root, "US", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"US"];
        if (sgfGetCharProperty(root, "PB", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"PB"];
        if (sgfGetCharProperty(root, "PW", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"PW"];
        if (sgfGetCharProperty(root, "RE", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"RE"];
        if (sgfGetCharProperty(root, "EV", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"EV"];
        if (sgfGetCharProperty(root, "SO", &tmpc))
            [info setObject:[[NSString alloc]initWithBytes:tmpc length:strlen(tmpc) encoding:curEncoding] forKey:@"SO"];
        
        NSString* gameName = [info objectForKey:@"GN"];
        if (gameName==nil) {
            gameName=[info objectForKey:@"EV"];
        }
        if (gameName==nil) {
            gameName=[info objectForKey:@"SO"];
        }
        if (gameName==nil) {
            gameName=[ NSString stringWithFormat:@"%@ %@ %@ %@",[info objectForKey:@"DT"],[info objectForKey:@"PB"],NSLocalizedString(@"VS", nil),[info objectForKey:@"PW"]];
        }
        [info setObject:gameName forKey:@"GN"];
        
        _gameInfo = info;
    }
    return _gameInfo;
}
-(TVGSGFTree *)initWithFile:(NSString *)filePath{
    sgftree_clear(&_sgftree);
    if (filePath!=nil) {
        const char * infilename = [filePath UTF8String];
        if (!sgftree_readfile(&_sgftree, infilename)) {
            return nil;
        }
    }else{
        return nil;
    }
    if (self.sgftree.root->next&&!self.sgftree.root->child) {
        _useChild=NO;
    }else{
        _useChild=YES;
    }
    [self generateNodeTree];
    //[self close];
    return self;
}
-(void)generateNodeTree{
    //make a tree and a array
    _nodeTreeArray = [[NSMutableArray alloc]init];
    [self fillMainChain:_nodeTreeArray byNode:self.sgftree.root byBranch:NO withPrevNode:self.prevGenNode];
}
-(TVGSGFNode *)prevGenNode{
    if (!_prevGenNode) {
        _prevGenNode=[[TVGSGFNode alloc]init];
        _prevGenNode.nodeID=-1;
    }
    return _prevGenNode;
}
-(void)fillMainChain:(NSMutableArray *)chain byNode:(SGFNode *) cNode byBranch:(BOOL) isBranch withPrevNode:(TVGSGFNode *)prevNode{
    NSArray *props = [self getNodePropertys:cNode];
    TVGSGFNode *node = [[TVGSGFNode alloc]init];
    node.nodeID=chain.count;
    node.props=props;
    if (isBranch) {
        node.parentID=prevNode.parentID;
        [prevNode.otherVaris addObject:[NSNumber numberWithInteger:node.nodeID]];
    }else{
        node.parentID=prevNode.nodeID;
        prevNode.nextStepID=node.nodeID;
    }
    
    [chain addObject:node];
    SGFNode *tmp=cNode;
    while ((tmp=tmp->next)&&!isBranch) {
        [self fillMainChain:chain byNode:tmp byBranch:YES withPrevNode:node];
    }
    if (!cNode->child) {
        node.isLeaf=YES;
        return;
    }
    node.isLeaf=NO;
    [self fillMainChain:chain byNode:cNode->child byBranch:NO withPrevNode:node];
}
-(NSArray *)getNodePropertys:(SGFNode *)node{
    NSMutableArray *propsArr = [[NSMutableArray alloc]init];
    SGFProperty* prop =node->props;
    for (; prop; prop=prop->next) {
        TVGSGFProperty *oProp = [[TVGSGFProperty alloc]init];
        oProp.rawName=prop->name;
        oProp.rawValue=prop->value;
        [propsArr addObject:oProp];
    }
    return propsArr;
}
-(int)close{
    sgfFreeNode(self.sgftree.root);
    return 0;
}
-(TVGSGFNode *)getRootNode{
    return [self getNodeById:0];
}
-(TVGSGFNode *)getNodeById:(NSInteger)nodeId{
    if (nodeId>=self.nodeTreeArray.count) {
        return nil;
    }
    return [self.nodeTreeArray objectAtIndex:nodeId];
}
@end

//
//  LevelSelect.m
//  Fly Bird!
//
//  Created by Marmik Shah on 01/03/14.
//  Copyright (c) 2014 Marmik Shah. All rights reserved.
//

#import "LevelSelect.h"
#import "Play.h"

@interface LevelSelect()
{
    CCButton* slow;
    CCButton* medium;
    CCButton* fast;
    CCSprite* background;
}
@end

@implementation LevelSelect

+(LevelSelect*)scene {

    return [[self alloc]init];
}
-(id)init {
    self = [super init];
    if(!self)return nil;
    [self addChild:[self addBackground]];
    [self addChild:[self lvlTypeSlow]];
    [self addChild:[self lvlTypeMedium]];
    [self addChild:[self lvlTypeFast]];
    return self;
}
-(CCButton*)lvlTypeFast {
    CCSpriteFrame* fastFrame = [CCSpriteFrame frameWithImageNamed:@"Fast.png"];
    fast = [CCButton buttonWithTitle:@"" spriteFrame:fastFrame];
    fast.position = ccp(self.contentSize.width/2, self.contentSize.height/2 + self.contentSize.height/4);
    [fast setTarget:self selector:@selector(startFastGame)];
    return fast;
}
-(CCButton*)lvlTypeMedium {
    CCSpriteFrame* mediumFrame = [CCSpriteFrame frameWithImageNamed:@"Medium.png"];
    medium = [CCButton buttonWithTitle:@"" spriteFrame:mediumFrame];
    medium.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [medium setTarget:self selector:@selector(startMediumGame)];
    return medium;
}
-(CCButton*)lvlTypeSlow {
    CCSpriteFrame* slowFrame = [CCSpriteFrame frameWithImageNamed:@"Slow.png"];
    slow = [CCButton buttonWithTitle:@"" spriteFrame:slowFrame];
    slow.position = ccp(self.contentSize.width/2, self.contentSize.height/4);
    [slow setTarget:self selector:@selector(startSlowGame)];
    return slow;
}
-(CCSprite*)addBackground {
    background = [CCSprite spriteWithImageNamed:@"LvlSelect.png"];
    background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    return  background;
}
-(void)startSlowGame {
    [[CCDirector sharedDirector]replaceScene:[Play sceneWithDifficulty:1]];
}
-(void)startMediumGame {
    [[CCDirector sharedDirector]replaceScene:[Play sceneWithDifficulty:2]];
}
-(void)startFastGame {
    [[CCDirector sharedDirector]replaceScene:[Play sceneWithDifficulty:3]];
}
@end

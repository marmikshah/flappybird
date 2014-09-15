//
//  IntroScene.m
//  Fly Bird!
//
//  Created by Marmik Shah on 21/02/14.
//  Copyright Marmik Shah 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "Play.h"
#import "LevelSelect.h"


@implementation IntroScene

+ (IntroScene *)scene{
	return [[self alloc] init];
}

- (id)init{
    self = [super init];
    if(!self)return nil;
    CCSprite* background = [CCSprite spriteWithImageNamed:@"FlyBird.png"];
    background.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:background];
    CCButton* play = [CCButton buttonWithTitle:@"Play!" fontName:@"Gill Sans" fontSize:25];
    play.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    play.color = [CCColor blueColor];
    [play setTarget:self selector:@selector(playGame)];
    [self addChild:play];
    return self;
}
-(void)playGame {
    //[[CCDirector sharedDirector]replaceScene:[LevelSelect scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1]];
}

@end

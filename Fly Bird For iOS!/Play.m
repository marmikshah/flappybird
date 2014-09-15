//
//  Play.m
//  Fly Bird!
//
//  Created by Marmik Shah on 21/02/14.
//  Copyright (c) 2014 Marmik Shah. All rights reserved.
//

#import "Play.h"
#import "IntroScene.h"
#import <GameKit/GameKit.h>
#import "LevelSelect.h"
#import <sqlite3.h>

int mode;

@interface Play() <CCPhysicsCollisionDelegate>
{

    CCLabelTTF* score;
    CCPhysicsNode* physics;
    BOOL gameOver;
    int points;
    CGPoint cloudposition;
    CGPoint jump;
    int counter;
    int highscore;
    CCLabelTTF* highScore;
    int respawn;
    int createTime;
    CCButton* pause;
    CCButton* play;
}
@end

@interface Play()
#pragma Sprite Declarations.
{
    CCSprite* topTunnelOne;
    CCSprite* bottomTunnelOne;
    CCSprite* topTunnelTwo;
    CCSprite* bottomTunnelTwo;
    CCSprite* cloud;
    CCSprite* grass;
    CCSprite* bird;
    CCSprite* ground;
    CCSprite* goal;
    CCSprite* ceiling;
    CCSprite* buildings;
}
@end

@implementation Play
+(Play*)sceneWithDifficulty:(int)type {
    mode = type;
    return [[self alloc]init];
}
-(id)init {
    self = [super init];
    if(!self) return nil;
    self.userInteractionEnabled = YES;
    int bg = arc4random()%2;
    CCSprite* background;
    if(bg==0){
        background = [CCSprite spriteWithImageNamed:@"BackgroundsDay.png"];
    }
    if(bg==1){
        background = [CCSprite spriteWithImageNamed:@"BackgroundsNight.png"];
        
    }
    
    background.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self decideTimeBasedOnDifficulty];

    [self addChild:background];
    [self addChild:[self addPhyicsWorld]];
    [physics addChild:[self addGround]];
    //[self addChild:[self addBuildings]];
    [physics addChild:[self addBird]];
    [self moveClouds];
    [self addChild:[self addScoreBar]];
    jump = CGPointMake(0,300);
    [self schedule:@selector(resetCloud) interval:0.5];
    [self schedule:@selector(generateTunnel) interval:createTime];
    [physics addChild:[self addCeiling]];
    [[OALSimpleAudio sharedInstance]playBg:@"Background.wav" loop:YES];
    return self;
}
-(void)decideTimeBasedOnDifficulty {
    if(mode ==  3) {
        createTime = 1;
        respawn = 1;
    }
    if(mode ==  2) {
        createTime = 1;
        respawn = 2.5;
    }
    if(mode ==  1) {
        createTime = 2;
        respawn = 4;
    }
}
-(void)generateTunnel {
    [self addTunnelOne];
}
-(void)moveClouds {
    CCPhysicsNode* cloudPhysics = [CCPhysicsNode node];
    cloudPhysics.gravity = ccp(-10, cloudposition.y);
    [self addChild:cloudPhysics];
    [cloudPhysics addChild:[self addClouds]];
}
-(void)resetCloud {
    if (cloud.position.x<-cloud.contentSize.width/2) {
        cloud.position = cloudposition;
    }
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(!gameOver){
        bird.physicsBody.velocity = jump;
        bird.rotation = 0;
    }
    [[OALSimpleAudio sharedInstance] playEffect:@"Jump.wav" volume:0.7 pitch:1 pan:10 loop:NO];
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    [bird setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"bird-1.png"]];
    bird.rotation = 90;
}
-(void)addTunnelOne {
    [physics addChild:[self addBottomBarOne]];
    [physics addChild:[self addGoalForBar1]];
    [physics addChild:[self addTopBarOne]];
    [self resetGround];
}
-(void)resetGround {
    [ground removeFromParentAndCleanup:YES];
    [physics addChild:[self addGround]];
}
-(void)addTunnelTwo {
    [physics addChild:[self addBottomBarTwo]];
    [physics addChild:[self addGoalForBar1]];
    [physics addChild:[self addTopBarTwo]];
    [self resetGround];
}
-(void)loser {
    if(!gameOver)
        [[OALSimpleAudio sharedInstance] playBg:@"Gameover.wav" loop:NO];
    gameOver = YES;
    [[CCDirector sharedDirector]pause];
    CCSprite* game = [CCSprite spriteWithImageNamed:@"Gameover.png"];
    game.position = CGPointMake(self.contentSize.width/2, self.contentSize.height/2+self.contentSize.height/4);
    [self addChild:game];
    [game runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:2],[CCActionRemove action]]]];
    CCButton* reset = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Restart.png"]];
    reset.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    CCButton* choosDifficulty = [CCButton buttonWithTitle:@"Choose Difficulty"];
    choosDifficulty.position = ccp(self.contentSize.width/2, self.contentSize.height/2+self.contentSize.height/8);
    [choosDifficulty setTarget:self selector:@selector(returnToDifficultySelect)];
    [self addChild:choosDifficulty];
    [reset setTarget:self selector:@selector(resetGame)];
    [self addChild:reset];
    [self stopAllActions];
    [topTunnelOne stopAllActions];
    [bottomTunnelOne stopAllActions];
    [topTunnelTwo stopAllActions];
    [bottomTunnelTwo stopAllActions];
    [self unscheduleAllSelectors];
}
-(void)resetGame {
    [self removeFromParentAndCleanup:YES];
    [[CCDirector sharedDirector]replaceScene:[Play sceneWithDifficulty:mode]];
    [[CCDirector sharedDirector]resume];
}
-(void)returnToDifficultySelect {
    [[CCDirector sharedDirector]replaceScene:[LevelSelect scene]];
}

#pragma Add Nodes to the screen.

-(CCPhysicsNode*)addPhyicsWorld {
    physics = [CCPhysicsNode node];
    physics.debugDraw = NO;
    physics.collisionDelegate = self;
    physics.gravity = CGPointMake(0,-980);
    return physics;
}
-(CCLabelTTF*)addScoreBar {
    score = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Gill Sans" fontSize:19];
    score.position = ccp(self.contentSize.width-60,self.contentSize.height-30);
    return score;
}
-(CCSprite*)addGoalForBar1 {
    goal = [CCSprite spriteWithImageNamed:@"Goal.png"];
    if(counter%2==0)
        goal.position = ccp(bottomTunnelOne.position.x, self.contentSize.height/2);
    else
        goal.position = ccp(bottomTunnelTwo.position.x, self.contentSize.height/2);
    goal.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,goal.contentSize} cornerRadius:0];
    goal.physicsBody.type = CCPhysicsBodyTypeStatic;
    goal.physicsBody.collisionType = @"GoalType";
    goal.physicsBody.collisionGroup = @"GoalGroup";
    goal.physicsBody.sensor = YES;
    CCActionMoveTo* moveBottom = [CCActionMoveTo actionWithDuration:respawn position:ccp(-20, goal.position.y)];
    CCActionRemove* remove = [CCActionRemove action];
    [goal runAction:[CCActionSequence actionWithArray:@[moveBottom,remove]]];
    return goal;
}
-(CCSprite*)addBird {
    bird = [CCSprite spriteWithImageNamed:@"bird-1.png"];
    bird.position = ccp(self.contentSize.width/4, self.contentSize.height/2);
    bird.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,bird.contentSize} cornerRadius:0];
    bird.physicsBody.collisionType = @"BirdType";
    bird.physicsBody.collisionGroup = @"BirdGroup";
    return bird;
}
-(CCSprite*)addGrass {
    grass = [CCSprite spriteWithImageNamed:@"Grass.png"];
    grass.position = ccp(self.contentSize.width/2, ground.contentSize.height/2 + ground.position.y);
    return grass;
}
-(CCSprite*)addClouds {

    cloud = [CCSprite spriteWithImageNamed:@"Clouds.png"];
    cloudposition = ccp(self.contentSize.width+cloud.contentSize.width, self.contentSize.height-cloud.contentSize.height);
    cloud.position = cloudposition;
    cloud.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,cloud.contentSize} cornerRadius:0];
    return cloud;
}
-(CCSprite*)addGround {
    ground = [CCSprite spriteWithImageNamed:@"Ground.png"];
    ground.position = ccp(self.contentSize.width/2,ground.contentSize.height/4);
    ground.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,ground.contentSize} cornerRadius:0];
    ground.physicsBody.affectedByGravity = NO;
    ground.physicsBody.allowsRotation = NO;
    ground.physicsBody.type = CCPhysicsBodyTypeStatic;
    ground.physicsBody.collisionGroup = @"GroundGroup";
    ground.physicsBody.collisionType = @"GroundType";
    return ground;
}
-(CCSprite*)addTopBarOne {
    topTunnelOne = [CCSprite spriteWithImageNamed:@"Top Bar.png"];
    topTunnelOne.position = ccp(self.contentSize.width, bottomTunnelOne.position.y + bottomTunnelOne.contentSize.height/2 + 100 +topTunnelOne.contentSize.height/2);
    topTunnelOne.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,topTunnelOne.contentSize} cornerRadius:0];
    topTunnelOne.physicsBody.collisionType = @"TopCc";
    topTunnelOne.physicsBody.collisionGroup = @"BirdCollide";
    topTunnelOne.physicsBody.type = CCPhysicsBodyTypeStatic;
    CCActionMoveTo* moveTop = [CCActionMoveTo actionWithDuration:respawn position:ccp(-20, topTunnelOne.position.y)];
    CCActionRemove* remove = [CCActionRemove action];
    [topTunnelOne runAction:[CCActionSequence actionWithArray:@[moveTop,remove]]];
    return topTunnelOne;
}
-(CCSprite*)addBottomBarOne {
    bottomTunnelOne = [CCSprite spriteWithImageNamed:@"Bottom Bar.png"];
    int randtemmp = arc4random()%100;
    if(randtemmp<30)randtemmp = 40;
    bottomTunnelOne.position = ccp(self.contentSize.width,randtemmp+ground.position.y+ground.contentSize.height/2);
    bottomTunnelOne.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,bottomTunnelOne.contentSize} cornerRadius:0];
    bottomTunnelOne.physicsBody.collisionType = @"BottomCc";
    bottomTunnelOne.physicsBody.collisionGroup = @"BirdCollide";
    bottomTunnelOne.physicsBody.type = CCPhysicsBodyTypeStatic;
    CCActionMoveTo* moveBottom = [CCActionMoveTo actionWithDuration:respawn position:ccp(-20, bottomTunnelOne.position.y)];
    CCActionRemove* remove = [CCActionRemove action];
    [bottomTunnelOne runAction:[CCActionSequence actionWithArray:@[moveBottom,remove]]];
    return bottomTunnelOne;
}
-(CCSprite*)addTopBarTwo {
    topTunnelTwo = [CCSprite spriteWithImageNamed:@"Top Bar.png"];
    topTunnelTwo.position = ccp(self.contentSize.width, bottomTunnelTwo.position.y + bottomTunnelTwo.contentSize.height/2 + 100 + topTunnelTwo.contentSize.height/2);
    topTunnelTwo.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,topTunnelTwo.contentSize} cornerRadius:0];
    topTunnelTwo.physicsBody.collisionType = @"TopCc";
    topTunnelTwo.physicsBody.collisionGroup = @"BirdCollide";
    topTunnelTwo.physicsBody.type = CCPhysicsBodyTypeStatic;
    CCActionMoveTo* moveTop = [CCActionMoveTo actionWithDuration:respawn position:ccp(-20, topTunnelTwo.position.y)];
    CCActionRemove* remove = [CCActionRemove action];
    [topTunnelTwo runAction:[CCActionSequence actionWithArray:@[moveTop,remove]]];
    return topTunnelTwo;
}
-(CCSprite*)addBottomBarTwo {
    bottomTunnelTwo = [CCSprite spriteWithImageNamed:@"Bottom Bar.png"];
    int randtemmp = arc4random()%100;
    if(randtemmp<30)randtemmp = 40;
    bottomTunnelTwo.position = ccp(self.contentSize.width,randtemmp+ground.position.y+ground.contentSize.height/2);
    bottomTunnelTwo.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,bottomTunnelTwo.contentSize} cornerRadius:0];
    bottomTunnelTwo.physicsBody.collisionType = @"BottomCc";
    bottomTunnelTwo.physicsBody.collisionGroup = @"BirdCollide";
    bottomTunnelTwo.physicsBody.type = CCPhysicsBodyTypeStatic;
    CCActionMoveTo* moveBottom = [CCActionMoveTo actionWithDuration:respawn position:ccp(-20, bottomTunnelTwo.position.y)];
    CCActionRemove* remove = [CCActionRemove action];
    [bottomTunnelTwo runAction:[CCActionSequence actionWithArray:@[moveBottom,remove]]];
    return bottomTunnelTwo;
}
-(CCSprite*)addCeiling {
    ceiling = [CCSprite spriteWithImageNamed:@"Ceiling.png"];
    ceiling.position = ccp(self.contentSize.width/2,self.contentSize.height);
    ceiling.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero,ceiling.contentSize }cornerRadius:5];
    ceiling.physicsBody.type = CCPhysicsBodyTypeStatic;
    ceiling.physicsBody.collisionGroup = @"CeilingGroup";
    ceiling.physicsBody.collisionType = @"CeilingType";
    return ceiling;
}
-(CCSprite*)addBuildings {
    buildings = [CCSprite spriteWithImageNamed:@"Buildings.png"];
    buildings.position = ccp(self.contentSize.width/2,ground.contentSize.height);
    return buildings;
}

#pragma Collision Detection.

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair BirdType:(CCNode *)birdNode TopCc:(CCNode *)topBar {
    [self loser];
    return YES;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair BirdType:(CCNode *)birdNode BottomCc:(CCNode *)topBar {
    [self loser];
    return YES;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair BirdType:(CCNode *)myBird GoalType:(CCNode *)myGoal {
    if(!gameOver){
        points+=1;
        if(highscore<points){
            [highScore setString:[NSString stringWithFormat:@"High Score :%d",points]];
            highscore = points;
        }
        [score setString:[NSString stringWithFormat:@"Score :%d",points]];
    }
    return YES;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair BirdType:(CCNode *)myBird GroundType:(CCNode *)myGround {
    bird.rotation = 0;
    [self loser];
    return YES;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair BirdType:(CCNode *)myBird CeilingType:(CCNode *)myCeiling {
    [self loser];
    return YES;
}


@end

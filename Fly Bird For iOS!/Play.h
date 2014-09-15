//
//  Play.h
//  Fly Bird!
//
//  Created by Marmik Shah on 21/02/14.
//  Copyright (c) 2014 Marmik Shah. All rights reserved.
//

#import "cocos2d-ui.h"
#import "cocos2d.h"

@interface Play : CCScene

+(Play*)sceneWithDifficulty:(int)type;
-(id)init;

@end

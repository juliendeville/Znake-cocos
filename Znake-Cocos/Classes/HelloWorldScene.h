//
//  HelloWorldScene.h
//  Znake-Cocos
//
//  Created by julien DEVILLE on 23/02/2014.
//  Copyright julien DEVILLE 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
#define WIDTH 9
#define HEIGHT 6
#define TILESIZE 64
#define HUMAN_POP_TIME 1.5
#define HUMAN_POINTS 1000
#define SECOND_POINTS 1000
// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface HelloWorldScene : CCScene <CCPhysicsCollisionDelegate>

// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene;
- (id)init;
- (void)pop;
//- (void)update:(CCTime)delta;

// -----------------------------------------------------------------------
@end
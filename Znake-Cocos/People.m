//
//  People.m
//  Znake-Cocos
//
//  Created by julien DEVILLE on 25/02/2014.
//  Copyright 2014 julien DEVILLE. All rights reserved.
//

#import "People.h"
#import "HelloWorldScene.h"


@implementation People {
    CGPoint lastTarget;
    bool firstDone;
}

- (void) move: (CGPoint) position
{
    if( firstDone && self.physicsBody.collisionType == nil ) {
        self.physicsBody.collisionGroup = @"zombieGroup";
        self.physicsBody.collisionType  = @"zombieCollision";
    }
    
    if( lastTarget.x == 0 && lastTarget.y == 0 ){
        lastTarget = self.position;
    }
    
    CCAction *moveAction = [ CCActionMoveTo actionWithDuration: MOVEMENT_DURATION position: position ];
    
    if( follower != nil && firstDone )
        [follower move:self.position];
    [self stopAllActions];
    
    self.position = lastTarget;
    [self runAction:moveAction];
    lastTarget = position;
    
    firstDone = true;
}
@end

//
//  Player.m
//  Znake-Cocos
//
//  Created by julien DEVILLE on 25/02/2014.
//  Copyright 2014 julien DEVILLE. All rights reserved.
//

#import "Player.h"
#import "People.h"


@implementation Player {
    CGPoint playerPosition;
    float anglePlayerDirection;
    CGPoint lastTarget;
}

- (void) setTiledPosition: (CGPoint) position scale: (float) scale {
    [super setTiledPosition:position scale:scale];
    playerPosition = position;
}

- (void) right {
    anglePlayerDirection -= M_PI_2;
    direction = ccp( cos( anglePlayerDirection ), sin( anglePlayerDirection ) );
}

- (void) left {
    anglePlayerDirection += M_PI_2;
    direction = ccp( cos( anglePlayerDirection ), sin( anglePlayerDirection ) );
}

- (void) move
{
    if( lastTarget.x == 0 && lastTarget.y == 0 )
        lastTarget = self.position;
        
    playerPosition = ccpAdd( playerPosition, direction );
    
    CCAction *moveAction = [ CCActionMoveTo actionWithDuration: MOVEMENT_DURATION position: [Tile getPixelPosition:playerPosition scale:self.scale] ];
    CCAction *actionCallFunc = [CCActionCallFunc actionWithTarget:self selector:@selector(move)];
    CCActionSequence *actionSequence = [CCActionSequence actionOne:(CCActionFiniteTime*)moveAction two:(CCActionFiniteTime*)actionCallFunc];
    
    
    if( follower != nil ){
        
        //CCLOG(@"move 1st follower to %0.2f %0.2f ", self.position.x, self.position.y);
        [follower move:self.position];
    }
    
    [self stopAllActions];
    self.position = lastTarget;
    [self runAction:actionSequence];
    lastTarget = [Tile getPixelPosition:playerPosition scale:self.scale];
}
@end

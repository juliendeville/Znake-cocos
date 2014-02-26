//
//  People.h
//  Znake-Cocos
//
//  Created by julien DEVILLE on 25/02/2014.
//  Copyright 2014 julien DEVILLE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Tile.h"
#define MOVEMENT_DURATION 0.3

@interface People : Tile {
    @public
    float movementDuration;
    People *follower;
}

- (void) move: (CGPoint) position;
@end

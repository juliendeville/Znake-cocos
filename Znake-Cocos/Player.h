//
//  Player.h
//  Znake-Cocos
//
//  Created by julien DEVILLE on 25/02/2014.
//  Copyright 2014 julien DEVILLE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "People.h"


@interface Player : People {
    @public
    CGPoint direction;
}

- (void) move;
- (void) right;
- (void) left;

@end

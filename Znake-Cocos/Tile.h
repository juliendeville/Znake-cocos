//
//  Tile.h
//  Znake-Cocos
//
//  Created by julien DEVILLE on 25/02/2014.
//  Copyright 2014 julien DEVILLE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Tile : CCSprite {
    
}

- (void) setTiledPosition: (CGPoint) position scale: (float) scale;

+ (CGPoint)getTiledPosition:(CGPoint) pixelPosition scale: (float) _scale;
+ (CGPoint)getPixelPosition: (CGPoint) position scale: (float) _scale;

- (CGPoint)getPixelPosition;
- (CGPoint)getTiledPosition;

@end

//
//  Tile.m
//  Znake-Cocos
//
//  Created by julien DEVILLE on 25/02/2014.
//  Copyright 2014 julien DEVILLE. All rights reserved.
//

#import "Tile.h"
#import "HelloWorldScene.h"

@implementation Tile
{
    CGPoint tilePosition;
}

- (void) setTiledPosition: (CGPoint) position scale: (float) scale {
    self.scale = scale;
    [self setPosition:[Tile getPixelPosition:position scale:scale]];
}

+ (CGPoint)getTiledPosition:(CGPoint) pixelPosition scale: (float) _scale
{
    return ccp( (pixelPosition.x/_scale/TILESIZE)-0.5f, (pixelPosition.y/_scale/TILESIZE)-0.5f);
}

+ (CGPoint)getPixelPosition: (CGPoint) position scale: (float) _scale
{
    return ccp(_scale*TILESIZE*(position.x+0.5f), _scale*TILESIZE*(position.y+0.5f));
}

- (CGPoint)getTiledPosition
{
    return ccp( (self.position.x/self.scale/TILESIZE)-0.5f, (self.position.y/self.scale/TILESIZE)-0.5f);
}

- (CGPoint)getPixelPosition
{
    return ccp(self.scale*TILESIZE*(self.position.x+0.5f), self.scale*TILESIZE*(self.position.y+0.5f));
}

@end

//
//  HelloWorldScene.m
//  Znake-Cocos
//
//  Created by julien DEVILLE on 23/02/2014.
//  Copyright julien DEVILLE 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"
#import "NewtonScene.h"
#import "tgmath.h"
#import "People.h"
#import "Player.h"
#import "Tile.h"
#include <stdlib.h>

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene

// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    Player *player;
    CCSpriteFrameCache *spriteCache;
    CCSpriteBatchNode *batch;
    Tile *backgroundTiles[HEIGHT][WIDTH];
    float scaleTile;
    
    NSMutableArray *humans;
//    CGFloat lastHuman;
    
    CCPhysicsNode *_physicsWorld;
    int _points;
    
    CCLabelTTF *pointsLabel;
    bool pause;
    Tile *dead;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    _points = 0;
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:1.0f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    //_physicsWorld.debugDraw = YES;
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];
    
    scaleTile = (self.contentSize.height/(float)HEIGHT) / TILESIZE;
    
    //spritesheet
    // Create a batch node -- just a big image which is prepared to
    // be carved up into smaller images as needed
    batch = [CCSpriteBatchNode batchNodeWithFile:@"BigAtlas.png"];
    
    // Add the batch node to parent (it won't draw anything itself, but
    // needs to be there so that it's in the rendering pipeline)
    [_physicsWorld addChild:batch];
    
    
    
    // Load sprite frames, which are just a bunch of named rectangle
    // definitions that go along with the image in a sprite sheet
    spriteCache =[CCSpriteFrameCache sharedSpriteFrameCache];
    [spriteCache addSpriteFramesWithFile:@"BigAtlas.plist"];

    [self drawBackground];
    // Finally, create a sprite, using the name of a frame in our frame cache.
    player = [Player spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"perso_anim_face_1.png"]];
    [player setTiledPosition:ccp(3,2) scale:scaleTile];
    player->direction = ccp(1,0);
    
    player.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:TILESIZE/4 andCenter:player.anchorPointInPoints];
    player.physicsBody.collisionGroup = @"playerGroup";
    player.physicsBody.collisionType  = @"playerCollision";
    // Add the sprite as a child of the sheet, so that it knows where to get its image data.
    [batch addChild:player];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
    
    [player move];
    humans = [[NSMutableArray alloc] init];
    
    //score
    pointsLabel = [CCLabelTTF labelWithString:@"000 000 000" fontName:@"Arial" fontSize:24];
    pointsLabel.positionType = CCPositionTypeNormalized;
    pointsLabel.position = ccp(0.15f, 0.95f); // Top Left of screen
    [self addChild: pointsLabel];
    
//    lastHuman = 0;
    [self schedule:@selector(pop) interval:HUMAN_POP_TIME];
    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair playerCollision:(CCNode *)_player humanCollision:(People *)_human {
    //[_player removeFromParent];
    [self zombie:[_human getTiledPosition]];
    CCLOG(@"pos %@ ", NSStringFromCGPoint([_human getTiledPosition]));
    [humans removeObject:_human];
    [_human removeFromParent];
    [self addPoints:HUMAN_POINTS];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair playerCollision:(CCNode *)_player zombieCollision:(People *)_zombie {
    [_player removeFromParent];
    [_zombie removeFromParent];
    [self dead];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair humanCollision:(CCNode *)_human zombieCollision:(People *)_zombie {
    [humans removeObject:_human];
    [_human removeFromParent];
    return NO;
}


- (void)addPoints: (int) points {
    _points += points;
    
    if( _points > 999999999 )
        _points = 999999999;
    int _pointsTemp = _points;
    int millions = ceil( _pointsTemp / 1000000 );
    _pointsTemp -= millions * 1000000;
    int thousands = ceil( _pointsTemp / 1000 );
    _pointsTemp -= thousands * 1000;
    
    NSString *millionsStr = [@(millions) description];
    while( [millionsStr length] < 3 )
        millionsStr = [@"0" stringByAppendingString:millionsStr];
    NSString *thousandsStr = [@(thousands) description];
    while( [thousandsStr length] < 3 )
        thousandsStr = [@"0" stringByAppendingString:thousandsStr];
    NSString *zerosStr = [@(_pointsTemp) description];
    while( [zerosStr length] < 3 )
        zerosStr = [@"0" stringByAppendingString:zerosStr];
    
    NSString *final = [millionsStr stringByAppendingFormat:@" %@ %@", thousandsStr, zerosStr];
    [pointsLabel setString:final];
}

- (void)update:(CCTime)delta {
    if( !pause )
        [self addPoints:(int)(delta * SECOND_POINTS) ];
}

- (void)pop {
    if( pause )
        return;
    //create new human
    People *human = [People spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"Stephy_face_normal.png"]];
    //set random position
    
    bool good = false;
    CGPoint pos;
    int failsafe = 0;
    while( !good && failsafe < 1000 ) {
        pos = ccp(arc4random_uniform(WIDTH),arc4random_uniform(HEIGHT));
        good = true;
        for( People *human in humans ) {
            if( round( human.position.x ) == round( pos.x ) && round( human.position.y ) == round( pos.y ) )
                good = false;
        }
        failsafe++;
    }
    
    [human setTiledPosition:pos scale:scaleTile];
    
    human.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:TILESIZE/4 andCenter:human.anchorPointInPoints];
    human.physicsBody.collisionGroup = @"humanGroup";
    human.physicsBody.collisionType  = @"humanCollision";
    
    //adding to the human list
    [humans addObject:human];
    //adding to the scene
    [batch addChild:human];
}

- (void)zombie: (CGPoint) position {
    //create new zombie
    
    People *zombie = [People spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"perso_anim_face_1.png"]];
    zombie.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:TILESIZE/4 andCenter:zombie.anchorPointInPoints];
    zombie.physicsBody.collisionGroup = @"playerGroup";
    //set random position
    [zombie setTiledPosition:position scale:scaleTile];
    
    if( player->follower != nil ) {
        zombie->follower = player->follower;
    }
    player->follower = zombie;
    
    //adding to the scene
    [batch addChild:zombie];
}


- (void)dead {
    pause = true;
    dead = [Tile spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"death.png"]];
    //set random position
    [dead setTiledPosition:ccp( 0, 0) scale:scaleTile*9];
    
    //adding to the scene
    [batch addChild:dead];
}

- (void)drawBackground
{
    Tile *tempTile;
    for( int i = 0; i < HEIGHT; i++ ) {
        for( int j = 0; j < WIDTH; j++ ) {
            tempTile = backgroundTiles[i][j];
            if( i % 2 == 0 && j % 2 == 0 ) {
                tempTile = [Tile spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"herbe_f.png"]];
            } else if( i % 2 != 0 && j % 2 != 0 ) {
                tempTile = [Tile spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"herbe_c.png"]];
            } else {
                tempTile = [Tile spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"herbe_n.png"]];
            }
            [tempTile setTiledPosition:ccp(j,i) scale:scaleTile];
            [batch addChild:tempTile];
        }
    }
    //not the best
    Tile *border = [Tile spriteWithSpriteFrame:[spriteCache spriteFrameByName:@"kill.png"]];
    [border setTiledPosition:ccp(-1,-1) scale:scaleTile];

    //screen border collisions
    NSArray *shapes = [NSArray arrayWithObjects:
                       [CCPhysicsShape rectShape:CGRectMake(TILESIZE*(0+1), TILESIZE*(6+1), TILESIZE*(WIDTH+1), TILESIZE) cornerRadius:0],
                       [CCPhysicsShape rectShape:CGRectMake(TILESIZE*(0+1), TILESIZE*(-1+1), TILESIZE*(WIDTH+1), TILESIZE) cornerRadius:0],
                       [CCPhysicsShape rectShape:CGRectMake(TILESIZE*(-1+1), TILESIZE*(0+1), TILESIZE, TILESIZE*HEIGHT) cornerRadius:0],
                       [CCPhysicsShape rectShape:CGRectMake(TILESIZE*(WIDTH+1), TILESIZE*(0+1), TILESIZE, TILESIZE*HEIGHT) cornerRadius:0],
                       nil];
    border.physicsBody = [CCPhysicsBody bodyWithShapes:shapes];
    border.physicsBody.collisionGroup = @"zombieGroup";
    border.physicsBody.collisionType  = @"zombieCollision";
    [batch addChild:border];
}


// -----------------------------------------------------------------------

- (void)dealloc
{
    //@todo releases
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    if( pause ) {
        [[CCDirector sharedDirector] replaceScene:[HelloWorldScene scene]
                                   withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionUp duration:1.0f]];
    } else {
        if( touchLoc.x > self.contentSize.width / 2 ) {
            [player right];
        } else {
            [player left];
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

- (void)onNewtonClicked:(id)sender
{
    [[CCDirector sharedDirector] pushScene:[NewtonScene scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------
@end

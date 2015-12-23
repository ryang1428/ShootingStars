//
//  ViewController.m
//  ShootingStar
//
//  Created by Ryan Garchinsky on 12/21/15.
//  Copyright © 2015 garapps. All rights reserved.
//

#define SCREEN_SCALE [[UIScreen mainScreen] scale]
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>

@interface ViewController ()

// Sprite Kit
@property (nonatomic, strong) UIButton *fireSpriteKitButton;
@property (nonatomic, strong) UIButton *fireCoreAnimationButton;

//Core Animation
@property (nonatomic, strong) UIImageView *caStarImageView;
@property (nonatomic, strong) CAEmitterLayer *caStarEmitter;

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:0.57 green:0.66 blue:0.74 alpha:1];
        
        self.fireSpriteKitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fireSpriteKitButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fireSpriteKitButton setTitle:@"Sprite Kit" forState:UIControlStateNormal];
        [self.fireSpriteKitButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.fireSpriteKitButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3f]];
        [self.fireSpriteKitButton setTintColor:[UIColor grayColor]];
        [self.fireSpriteKitButton addTarget:self action:@selector(shootOffSpriteKitStarFromView:) forControlEvents:UIControlEventTouchUpInside];
        
        self.fireCoreAnimationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fireCoreAnimationButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fireCoreAnimationButton setTitle:@"Core Animation" forState:UIControlStateNormal];
        [self.fireCoreAnimationButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.fireCoreAnimationButton setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.3f]];
        [self.fireCoreAnimationButton setTintColor:[UIColor grayColor]];
        [self.fireCoreAnimationButton addTarget:self action:@selector(shootOffCoreAnimationStarFromView:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.fireSpriteKitButton];
        [self.view addSubview:self.fireCoreAnimationButton];

        NSDictionary *views = NSDictionaryOfVariableBindings(_fireSpriteKitButton, _fireCoreAnimationButton);
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fireSpriteKitButton(100)]|" options:0 metrics:nil views:views]];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_fireSpriteKitButton][_fireCoreAnimationButton]|" options:NSLayoutFormatAlignAllBottom|NSLayoutFormatAlignAllTop metrics:nil views:views]];
        
        [NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint constraintWithItem:self.fireCoreAnimationButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.fireSpriteKitButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)fireTouched:(id)sender {
    [self shootOffSpriteKitStarFromView:sender];
}

- (void)shootOffSpriteKitStarFromView:(UIView *)view {
    CGPoint viewOrigin;
    
    viewOrigin.y = 0;
    viewOrigin.x = (view.frame.origin.x + (view.frame.size.width / 2)) / SCREEN_SCALE;
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    containerView.userInteractionEnabled = NO;
    
    SKView *skView = [[SKView alloc] initWithFrame:containerView.frame];
    skView.allowsTransparency = YES;
    [containerView addSubview:skView];
    
    SKScene *skScene = [SKScene sceneWithSize:skView.frame.size];
    skScene.scaleMode = SKSceneScaleModeFill;
    skScene.backgroundColor = [UIColor clearColor];
    
    SKSpriteNode *starSprite = [SKSpriteNode spriteNodeWithImageNamed:@"filled_star"];
    [starSprite setScale:0.6];
    starSprite.position = viewOrigin;
    [skScene addChild:starSprite];
    
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"StarParticle" ofType:@"sks"]];
    SKEmitterNode *dotEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Asterisk" ofType:@"sks"]];
    
    [dotEmitter setParticlePosition:CGPointMake(0, -starSprite.size.height)];
    [emitter setParticlePosition:CGPointMake(0, -starSprite.size.height)];

    emitter.targetNode = skScene;
    dotEmitter.targetNode = skScene;
    
    [starSprite addChild:emitter];
    [starSprite addChild:dotEmitter];
    
    [skView presentScene:skScene];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, viewOrigin.x, viewOrigin.y);
    
    CGPoint endPoint = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + 100);
    UIBezierPath *bp = [UIBezierPath new];
    [bp moveToPoint:viewOrigin];
    
    // curvy path
    // control points "pull" the curve to that point on the screen. You should be smarter then just using magic numbers like below.
    [bp addCurveToPoint:endPoint controlPoint1:CGPointMake(viewOrigin.x + 500, viewOrigin.y + 275) controlPoint2:CGPointMake(-200, skView.frame.size.height - 250)];
        
    __weak typeof(containerView) weakView = containerView;
    SKAction *followline = [SKAction followPath:bp.CGPath asOffset:YES orientToPath:YES duration:3.0];
    
    SKAction *done = [SKAction runBlock:^{
        // lets delay until all particles are removed
        int64_t delayInSeconds = 2.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakView removeFromSuperview];
        });
    }];
    
    [starSprite runAction:[SKAction sequence:@[followline, done]]];
    
    [self.view addSubview:containerView];
}

- (void)shootOffCoreAnimationStarFromView:(UIView *)view {
    self.caStarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filled_star"]];
    self.caStarImageView.alpha = 1.0f;
    CGRect imageFrame = CGRectMake(self.caStarImageView.frame.origin.x, self.caStarImageView.frame.origin.y, 50, 50);
    
    //Your image frame.origin from where the animation need to get start
    CGPoint viewOrigin = self.caStarImageView.frame.origin;
    
    viewOrigin.y = self.view.frame.size.height;
    viewOrigin.x = (view.frame.origin.x + (view.frame.size.width / 2));
    
    self.caStarImageView.frame = imageFrame;
    self.caStarImageView.layer.position = viewOrigin;
    [self.view addSubview:self.caStarImageView];
    
    // need to rotate the image to get it on the right tangent
    self.caStarImageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    
    // particles emitters
    self.caStarEmitter = [CAEmitterLayer new];
    self.caStarEmitter.emitterPosition = CGPointMake((self.caStarImageView.frame.size.width / 2) - 5, self.caStarImageView.frame.size.height);
    self.caStarEmitter.emitterShape = kCAEmitterLayerLine;
    self.caStarEmitter.emitterZPosition = 10; // 3;
    self.caStarEmitter.emitterSize = CGSizeMake(0.5, 0.5);
    
    CAEmitterCell *star = [self makeEmitterCellWithShape:0];
    CAEmitterCell *star2 = [self makeEmitterCellWithShape:0];
    CAEmitterCell *star3 = [self makeEmitterCellWithShape:0];
    
    CAEmitterCell *circle = [self makeEmitterCellWithShape:1];
    CAEmitterCell *circle2 = [self makeEmitterCellWithShape:1];
    CAEmitterCell *circle3 = [self makeEmitterCellWithShape:1];
    
    self.caStarEmitter.emitterCells = @[star, star2, star3, circle, circle2, circle3];
    [self.caStarImageView.layer addSublayer:self.caStarEmitter];
    
    // Set up fade out effect
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationCubicPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.rotationMode = kCAAnimationRotateAuto;
    
    //Setting Endpoint of the animation
    CGPoint endPoint = CGPointMake(self.view.frame.size.width, -100);
    UIBezierPath *bp = [UIBezierPath new];
    [bp moveToPoint:viewOrigin];
    
    // control points "pull" the curve to that point on the screen. You should be smarter then just using magic numbers like below.
    [bp addCurveToPoint:endPoint controlPoint1:CGPointMake(endPoint.x - 400, endPoint.y + 200) controlPoint2:endPoint];
    
    pathAnimation.path = bp.CGPath;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, nil]];
    group.duration = 2.3f;
    group.delegate = self;
    [group setValue:self.caStarImageView forKey:@"imageViewBeingAnimated"];
    
    [self.caStarImageView.layer addAnimation:group forKey:@"savingAnimation"];
}

- (CAEmitterCell *)makeEmitterCellWithShape:(NSInteger)shape {
    CAEmitterCell *cell = [CAEmitterCell new];
    cell.velocity = [self randFloatBetween:125 and:200];
    cell.velocityRange = [self randFloatBetween:15 and:40];
    cell.emissionLongitude = M_PI;
    cell.emissionRange = M_PI_4;
    cell.spin = 2;
    cell.spinRange = 10;
    cell.scale = 0.2;
    cell.scaleSpeed = -0.05;
    
    cell.lifetime = [self randFloatBetween:0.3 and:0.75];
    cell.lifetimeRange = [self randFloatBetween:0.6 and:1.5];
    
    if (shape == 0) {
        cell.color = [UIColor yellowColor].CGColor;
        cell.contents = (id)[[UIImage imageNamed:@"filled_star"] CGImage];
        cell.birthRate = 15;
    }
    else {
        cell.color = [UIColor orangeColor].CGColor;
        cell.contents = (id)[[UIImage imageNamed:@"asterisk_filled"] CGImage];
        cell.birthRate = 40;
    }
    
    return cell;
}

- (CGFloat)randFloatBetween:(float)low and:(float)high {
    float diff = high - low;
    return (((float) rand() / RAND_MAX) * diff) + low;
}

#pragma mark - Delegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    if (finished) {
        // stop emitting particles, and wait a couple seconds so they all have time to disappear
        self.caStarEmitter.birthRate = 0;
        
        __weak typeof(self) weakSelf = self;
        int64_t delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.caStarImageView removeFromSuperview];
        });
    }
}

@end

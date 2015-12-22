//
//  ViewController.m
//  ShootingStar
//
//  Created by Ryan Garchinsky on 12/21/15.
//  Copyright © 2015 garapps. All rights reserved.
//

#define SCREEN_SCALE [[UIScreen mainScreen] scale]

#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *fireButton;

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:0.57 green:0.66 blue:0.74 alpha:1];
        
        self.fireButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fireButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fireButton setTitle:@"Touch Here" forState:UIControlStateNormal];
        [self.fireButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.fireButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3f]];
        [self.fireButton setTintColor:[UIColor grayColor]];
        [self.fireButton addTarget:self action:@selector(fireTouched) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.fireButton];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fireButton(100)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_fireButton)]];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_fireButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_fireButton)]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)fireTouched {
    [self addToBasketAnimationFromView:self.fireButton];
}

- (void)addToBasketAnimationFromView:(UIView *)view {
    CGPoint viewOrigin;
    
    CGRect frame = [self.view convertRect:view.frame fromView:view];
    viewOrigin.y = 20;
    viewOrigin.x = (frame.size.width / 2) / 2;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    containerView.userInteractionEnabled = NO;
    
    SKView *skView = [[SKView alloc] initWithFrame:containerView.frame];
    skView.allowsTransparency = YES;
    [containerView addSubview:skView];
    
    SKScene *skScene = [SKScene sceneWithSize:skView.frame.size];
    skScene.scaleMode = SKSceneScaleModeAspectFill;
    skScene.backgroundColor = [UIColor clearColor];
    
    SKSpriteNode *starSprite = [SKSpriteNode spriteNodeWithImageNamed:@"filled_star"];
    [starSprite setScale:0.6];
    starSprite.position = viewOrigin;
    [skScene addChild:starSprite];
    
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"StarParticle" ofType:@"sks"]];
    //SKEmitterNode *dotEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"DotParticle" ofType:@"sks"]];
    [emitter setParticlePosition:CGPointMake(0, -starSprite.size.height)];
    emitter.targetNode = skScene;
    //dotEmitter.targetNode = skScene;
    
    [starSprite addChild:emitter];
    //[starSprite addChild:dotEmitter];
    
    [skView presentScene:skScene];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, viewOrigin.x, viewOrigin.y);
    
    CGPoint endPoint = CGPointMake(0, self.view.frame.size.height + 100);
    UIBezierPath *bp = [UIBezierPath new];
    [bp moveToPoint:viewOrigin];
    
    // curvy path
    //[bp addCurveToPoint:endPoint controlPoint1:CGPointMake(viewOrigin.x + 300, viewOrigin.y + 275) controlPoint2:CGPointMake(-400, skView.frame.size.height - 250)];
    
    [bp addCurveToPoint:endPoint controlPoint1:endPoint controlPoint2:endPoint];
    
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

/*
- (void)addToBasketAnimationFdddromButton:(UIButton *)button {
    UIImageView *imageViewForAnimation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_star"]];
    imageViewForAnimation.alpha = 1.0f;
    CGRect imageFrame = imageViewForAnimation.frame;
    //Your image frame.origin from where the animation need to get start
    CGPoint viewOrigin = imageViewForAnimation.frame.origin;
    
    CGRect frame = [self.view convertRect:button.frame fromView:button];
    viewOrigin.y = frame.origin.y + (frame.size.height / 2);
    viewOrigin.x = frame.size.width / 2;
    
    imageViewForAnimation.frame = imageFrame;
    imageViewForAnimation.layer.position = viewOrigin;
    [self.view addSubview:imageViewForAnimation];
    
    imageViewForAnimation.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    
    //particles
    CAEmitterLayer *emitter = [CAEmitterLayer new];
    emitter.emitterPosition = CGPointMake((imageViewForAnimation.width / 2) - 5, imageViewForAnimation.height);
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterZPosition = 10; // 3;
    emitter.emitterSize = CGSizeMake(0.5, 0.5);
    
    CAEmitterCell *star = [self makeEmitterCellWithShape:FPPDPAddToBasketAnimationShapeStar];
    CAEmitterCell *star2 = [self makeEmitterCellWithShape:FPPDPAddToBasketAnimationShapeStar];
    CAEmitterCell *star3 = [self makeEmitterCellWithShape:FPPDPAddToBasketAnimationShapeStar];
    
    CAEmitterCell *circle = [self makeEmitterCellWithShape:FPPDPAddToBasketAnimationShapeCircle];
    CAEmitterCell *circle2 = [self makeEmitterCellWithShape:FPPDPAddToBasketAnimationShapeCircle];
    CAEmitterCell *circle3 = [self makeEmitterCellWithShape:FPPDPAddToBasketAnimationShapeCircle];
    
    emitter.emitterCells = @[star, star2, star3, circle, circle2, circle3];
    [imageViewForAnimation.layer addSublayer:emitter];
    // end particles
    
    // Set up fade out effect
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Rotate
    //    CABasicAnimation *animation = [CABasicAnimation   animationWithKeyPath:@"transform.rotation.z"];
    //    animation.duration = 0.7;
    //    animation.additive = YES;
    //    animation.removedOnCompletion = NO;
    //    animation.fillMode = kCAFillModeForwards;
    //    animation.fromValue = [NSNumber numberWithFloat:0];
    //    animation.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(90)];
    //    [imageViewForAnimation.layer addAnimation:animation forKey:@"90rotation"];
    
    // Set up scaling
    //    CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    //    [resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(40.0f, imageFrame.size.height * (40.0f / imageFrame.size.width))]];
    //    resizeAnimation.fillMode = kCAFillModeForwards;
    //    resizeAnimation.removedOnCompletion = NO;
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationCubicPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.rotationMode = kCAAnimationRotateAuto;
    
    //Setting Endpoint of the animation
    CGPoint endPoint = CGPointMake(self.navigationController.navigationBar.frame.size.width - 50, self.navigationController.navigationBar.frame.origin.y - 35);
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    
    UIBezierPath *bp = [UIBezierPath new];
    [bp moveToPoint:viewOrigin];
    
    // curvy
    //[bp addCurveToPoint:endPoint controlPoint1:CGPointMake(viewOrigin.x + 300, viewOrigin.y - 275) controlPoint2:CGPointMake(-200, 400)];
    
    // shooting star
    [bp addCurveToPoint:endPoint controlPoint1:CGPointMake(viewOrigin.x - [self randFloatBetween:0 and:400], viewOrigin.y - [self randFloatBetween:225 and:325]) controlPoint2:endPoint];
    
    pathAnimation.path = bp.CGPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, nil]];
    group.duration = 2.3f;
    group.delegate = self;
    [group setValue:imageViewForAnimation forKey:@"imageViewBeingAnimated"];
    
    [imageViewForAnimation.layer addAnimation:group forKey:@"savingAnimation"];
}

- (CAEmitterCell *)makeEmitterCellWithShape:(FPPDPAddToBasketAnimationShape)shape {
    CAEmitterCell *cell = [CAEmitterCell new];
    cell.velocity = [self randFloatBetween:125 and:200];
    cell.velocityRange = [self randFloatBetween:15 and:40];
    cell.emissionLongitude = M_PI;
    cell.emissionRange = M_PI_4;
    cell.spin = 2;
    cell.spinRange = 10;
    cell.scaleRange = 0.5;
    cell.scaleSpeed = -0.05;
    
    cell.lifetime = [self randFloatBetween:0.3 and:0.75];
    cell.lifetimeRange = [self randFloatBetween:0.6 and:1.5];
    
    if (shape == FPPDPAddToBasketAnimationShapeStar) {
        cell.color = [UIColor fp_pink].CGColor;
        cell.contents = (id)[[UIImage imageNamed:@"little_star"] CGImage];
        cell.scaleRange = 0.5;
        cell.scaleSpeed = -0.05;
        cell.birthRate = 15;
    }
    else {
        cell.color = [UIColor fp_meAccent].CGColor;
        cell.contents = (id)[[UIImage imageNamed:@"anim_dot"] CGImage];
        cell.birthRate = 40;
    }
    
    return cell;
}

- (CGFloat)randFloatBetween:(float)low and:(float)high {
    float diff = high - low;
    return (((float) rand() / RAND_MAX) * diff) + low;
}
*/

@end

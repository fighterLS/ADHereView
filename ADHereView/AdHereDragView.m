
//
//  AdHereDragView.m
//  ADHereView
//
//  Created by 李赛 on 16/12/8.
//  Copyright © 2016年 李赛. All rights reserved.
//
#define IS_IPAD_IDIOM (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_IDIOM (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

#import "AdHereDragView.h"

@interface XFATLayoutAttributes : NSObject

+ (CGRect)contentViewSpreadFrame;
+ (CGPoint)cotentViewDefaultPoint;
+ (CGFloat)itemWidth;
+ (CGFloat)itemImageWidth;
+ (CGFloat)cornerRadius;
+ (CGFloat)margin;
+ (NSUInteger)maxCount;

+ (CGFloat)inactiveAlpha;
+ (CGFloat)animationDuration;
+ (CGFloat)activeDuration;

@end
@implementation XFATLayoutAttributes

// iPad   width 390 itemWidth 76 margin 2 corner:14  48-41-33
// iPhone width 295 itemWidth 60 margin 2 corner:14  44-38-30

+ (CGRect)contentViewSpreadFrame {
    CGFloat spreadWidth = IS_IPAD_IDIOM? 390: 295;
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake((CGRectGetWidth(screenFrame) - spreadWidth) / 2,
                              (CGRectGetHeight(screenFrame) - spreadWidth) / 2,
                              spreadWidth, spreadWidth);
    return frame;
}

+ (CGPoint)cotentViewDefaultPoint {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGPoint point = CGPointMake(CGRectGetWidth(screenFrame)
                                - [self itemImageWidth] / 2
                                - [self margin],
                                CGRectGetMidY(screenFrame));
    return point;
}

+ (CGFloat)itemWidth {
    return CGRectGetWidth([self contentViewSpreadFrame]) / 3.0;
}

+ (CGFloat)itemImageWidth {
    return IS_IPAD_IDIOM? 76: 60;
}

+ (CGFloat)cornerRadius {
    return 14;
}

+ (CGFloat)margin {
    return 2;
}

+ (NSUInteger)maxCount {
    return 8;
}

+ (CGFloat)inactiveAlpha {
    return 0.4;
}

+ (CGFloat)animationDuration {
    return 0.25;
}

+ (CGFloat)activeDuration {
    return 4;
}
@end

@implementation AdHereDragView
+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

/**
 [UIApplication sharedApplication].keyWindow=nil时，将方法放在viewDidAppear中
 */
- (void)showAssistiveTouch {
   
    _assistiveWindow =  [UIApplication sharedApplication].keyWindow;
    [_assistiveWindow makeKeyAndVisible];
    [_assistiveWindow addSubview:_contentView];
}

-(instancetype)init
{
    self=[super init];
    if (self) {
        _contentPoint = [XFATLayoutAttributes cotentViewDefaultPoint];
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [XFATLayoutAttributes itemImageWidth], [XFATLayoutAttributes itemImageWidth])];
        _contentView.backgroundColor=[UIColor yellowColor];
        _contentView.layer.cornerRadius = 14;
        _contentView.center = _contentPoint;
        self.contentAlpha = [XFATLayoutAttributes inactiveAlpha];
        
        //        UITapGestureRecognizer *spreadGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spread)];
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        //        [self.contentView addGestureRecognizer:spreadGestureRecognizer];
        [self.contentView addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}


#pragma mark - Timer

- (void)beginTimer {
    _timer = [NSTimer timerWithTimeInterval:[XFATLayoutAttributes activeDuration] target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFired {
    [UIView animateWithDuration:[XFATLayoutAttributes animationDuration] animations:^{
        self.contentAlpha = [XFATLayoutAttributes inactiveAlpha];
    }];
    [self stopTimer];
}

#pragma mark - Action

- (void)panGestureAction:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:_assistiveWindow];
    
    static CGPoint pointOffset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointOffset = [gestureRecognizer locationInView:self.contentView];
    });
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self stopTimer];
        [UIView animateWithDuration:[XFATLayoutAttributes animationDuration] animations:^{
            self.contentAlpha = 1;
        }];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.contentPoint = CGPointMake(point.x + [XFATLayoutAttributes itemImageWidth] / 2 - pointOffset.x, point.y  + [XFATLayoutAttributes itemImageWidth] / 2 - pointOffset.y);
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled
               || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [UIView animateWithDuration:[XFATLayoutAttributes animationDuration] animations:^{
            self.contentPoint = [self stickToPointByHorizontal];
        } completion:^(BOOL finished) {
            onceToken = NO;
            [self beginTimer];
        }];
    }
}
- (void)setContentPoint:(CGPoint)contentPoint {
    _contentPoint = contentPoint;
    _contentView.center=_contentPoint;
}

- (void)setContentAlpha:(CGFloat)contentAlpha {
    _contentAlpha = contentAlpha;
    _contentView.alpha=_contentAlpha;
}

#pragma mark - StickToPoint

- (CGPoint)stickToPointByHorizontal {
    CGRect screen = [UIScreen mainScreen].bounds;
    CGPoint center = self.contentPoint;
    if (center.y < center.x && center.y < -center.x + screen.size.width) {
        CGPoint point = CGPointMake(center.x, [XFATLayoutAttributes margin] + [XFATLayoutAttributes itemImageWidth] / 2);
        point = [self makePointValid:point];
        return point;
    } else if (center.y > center.x + screen.size.height - screen.size.width
               && center.y > -center.x + screen.size.height) {
        CGPoint point = CGPointMake(center.x, CGRectGetHeight(screen) - [XFATLayoutAttributes itemImageWidth] / 2 - [XFATLayoutAttributes margin]);
        point = [self makePointValid:point];
        return point;
    } else {
        if (center.x < screen.size.width / 2) {
            CGPoint point = CGPointMake([XFATLayoutAttributes margin] + [XFATLayoutAttributes itemImageWidth] / 2, center.y);
            point = [self makePointValid:point];
            return point;
        } else {
            CGPoint point = CGPointMake(CGRectGetWidth(screen) - [XFATLayoutAttributes itemImageWidth] / 2 - [XFATLayoutAttributes margin], center.y);
            point = [self makePointValid:point];
            return point;
        }
    }
}

- (CGPoint)makePointValid:(CGPoint)point {
    CGRect screen = [UIScreen mainScreen].bounds;
    if (point.x < [XFATLayoutAttributes margin] + [XFATLayoutAttributes itemImageWidth] / 2) {
        point.x = [XFATLayoutAttributes margin] + [XFATLayoutAttributes itemImageWidth] / 2;
    }
    if (point.x > CGRectGetWidth(screen) - [XFATLayoutAttributes itemImageWidth] / 2 - [XFATLayoutAttributes margin]) {
        point.x = CGRectGetWidth(screen) - [XFATLayoutAttributes itemImageWidth] / 2 - [XFATLayoutAttributes margin];
    }
    if (point.y < [XFATLayoutAttributes margin] + [XFATLayoutAttributes itemImageWidth] / 2) {
        point.y = [XFATLayoutAttributes margin] + [XFATLayoutAttributes itemImageWidth] / 2;
    }
    if (point.y > CGRectGetHeight(screen) - [XFATLayoutAttributes itemImageWidth] / 2 - [XFATLayoutAttributes margin]) {
        point.y = CGRectGetHeight(screen) - [XFATLayoutAttributes itemImageWidth] / 2 - [XFATLayoutAttributes margin];
    }
    return point;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

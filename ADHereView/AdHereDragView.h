//
//  AdHereDragView.h
//  ADHereView
//
//  Created by 李赛 on 16/12/8.
//  Copyright © 2016年 李赛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdHereDragView : NSObject
+ (instancetype)sharedInstance;
/**
 [UIApplication sharedApplication].keyWindow=nil时，将方法放在viewDidAppear中
 */
- (void)showAssistiveTouch;
@property (nonatomic, strong) UIWindow *assistiveWindow;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGPoint contentPoint;
@property (nonatomic, assign) CGFloat contentAlpha;
@property (nonatomic, strong) NSTimer *timer;
@end

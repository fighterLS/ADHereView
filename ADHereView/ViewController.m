//
//  ViewController.m
//  ADHereView
//
//  Created by 李赛 on 16/12/8.
//  Copyright © 2016年 李赛. All rights reserved.
//

#import "ViewController.h"
#import "AdHereDragView.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [ [AdHereDragView sharedInstance] showAssistiveTouch];

    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AdHereDragView sharedInstance] showAssistiveTouch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  ViewController.m
//  RulerView
//
//  Created by Story5 on 4/18/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import "ViewController.h"
#import "RulerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RulerView *rulerView = [[RulerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:rulerView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

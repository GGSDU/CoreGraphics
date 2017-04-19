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

@property (strong,nonatomic) dispatch_semaphore_t semaphore;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RulerView *rulerView = [[RulerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:rulerView];
    
//    self.semaphore = dispatch_semaphore_create(0);
//    // Do any additional setup after loading the view, typically from a nib.
//    [self test];
//    NSLog(@"q31111");
}

- (void)test{
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"hellO");
        dispatch_semaphore_signal(weakSelf.semaphore);
    });
    
    dispatch_semaphore_wait(weakSelf.semaphore, DISPATCH_TIME_FOREVER);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

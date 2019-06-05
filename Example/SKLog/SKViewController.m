//
//  SKViewController.m
//  SKLog
//
//  Created by Xcoder1011 on 05/29/2019.
//  Copyright (c) 2019 Xcoder1011. All rights reserved.
//

#import "SKViewController.h"

@interface SKViewController ()

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    SKLog(@"默认的log使用方式");
    
    SKLogg(999, @"我这是一种type==999 的Log");
    
    for (NSInteger i = 0; i < 100; i ++ ) {
        SKLogg(83, @"我这是 i = %zd",i);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"sortedLogDirectorieNames = %@",[SKLogger sortedLogDirectorieNames]);
        NSLog(@"sortedLogDirectoriePaths = %@",[SKLogger sortedLogDirectoriePaths]);
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

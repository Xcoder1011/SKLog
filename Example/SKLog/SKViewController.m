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
    
    SKLog(3, @"你好");

    SKLog(0, @"NIHAO");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

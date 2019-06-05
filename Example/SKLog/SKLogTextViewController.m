//
//  SKLogTextViewController.m
//  SKLog_Example
//
//  Created by shangkun on 2019/6/5.
//  Copyright © 2019年 Xcoder1011. All rights reserved.
//

#import "SKLogTextViewController.h"

@interface SKLogTextViewController ()

@property (nonatomic, strong) UITextView *textview;

@end

@implementation SKLogTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textview = [[UITextView alloc] initWithFrame:self.view.bounds];
    _textview.font = [UIFont systemFontOfSize:12];
    _textview.textColor = UIColor.whiteColor;
    _textview.backgroundColor = [UIColor blackColor];
    _textview.editable = NO;
    NSString *text = [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil];
    _textview.text = text;
    [self.view addSubview:_textview];
}



@end

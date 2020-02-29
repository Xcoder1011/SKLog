//
//  SKPreviewLogController.m
//  Pods
//
//  Created by KUN on 2019/5/31.
//

#import "SKPreviewLogController.h"
#import <WebKit/WebKit.h>
#import "SKLogger.h"

typedef void(^SearchResultBlock)(NSInteger searchCount);

@interface SKPreviewLogController ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation SKPreviewLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configWebView];
}

- (void)configWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSString *lastName =[[self.logPath lastPathComponent] lowercaseString];
    if ([lastName containsString:@".log"]) {
        NSStringEncoding *useEncodeing = nil;
        NSString *body = [NSString stringWithContentsOfFile:self.logPath usedEncoding:useEncodeing error:nil];
        if (!body) {
            body = [NSString stringWithContentsOfFile:self.logPath encoding:0x80000632 error:nil];
        }
        if (!body) {
            body = [NSString stringWithContentsOfFile:self.logPath encoding:0x80000631 error:nil];
        }
        if (body) {
            NSString* responseStr = [NSString stringWithFormat:
                                     @"<HTML>"
                                     "<head>"
                                     "<title>Text View</title>"
                                     "</head>"
                                     "<BODY>"
                                     "<pre>"
                                     "%@"
                                     "</pre>"
                                     "</BODY>"
                                     "</HTML>",
                                     body];
            [self.webView loadHTMLString:responseStr baseURL:nil];
        }else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.logPath]];
            [_webView loadRequest:request];
        }
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.logPath]];
        [_webView loadRequest:request];
    }
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
}


@end

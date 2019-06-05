//
//  SKViewController.m
//  SKLog
//
//  Created by Xcoder1011 on 05/29/2019.
//  Copyright (c) 2019 Xcoder1011. All rights reserved.
//

#import "SKViewController.h"
#import "SKLogTextViewController.h"

@interface SKViewController ()

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!_dataArray) {
        _dataArray = [SKLogger sortedLogDirectoriePaths];
    }
    
    self.title = @"SKLog";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSString *content = _dataArray[indexPath.row];
    if ([content containsString:@"/"]) {
        content = [[content componentsSeparatedByString:@"/"] lastObject];
    }
    cell.textLabel.text = content;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    NSString *path = _dataArray[indexPath.row];
    
    if ([path containsString:@"/"]) {
       
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        SKViewController *controller = [[SKViewController alloc] init];
        controller.dataArray = files;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if ([path hasSuffix:@".log"] || [path hasSuffix:@".txt"]) {
        
        SKLogTextViewController *controller = [[SKLogTextViewController alloc] init];
        NSString *dirname = [[path componentsSeparatedByString:@"."] firstObject];
        dirname = [[dirname componentsSeparatedByString:@"_"] firstObject];
        controller.logPath = [[[SKLogger sharedInstance].logsDirectory stringByAppendingPathComponent:dirname] stringByAppendingPathComponent:path];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

@end

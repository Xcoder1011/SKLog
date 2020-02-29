//
//  SKUploadLogController.m
//  Pods
//
//  Created by KUN on 2019/5/31.
//

#import "SKUploadLogController.h"
#import "SKPreviewLogController.h"

@interface SKUploadLogController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectDataArray;
@property (nonatomic, strong) dispatch_semaphore_t selectDatasLock;

@end

@implementation SKUploadLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectDatasLock = dispatch_semaphore_create(1);
    self.title = @"上传日志";
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:[SKLogger sortedLogDirectoriePaths]];
    }
    if (!_selectDataArray) {
        _selectDataArray = [NSMutableArray arrayWithCapacity:1];
    }
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectDataArray)) options:(NSKeyValueObservingOptionNew) context:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarItemClicked)];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        // Fallback on earlier versions
    }
    [self.tableView reloadData];
    [self.tableView setEditing:YES animated:YES];
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)leftBarItemClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarItemClicked {
    if (self.selectDataArray.count) {
        NSMutableArray *fileNames = @[].mutableCopy;
        NSMutableArray *filePaths = @[].mutableCopy;
        dispatch_semaphore_wait(self.selectDatasLock, DISPATCH_TIME_FOREVER);
        [self.selectDataArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull fileDir, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileDir error:nil];
            if (files && files.count) {
                NSString *fileName = [files firstObject];
                NSString *filePath = [fileDir stringByAppendingPathComponent:fileName];
                [fileNames addObject:fileName];
                [filePaths addObject:filePath];
            }
        }];
        dispatch_semaphore_signal(self.selectDatasLock);
        if (self.selectLogFileBlock) {
            self.selectLogFileBlock([fileNames copy], [filePaths copy]);
        }
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sk_showToast:(NSString *)msg {
    
    UILabel *messageLabel = nil;
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = 10.0;
    wrapperView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    if (msg != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        messageLabel.font = [UIFont systemFontOfSize:16.0];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = msg;
        CGSize maxSizeMessage = CGSizeMake((self.view.bounds.size.width * 0.8), self.view.bounds.size.height * 0.8);
        CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
        expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width), MIN(maxSizeMessage.height, expectedSizeMessage.height));
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
   
    CGRect messageRect = CGRectZero;
    
    if(messageLabel != nil) {
        messageRect.origin.x = 10;
        messageRect.origin.y = 10;
        messageRect.size.width = messageLabel.bounds.size.width;
        messageRect.size.height = messageLabel.bounds.size.height;
    }
    
    CGFloat longerWidth = messageRect.size.width;
    CGFloat longerX = messageRect.origin.x;
    
    CGFloat wrapperWidth = MAX(((10 * 2.0)), (longerX + longerWidth + 10));
    CGFloat wrapperHeight = MAX((messageRect.origin.y + messageRect.size.height +10), 20);
    
    wrapperView.frame = CGRectMake((self.view.bounds.size.width - wrapperWidth)/2.0,(self.view.bounds.size.height - wrapperHeight)/2.0, wrapperWidth, wrapperHeight);
    
    if(messageLabel != nil) {
        messageLabel.frame = messageRect;
        [wrapperView addSubview:messageLabel];
    }
    
    [self.view addSubview:wrapperView];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         wrapperView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [self sk_HideToast:wrapperView];
                             });
                         }
                     }];
}

- (void)sk_HideToast:(UIView *)view {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         view.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

- (void)longPressView:(UILongPressGestureRecognizer *)ges {
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        if ([ges.view isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell =  (UITableViewCell *)ges.view;
            NSString *fileDir = self.dataArray[cell.tag];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileDir error:nil];
            if (files && files.count) {
                NSString *fileName = [files firstObject];
                NSString *filePath = [fileDir stringByAppendingPathComponent:fileName];
                SKPreviewLogController *controller = [[SKPreviewLogController alloc] init];
                controller.logPath = filePath;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if([keyPath isEqualToString:NSStringFromSelector(@selector(selectDataArray))]) {
        if (self.selectDataArray.count > 0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemClicked)];
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
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
    cell.tag = indexPath.row;

#ifdef DEBUG
    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressView:)];
    longPressGest.minimumPressDuration = 2;
    [cell addGestureRecognizer:longPressGest];
#endif
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!tableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[self mutableArrayValueForKeyPath:NSStringFromSelector(@selector(selectDataArray))] addObject:self.dataArray[indexPath.row]];
        [self rightBarItemClicked];
    } else {
        if (self.selectDataArray.count >= self.maxSelectFilesCount) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self sk_showToast:[NSString stringWithFormat:@"一次最多上报%tu个文件",self.maxSelectFilesCount]];
            return;
        }
        [[self mutableArrayValueForKeyPath:NSStringFromSelector(@selector(selectDataArray))] addObject:self.dataArray[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.editing) {
        [[self mutableArrayValueForKeyPath:NSStringFromSelector(@selector(selectDataArray))] removeObject:self.dataArray[indexPath.row]];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    } else  {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *sendAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"发送" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [self.selectDataArray addObject:self.dataArray[indexPath.row]];
        [self rightBarItemClicked];
    }];
    sendAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *previewAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"查看" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSString *fileDir =  self.dataArray[indexPath.row];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileDir error:nil];
        if (files && files.count) {
            NSString *fileName = [files firstObject];
            NSString *filePath = [fileDir stringByAppendingPathComponent:fileName];
            SKPreviewLogController *controller = [[SKPreviewLogController alloc] init];
            controller.logPath = filePath;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
    
#ifdef DEBUG
    return @[sendAction, previewAction];
#endif
    return @[sendAction];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectDataArray))];
}

@end

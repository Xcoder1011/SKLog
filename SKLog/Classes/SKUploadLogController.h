//
//  SKUploadLogController.h
//  Pods
//
//  Created by KUN on 2019/5/31.
//

#import <UIKit/UIKit.h>
#import "SKLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKUploadLogController : UITableViewController

@property (nonatomic, copy) SKMultiSelectLogFileBlock  selectLogFileBlock;

@property (nonatomic, assign) NSUInteger  maxSelectFilesCount;

@end

NS_ASSUME_NONNULL_END

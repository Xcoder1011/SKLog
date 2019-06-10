//
//  SKLogger.h
//  Pods
//
//  Created by shangkun on 2019/5/31.
//

#import <Foundation/Foundation.h>
#import "SKLogHeader.h"

NS_ASSUME_NONNULL_BEGIN


/**
 功能 == NSLog
 
 @param ... type:默认为 0
 */
#define SKLog(...)  SKDebugLog(0, SKLOCATION(), __VA_ARGS__)


/**
 可支持 不同类型的 Log
 
 @param type > 0
 */
#define SKLogg(type, ...)  SKDebugLog(type, SKLOCATION(), __VA_ARGS__)


@interface SKLogger : NSObject

@property (class, nonatomic, strong, readonly) SKLogger *sharedInstance;

/// 排序好的 log文件夹路径
@property (class, nonatomic, strong, readonly) NSArray <NSString *> *sortedLogDirectoriePaths;

/// 排序好的 log文件夹名称
@property (class, nonatomic, strong, readonly) NSArray <NSString *> *sortedLogDirectorieNames;

/// 支持自定义的Log时间格式
@property (nonatomic, strong) NSDateFormatter *logDateFormatter;

/// 支持自定义Log文件夹名称, 默认使用时格式@"yyyy-MM-dd HH:mm:ss"
@property (nonatomic, strong) NSDateFormatter *logDirDateFormatter;

/// 自定义type说明 ,Example: @{ @(11):@"PK赛", @(22):@"答题模式" };
@property (nonatomic, strong) NSDictionary <NSNumber *, NSString *> *typeDescriptionConfig;

/// 记录的文件夹最大数 ，default = 10
@property (atomic, assign, readwrite) NSUInteger maximumNumberOfLogsDirectories;

/// 存储log日志的文件夹路径
@property (nonatomic, copy, readonly) NSString *logsDirectory;

/// 本次启动创建的日志文件夹路径
@property (nonatomic, copy, readonly) NSString *currentLogsDirectory;

/// 日志模式是否打开
@property (nonatomic, assign , readonly) BOOL enableMode;

/// 打开记录日志模式
- (void)enable;

- (void)parseStringWithLocation:(SKLocation)loc type:(NSInteger)type string:(NSString *)string;

FOUNDATION_EXTERN void SKDebugLog(NSInteger type, SKLocation location, NSString *format, ...);

@end

NS_ASSUME_NONNULL_END


/// For Example SKLog Path :


///  .../SKLog

///  .../SKLog/2019-05-31-14:01:58/
///  .../SKLog/2019-05-31-14:03:58/
///  .../SKLog/2019-05-31-14:04:11/

///  .../SKLog/2019-05-31-14:01:58/2019-05-31-14:01:58.log

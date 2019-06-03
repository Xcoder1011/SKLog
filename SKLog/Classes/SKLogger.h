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

/// 支持自定义的时间格式
@property (nonatomic, strong) NSDateFormatter *logDateFormatter;

/// 存储log日志的文件目录
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

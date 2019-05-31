//
//  SKLogger.h
//  Pods
//
//  Created by shangkun on 2019/5/31.
//

#import <Foundation/Foundation.h>

//FOUNDATION_EXPORT void SKLog(NSInteger type, NSString *format, ...);

extern void SKLog(NSInteger type, NSString *format, ...);

NS_ASSUME_NONNULL_BEGIN

@interface SKLogger : NSObject

@property (class, nonatomic, strong, readonly) SKLogger *sharedInstance;

@property (nonatomic, copy, readonly) NSString *logsDirectory;

- (void)enable;

@end

NS_ASSUME_NONNULL_END

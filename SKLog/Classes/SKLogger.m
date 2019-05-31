//
//  SKLogger.m
//  Pods
//
//  Created by shangkun on 2019/5/31.
//

#import "SKLogger.h"

void SKLog(NSInteger type, NSString *format, ...) {
    
    NSString *string = nil;
    va_list argList;
    va_start(argList, format);
    string = [[NSString alloc] initWithFormat:format arguments:argList];
    string = [NSString stringWithFormat:@"Function:%s Line:%d info:%@",__func__,__LINE__,string];
    NSLog(@"%@", string);
    va_end(argList);
}

static dispatch_queue_t writeLogQueue;

@interface SKLogger ()

@property (nonatomic, copy, readwrite) NSString *logsDirectory;

@end

@implementation SKLogger

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)initialize {
    static dispatch_once_t logonceToken;
    dispatch_once(&logonceToken, ^{
        writeLogQueue =  dispatch_queue_create("com.SKLog.writeLogQueue", DISPATCH_QUEUE_SERIAL);
    });
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configLogPath];
    }
    return self;
}

- (void)configLogPath {
    
    [self logsDirectory];
    
}

- (NSString *)logsDirectory {
    
    if (!_logsDirectory) {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _logsDirectory = [documentsDirectory stringByAppendingPathComponent:@"SKLog"];
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_logsDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_logsDirectory
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                NSLog(@"create logsDirectory error.");
            }
        }
    }
    NSLog(@"logsDirectory = %@",_logsDirectory);
    // logsDirectory = /var/mobile/Containers/Data/Application/FDB11EAC-2B52-4BE9-B50F-DFDDDFF06A5E/Documents/SKLog
    return _logsDirectory;
}

- (void)enable {
    
}

@end

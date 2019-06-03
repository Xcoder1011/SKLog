//
//  SKLogger.m
//  Pods
//
//  Created by shangkun on 2019/5/31.
//

#import "SKLogger.h"

void SKDebugLog(NSInteger type, SKLocation location, NSString *format, ...) {
    
    if ([SKLogger sharedInstance].enableMode) {
        NSString *string = nil;
        va_list argList;
        va_start(argList, format);
        string = [[NSString alloc] initWithFormat:format arguments:argList];
        [[SKLogger sharedInstance] parseStringWithLocation:location type:type string:string];
        va_end(argList);
    }
}

static inline NSString *getFileNameAndFunctionFromLocation(SKLocation location)
{
    NSString *string;
    SKLocation initialLocation = SKLocationMake("", 0, "");
    if (!memcmp(&location, &initialLocation, sizeof(location))) {
        string = @"";
    } else {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:location.file length:strlen(location.file)];
        NSString *filename = [path lastPathComponent];
        string = [NSString stringWithFormat:@"%@ LINE:%d %s", filename, location.line, location.func];
    }
    return string;
}

static dispatch_queue_t writeLogQueue;

@interface SKLogger ()

@property (nonatomic, copy, readwrite) NSString *logsDirectory;
@property (nonatomic, copy, readwrite) NSString *currentLogsDirectory; // launch time
@property (nonatomic, assign , readwrite) BOOL enableMode;
// 记录当前 的启动时间
@property (nonatomic, copy) NSString *currentlaunchTime; // 2019-06-03-14:01:58

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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    _logDateFormatter = dateFormatter;
    [self logsDirectory];
    [self currentLogsDirectory];
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
        NSLog(@"logsDirectory = %@",_logsDirectory);
        // logsDirectory = /var/mobile/Containers/Data/Application/FDB11EAC-2B52-4BE9-B50F-DFDDDFF06A5E/Documents/SKLog
    }
   
    return _logsDirectory;
}

- (void)enable {
    
    _enableMode = YES;
}

- (NSString *)currentLogsDirectory {
    if (!_currentLogsDirectory) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
        NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
        _currentlaunchTime = timestamp;
        _currentLogsDirectory = [self.logsDirectory stringByAppendingPathComponent:timestamp];
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_currentLogsDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_currentLogsDirectory
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                NSLog(@"create currentLogsDirectory error.");
            }
        }
        NSLog(@"currentLogsDirectory = %@",_currentLogsDirectory);
        // currentLogsDirectory = /Users/kun/Library/Developer/CoreSimulator/Devices/F85DCE55-9D55-4C35-9F1F-5772E9B78608/data/Containers/Data/Application/6295454C-BA2E-47FE-AE67-3194561008D7/Documents/SKLog/2019-06-03-14:01:58
    }
    return _currentLogsDirectory;
}


- (void)parseStringWithLocation:(SKLocation)loc type:(NSInteger)type string:(NSString *)string {
    
    dispatch_async(writeLogQueue, ^{
        
        NSString *timestamp = [self.logDateFormatter stringFromDate:[NSDate date]];
        NSString *formatstring = [NSString stringWithFormat:@"%@ TYPE:%zd %@ >>>%@",timestamp, type, getFileNameAndFunctionFromLocation(loc), string];
#ifdef DEBUG
        fprintf (stderr, "%s\n", [formatstring UTF8String]);
#endif
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%zd.log", self.currentlaunchTime,type];
        NSString *filePath = [self.currentLogsDirectory stringByAppendingPathComponent:fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            NSLog(@" ========== createFileAtPath filePath = %@",filePath);
        }
        
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[formatstring dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
    });
}

@end

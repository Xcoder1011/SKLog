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
@property (nonatomic, copy, readwrite) NSString *currentLogsDirectory;
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
        [self configInitial];
        [self configLogPath];
        [self deleteOldLogsDirectories];
    }
    return self;
}

- (void)configInitial {
    _maximumNumberOfLogsDirectories = 10;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(maximumNumberOfLogsDirectories)) options:options context:nil];
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
        if (!sk_isDirExistAtPath(_logsDirectory)) {
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
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
        _currentlaunchTime = timestamp;
        _currentLogsDirectory = [self.logsDirectory stringByAppendingPathComponent:timestamp];
        NSError *error = nil;
        if (!sk_isDirExistAtPath(_currentLogsDirectory)) {
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

- (void)deleteOldLogsDirectories {
    
    NSArray *fileDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.logsDirectory error:nil];
    NSArray *sortedFileDirs = [fileDirs sortedArrayUsingComparator:^NSComparisonResult(NSString  * _Nonnull timeDirKey1, NSString * _Nonnull timeDirKey2) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [dateFormatter dateFromString:timeDirKey1];
        NSDate *date2 = [dateFormatter dateFromString:timeDirKey2];
        return [date2 compare:date1];  // 时间降序 排序， 时间 由近及远
    }];
    
    if (fileDirs.count > _maximumNumberOfLogsDirectories) {
        NSUInteger deleteStartIndex = _maximumNumberOfLogsDirectories;
        for (NSUInteger index = deleteStartIndex; index < sortedFileDirs.count ; index ++) {
            /*
            SKLog/ fileDirs = (
                               "2019-06-03-17:27:11",
                               "2019-06-03-17:26:15",
                               "2019-06-03-17:25:03",
                               "2019-06-03-13:51:10",
                               "2019-06-03-15:31:17",
                               "2019-06-03-11:42:09",
                               "2019-06-03-16:55:57"
                               )
            */
            NSString *timeDirKey = sortedFileDirs[index];
            NSLog(@" delete timeDirName = %@",timeDirKey);
            NSString *timeDirPath = [self.logsDirectory stringByAppendingPathComponent:timeDirKey];
            if (sk_isDirExistAtPath(timeDirPath)) {
                sk_DeleteAllFileAtPath(timeDirPath);
                BOOL flag= [[NSFileManager defaultManager] removeItemAtPath:timeDirPath error:nil];
                if(flag){
                    NSLog(@"删除成功");
                }else{
                    NSLog(@"删除失败");
                }
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    NSNumber *old = change[NSKeyValueChangeOldKey];
    NSNumber *new = change[NSKeyValueChangeNewKey];
   
    if ([old isEqual:new]) {
        return;
    }
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(maximumNumberOfLogsDirectories))]) {
        dispatch_async(writeLogQueue, ^{
           
            [self deleteOldLogsDirectories];
        });
    }
}

- (void)dealloc {
    
    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(maximumNumberOfLogsDirectories)) context:nil];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

@end

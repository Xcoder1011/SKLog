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
        // string = [NSString stringWithFormat:@"%@ LINE:%d %s", filename, location.line, location.func];
        string = [NSString stringWithFormat:@"%@ :%d", filename, location.line];
    }
    return string;
}

static dispatch_queue_t writeLogQueue;

@interface SKLogger ()

@property (nonatomic, copy, readwrite) NSString *logsDirectory;
@property (nonatomic, copy, readwrite) NSString *currentLogsDirectory;
@property (nonatomic, assign , readwrite) BOOL enableMode;
// 记录当前 的启动时间 2019-06-03-14:01:58
@property (nonatomic, copy) NSString *currentlaunchTime;

@end

@implementation SKLogger

+ (instancetype)sharedInstance {
    static id logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[SKLogger alloc] init];
    });
    return logger;
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
    _logDateFormatter = [self dateFormatterWith:@"yyyy-MM-dd HH:mm:ss.SSS"];
    _logDirDateFormatter = [self dateFormatterWith:@"yyyy-MM-dd HH:mm:ss"];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(maximumNumberOfLogsDirectories)) options:options context:nil];
}

- (void)configLogPath {
    
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
    }
   
    return _logsDirectory;
}

- (void)enable {
    
    _enableMode = YES;
}

- (NSString *)currentLogsDirectory {
    if (!_currentLogsDirectory) {
        NSString *timestamp = [_logDirDateFormatter stringFromDate:[NSDate date]];
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
    }
    return _currentLogsDirectory;
}

- (void)parseStringWithLocation:(SKLocation)loc type:(NSInteger)type string:(NSString *)string {
    
    dispatch_async(writeLogQueue, ^{
        
        NSString *timestamp = [self.logDateFormatter stringFromDate:[NSDate date]];
        NSString *typeDesc = [NSString stringWithFormat:@"%zd",type];
        if (self.typeDescriptionConfig && self.typeDescriptionConfig.count) {
            if ([self.typeDescriptionConfig.allKeys containsObject:@(type)]) {
                typeDesc = self.typeDescriptionConfig[@(type)];
            }
        }
        
        NSString *formatstring = [NSString stringWithFormat:@"%@ TYPE:%@ %@ %@\r",timestamp, typeDesc, getFileNameAndFunctionFromLocation(loc), string];
        // NSString *fileName = [NSString stringWithFormat:@"%@_%@.txt", self.currentlaunchTime,typeDesc];
        // 统一写入一个log文件
        NSString *fileName = [NSString stringWithFormat:@"%@.log", self.currentlaunchTime];
        NSString *filePath = [self.currentLogsDirectory stringByAppendingPathComponent:fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            formatstring = [NSString stringWithFormat:@"%@\n%@",[self.class appBaseInfoString],formatstring];
        }
        
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[formatstring dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
        
#ifdef DEBUG
        fprintf (stderr, "%s\n", [formatstring UTF8String]);
#endif
        
    });
}

- (void)deleteOldLogsDirectories {
    
    NSArray *fileDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.logsDirectory error:nil];
    NSArray *sortedFileDirs = [self sortedLogDirectorieNames];
    if (fileDirs.count > _maximumNumberOfLogsDirectories) {
        NSUInteger deleteStartIndex = _maximumNumberOfLogsDirectories;
        for (NSUInteger index = deleteStartIndex; index < sortedFileDirs.count ; index ++) {
            NSString *timeDirKey = sortedFileDirs[index];
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

- (NSDateFormatter *)dateFormatterWith:(NSString *)form {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = form;
    return dateFormatter;
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

#pragma mark -- getter

+ (NSString *)appBaseInfoString {
    
    static NSString *infoString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = sk_AppBaseInfos();
        NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
        infoString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [infoString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    });
    return infoString;
}

- (NSArray<NSString *> *)sortedLogDirectoriePaths {
    
    NSArray *fileDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.logsDirectory error:nil];
    NSArray *sortedFileDirs = [fileDirs sortedArrayUsingComparator:^NSComparisonResult(NSString  * _Nonnull timeDirKey1, NSString * _Nonnull timeDirKey2) {
        NSDate *date1 = [self.logDirDateFormatter dateFromString:timeDirKey1];
        NSDate *date2 = [self.logDirDateFormatter dateFromString:timeDirKey2];
        return [date2 compare:date1];  // 时间降序 排序， 时间 由近及远
    }];
    
    NSMutableArray *directoriePaths = [NSMutableArray arrayWithCapacity:sortedFileDirs.count];
    [sortedFileDirs enumerateObjectsUsingBlock:^(NSString *  _Nonnull dirName, NSUInteger idx, BOOL * _Nonnull stop) {
        [directoriePaths addObject:[self.logsDirectory stringByAppendingPathComponent:dirName]];
    }];
    
    return [directoriePaths copy];
}

+ (NSArray<NSString *> *)sortedLogDirectoriePaths {
    
    return [SKLogger sharedInstance].sortedLogDirectoriePaths;
}

- (NSArray<NSString *> *)sortedLogDirectorieNames {
    
    NSArray *fileDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.logsDirectory error:nil];
    NSArray *sortedFileDirs = [fileDirs sortedArrayUsingComparator:^NSComparisonResult(NSString  * _Nonnull timeDirKey1, NSString * _Nonnull timeDirKey2) {
        NSDate *date1 = [self.logDirDateFormatter dateFromString:timeDirKey1];
        NSDate *date2 = [self.logDirDateFormatter dateFromString:timeDirKey2];
        return [date2 compare:date1];  // 时间降序 排序， 时间 由近及远
    }];
    
    return sortedFileDirs;
}

+ (NSArray<NSString *> *)sortedLogDirectorieNames {
    
    return [SKLogger sharedInstance].sortedLogDirectorieNames;
}

- (void)dealloc {
    
    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(maximumNumberOfLogsDirectories)) context:nil];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

@end

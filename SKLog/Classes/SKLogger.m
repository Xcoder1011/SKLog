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
@property (nonatomic, assign , readwrite) BOOL enableMode;

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
    
    _enableMode = YES;
}

- (void)parseStringWithLocation:(SKLocation)loc type:(NSInteger)type string:(NSString *)string {
    
    NSString *timestamp = [self.logDateFormatter stringFromDate:[NSDate date]];
    NSString *string2 = [NSString stringWithFormat:@"%@ TYPE:%zd %@ >>>%@",timestamp, type, getFileNameAndFunctionFromLocation(loc), string];
#ifdef DEBUG
    fprintf (stderr, "%s\n", [string2 UTF8String]);
#endif
}

@end

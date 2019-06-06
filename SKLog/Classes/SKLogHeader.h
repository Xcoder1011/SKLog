//
//  SKLogHeader.h
//  Pods
//
//  Created by shangkun on 2019/5/31.
//

#ifndef SKLogHeader_h
#define SKLogHeader_h

typedef struct {
    char const *file;
    int line;
    char const *func;
} SKLocation;

static inline SKLocation SKLocationMake(char const *file, int line,char const *func) {
    SKLocation loc;
    loc.file = file;
    loc.line = line;
    loc.func = func;
    return loc;
}

#define SKLOCATION() SKLocationMake(__FILE__, __LINE__, __func__)

#define SKObjDetail(var) __getObjDetail(@encode(__typeof__(var)), (var))

static inline id __getObjDetail(const char * type, ...)
{
    va_list variable_param_list;
    va_start(variable_param_list, type);
    
    id object = nil;
    
    if (strcmp(type, @encode(id)) == 0) {
        id param = va_arg(variable_param_list, id);
        object = param;
    }
    else if (strcmp(type, @encode(CGPoint)) == 0) {
        CGPoint param = (CGPoint)va_arg(variable_param_list, CGPoint);
        object = NSStringFromCGPoint(param);
    }
    else if (strcmp(type, @encode(CGSize)) == 0) {
        CGSize param = (CGSize)va_arg(variable_param_list, CGSize);
        object = NSStringFromCGSize(param);
    }
    else if (strcmp(type, @encode(CGVector)) == 0) {
        CGVector param = (CGVector)va_arg(variable_param_list, CGVector);
        object = NSStringFromCGVector(param);
    }
    else if (strcmp(type, @encode(CGRect)) == 0) {
        CGRect param = (CGRect)va_arg(variable_param_list, CGRect);
        object = NSStringFromCGRect(param);
    }
    else if (strcmp(type, @encode(NSRange)) == 0) {
        NSRange param = (NSRange)va_arg(variable_param_list, NSRange);
        object = NSStringFromRange(param);
    }
    else if (strcmp(type, @encode(CFRange)) == 0) {
        CFRange param = (CFRange)va_arg(variable_param_list, CFRange);
        object = [NSValue value:&param withObjCType:type];
    }
    else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
        CGAffineTransform param = (CGAffineTransform)va_arg(variable_param_list, CGAffineTransform);
        object = NSStringFromCGAffineTransform(param);
    }
    else if (strcmp(type, @encode(CATransform3D)) == 0) {
        CATransform3D param = (CATransform3D)va_arg(variable_param_list, CATransform3D);
        object = [NSValue valueWithCATransform3D:param];
    }
    else if (strcmp(type, @encode(SEL)) == 0) {
        SEL param = (SEL)va_arg(variable_param_list, SEL);
        object = NSStringFromSelector(param);
    }
    else if (strcmp(type, @encode(Class)) == 0) {
        Class param = (Class)va_arg(variable_param_list, Class);
        object = NSStringFromClass(param);
    }
    else if (strcmp(type, @encode(short)) == 0) {
        short param = (short)va_arg(variable_param_list, int);
        object = @(param);
    }
    else if (strcmp(type, @encode(int)) == 0) {
        int param = (int)va_arg(variable_param_list, int);
        object = @(param);
    }
    else if (strcmp(type, @encode(long)) == 0) {
        long param = (long)va_arg(variable_param_list, long);
        object = @(param);
    }
    else if (strcmp(type, @encode(long long)) == 0) {
        long long param = (long long)va_arg(variable_param_list, long long);
        object = @(param);
    }
    else if (strcmp(type, @encode(float)) == 0) {
        float param = (float)va_arg(variable_param_list, double);
        object = @(param);
    }
    else if (strcmp(type, @encode(double)) == 0) {
        double param = (double)va_arg(variable_param_list, double);
        object = @(param);
    }
    else if (strcmp(type, @encode(BOOL)) == 0) {
        BOOL param = (BOOL)va_arg(variable_param_list, int);
        object = param ? @"YES" : @"NO";
    }
    else if (strcmp(type, @encode(bool)) == 0) {
        bool param = (bool)va_arg(variable_param_list, int);
        object = param ? @"true" : @"false";
    }
    else if (strcmp(type, @encode(char)) == 0) {
        char param = (char)va_arg(variable_param_list, int);
        object = [NSString stringWithFormat:@"%c", param];
    }
    else if (strcmp(type, @encode(unsigned short)) == 0) {
        unsigned short param = (unsigned short)va_arg(variable_param_list, unsigned int);
        object = @(param);
    }
    else if (strcmp(type, @encode(unsigned int)) == 0) {
        unsigned int param = (unsigned int)va_arg(variable_param_list, unsigned int);
        object = @(param);
    }
    else if (strcmp(type, @encode(unsigned long)) == 0) {
        unsigned long param = (unsigned long)va_arg(variable_param_list, unsigned long);
        object = @(param);
    }
    else if (strcmp(type, @encode(unsigned long long)) == 0) {
        unsigned long long param = (unsigned long long)va_arg(variable_param_list, unsigned long long);
        object = @(param);
    }
    else if (strcmp(type, @encode(unsigned char)) == 0) {
        unsigned char param = (unsigned char)va_arg(variable_param_list, unsigned int);
        object = [NSString stringWithFormat:@"%c", param];
    }
    else {
        void * param = (void *)va_arg(variable_param_list, void *);
        object = [NSString stringWithFormat:@"%p", param];
    }
    
    va_end(variable_param_list);
    
    return object;
}

#pragma mark 判断文件夹是否存在
static inline BOOL sk_isDirExistAtPath(NSString *path)
{
    BOOL isDir = NO;
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    return result && isDir;
}

#pragma mark 删除文件夹下的所有文件
static inline BOOL sk_DeleteAllFileAtPath(NSString *path)
{
    BOOL result = NO;
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSString *filePath = nil;
    for (int i = 0; i < [fileArray count]; i++)
    {
        filePath = [path stringByAppendingPathComponent:[fileArray objectAtIndex:i]];
        result = [[NSFileManager defaultManager] removeItemAtPath:filePath
                                                            error:nil];
        if (!result)
        {
            break;
        }
        filePath = nil;
    }
    return result;
}


static inline NSDictionary *sk_AppBaseInfos() {
    
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    [mdict setObject:[UIDevice currentDevice].name ?: @"Unknown" forKey:@"Phone Name"];
    [mdict setObject:infoDic[@"CFBundleShortVersionString"]?:@"Unknown" forKey:@"App Version"];
    [mdict setObject:[UIDevice currentDevice].systemName ?: @"Unknown" forKey:@"System Name"];
    [mdict setObject:[UIDevice currentDevice].systemVersion ?: @"Unknown" forKey:@"System Version"];
    [mdict setObject:infoDic[@"CFBundleIdentifier"] ?:@"Unknown" forKey:@"BundleID"];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    [mdict setObject:[NSString stringWithFormat:@"%ld * %ld",(long)(width * [UIScreen mainScreen].scale),(long)(height * [UIScreen mainScreen].scale)] forKey:@"Screen Resolution"];

    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    unsigned long long totalDisk = [[attributes objectForKey:NSFileSystemSize] unsignedLongLongValue];
    unsigned long long freeDisk = [[attributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    [mdict setObject:[NSString stringWithFormat:@"%@ / %@", [NSByteCountFormatter stringFromByteCount:freeDisk countStyle:NSByteCountFormatterCountStyleFile],[NSByteCountFormatter stringFromByteCount:totalDisk countStyle:NSByteCountFormatterCountStyleFile]] forKey:@"Disk"];

    return [mdict copy];
}
#endif /* SKLogHeader_h */

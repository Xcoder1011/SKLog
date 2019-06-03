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


#endif /* SKLogHeader_h */

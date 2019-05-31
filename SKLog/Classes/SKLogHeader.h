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

#endif /* SKLogHeader_h */

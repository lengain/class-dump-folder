//
//  LNClussDump.h
//  LNClassDump
//
//  Created by 童玉龙 on 2021/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ClassDumpPath @"/usr/local/bin/class-dump"

@interface LNClassDump : NSObject

+ (NSArray <NSString *>*)machOFilesWithPath:(NSString *)path;

+ (void)printAllMachOFileAtPath:(NSString *)path;
+ (void)printExeMachOFileWithPath:(NSString *)path;
+ (void)dumpExeMachOFileWithPath:(NSString *)path;
+ (void)dumpFilePathArray:(NSArray *)fileArray;

@end

NS_ASSUME_NONNULL_END

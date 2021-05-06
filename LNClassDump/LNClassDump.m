//
//  LNClussDump.m
//  LNClassDump
//
//  Created by 童玉龙 on 2021/4/30.
//

#import "LNClassDump.h"
#import <unistd.h>
#import <stdbool.h>
#import <stddef.h>
#import <mach-o/fat.h>
#import <mach-o/loader.h>
#import <mach-o/swap.h>
#import <mach/machine.h>
#import "LNCommad.h"
@implementation LNClassDump

+ (void)printAllMachOFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray <NSString *>*subpaths = [fileManager subpathsAtPath:path];
    [subpaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *currentFilePath = [path stringByAppendingPathComponent:obj];
        if ([self isMachOFile:currentFilePath]) {
            printf("%s\n",currentFilePath.UTF8String);
        }
    }];
}

+ (NSArray<NSString *> *)machOFilesWithPath:(NSString *)path {
    NSMutableArray *filePathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray <NSString *>*subpaths = [fileManager subpathsAtPath:path];
    [subpaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *currentFilePath = [path stringByAppendingPathComponent:obj];
        if ([self isMachOFile:currentFilePath]) {
            if ([self enableClassDumpWithPath:currentFilePath]) {
                [filePathArray addObject:currentFilePath];
            }
        }
    }];
    return filePathArray;
}

+ (void)printExeMachOFileWithPath:(NSString *)path {
    NSArray *dynamicLib = [self machOFilesWithPath:path];
    for (NSString *path in dynamicLib) {
        printf("%s\n",path.UTF8String);
    }
}

+ (void)dumpExeMachOFileWithPath:(NSString *)path {
    [self dumpFilePathArray:[self machOFilesWithPath:path]];
}

+ (void)dumpFilePathArray:(NSArray *)fileArray {
    for (NSString *currentFilePath in fileArray) {
        NSArray <NSString *>*pathComponents = [currentFilePath componentsSeparatedByString:@"path"];
        printf("Dump file: %s\n",pathComponents.lastObject.UTF8String);
        NSMutableString *classdumpCommand = [[NSMutableString alloc] initWithFormat:@"%@ -H ",ClassDumpPath];
        [classdumpCommand appendString:currentFilePath];
        NSArray *components = [currentFilePath componentsSeparatedByString:@"/"];
        [classdumpCommand appendString:@" -o "];
        [classdumpCommand appendFormat:@"%@Headers",components.lastObject];
        [LNCommad executeCommand:classdumpCommand];
    }
}


#pragma mark - Tools

+ (BOOL)isMachOFile:(NSString* )filename
{
    NSURL * url = [NSURL fileURLWithPath:filename];
    
    // can enter directories
    NSNumber * isDirectory = nil;
    [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
    if ([isDirectory boolValue] == YES)
    {
        return YES;
    }
    
    // skip symbolic links, etc.
    NSNumber * isRegularFile = nil;
    [url getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:NULL];
    if ([isRegularFile boolValue] == NO)
    {
        return NO;
    }
    
    // check for magic values at front
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:filename];
    NSData * magicData = [fileHandle readDataOfLength:8];
    [fileHandle closeFile];
    
    if ([magicData length] < sizeof(uint32_t))
    {
        return NO;
    }
    
    uint32_t magic = *(uint32_t*)[magicData bytes];
    if (magic == MH_MAGIC || magic == MH_MAGIC_64 ||
        magic == FAT_CIGAM || magic == FAT_MAGIC)
    {
        return YES;
    }
    
    if ([magicData length] < sizeof(uint64_t))
    {
        return NO;
    }
    
    if (*(uint64_t*)[magicData bytes] == *(uint64_t*)"!<arch>\n")
    {
        return YES;
    }
    
    return NO;
}


+ (BOOL)enableClassDumpWithPath:(NSString *)path {
    NSError *fileError;
    NSMutableData *fileData = [NSMutableData dataWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                           options:NSDataReadingMappedIfSafe
                                                             error:&fileError];
    if (fileError) {
        return NO;
    }
    uint32_t location = 0;
    uint32_t magic = *(uint32_t*)((uint8_t *)[fileData bytes]);
    switch (magic)
    {
        case FAT_MAGIC:
        case FAT_CIGAM:
        {
            return YES;
        } break;
            
        case MH_MAGIC:
        case MH_CIGAM:
        {
            struct mach_header mach_header;
            [fileData getBytes:&mach_header range:NSMakeRange(location, sizeof(struct mach_header))];
            if (magic == MH_CIGAM)
                swap_mach_header(&mach_header, NX_LittleEndian);
            return [self enableClassDumpWithMachHeaderType:mach_header.filetype];
        } break;
            
        case MH_MAGIC_64:
        case MH_CIGAM_64:
        {
            struct mach_header_64 mach_header_64;
            [fileData getBytes:&mach_header_64 range:NSMakeRange(location, sizeof(struct mach_header_64))];
            if (magic == MH_CIGAM_64)
                swap_mach_header_64(&mach_header_64, NX_LittleEndian);
            return [self enableClassDumpWithMachHeaderType:mach_header_64.filetype];
        } break;
            
        default:
            return NO;
    }
    return NO;
}


+ (BOOL)enableClassDumpWithMachHeaderType:(uint32_t)filetype {
    switch (filetype) {
        case MH_EXECUTE: case MH_DYLIB:
            return YES;
        default:
            return NO;
    }
}

+ (NSString *)filtTypeWithMachHeader:(struct mach_header const *)mach_header {
    NSString * machine = [self getMachine:mach_header->cputype];
    NSString *caption = [NSString stringWithFormat:@"%@ (%@)",
                    mach_header->filetype == MH_OBJECT      ? @"Object " :
                    mach_header->filetype == MH_EXECUTE     ? @"Executable " :
                    mach_header->filetype == MH_FVMLIB      ? @"Fixed VM Shared Library" :
                    mach_header->filetype == MH_CORE        ? @"Core" :
                    mach_header->filetype == MH_PRELOAD     ? @"Preloaded Executable" :
                    mach_header->filetype == MH_DYLIB       ? @"Shared Library " :
                    mach_header->filetype == MH_DYLINKER    ? @"Dynamic Link Editor" :
                    mach_header->filetype == MH_BUNDLE      ? @"Bundle" :
                    mach_header->filetype == MH_DYLIB_STUB  ? @"Shared Library Stub" :
                    mach_header->filetype == MH_DSYM        ? @"Debug Symbols" :
                    mach_header->filetype == MH_KEXT_BUNDLE ? @"Kernel Extension" : @"?????",
                    [machine isEqualToString:@"ARM"] == YES ? [self getARMCpu:mach_header->cpusubtype] : machine];
    
    return caption;
}

+ (NSString *)getMachine:(cpu_type_t)cputype
{
    switch (cputype)
    {
        default:                  return @"???";
        case CPU_TYPE_I386:       return @"X86";
        case CPU_TYPE_POWERPC:    return @"PPC";
        case CPU_TYPE_X86_64:     return @"X86_64";
        case CPU_TYPE_POWERPC64:  return @"PPC64";
        case CPU_TYPE_ARM:        return @"ARM";
        case CPU_TYPE_ARM64:      return @"ARM64";
    }
}

+ (NSString *)getARMCpu:(cpu_subtype_t)cpusubtype
{
    switch (cpusubtype)
    {
        default:                      return @"???";
        case CPU_SUBTYPE_ARM_ALL:     return @"ARM_ALL";
        case CPU_SUBTYPE_ARM_V4T:     return @"ARM_V4T";
        case CPU_SUBTYPE_ARM_V6:      return @"ARM_V6";
        case CPU_SUBTYPE_ARM_V5TEJ:   return @"ARM_V5TEJ";
        case CPU_SUBTYPE_ARM_XSCALE:  return @"ARM_XSCALE";
        case CPU_SUBTYPE_ARM_V7:      return @"ARM_V7";
        case CPU_SUBTYPE_ARM_V7F:     return @"ARM_V7F";
        case CPU_SUBTYPE_ARM_V7K:     return @"ARM_V7K";
        case CPU_SUBTYPE_ARM_V7S:     return @"ARM_V7S";
        case CPU_SUBTYPE_ARM_V8:      return @"ARM_V8";
    }
}




@end

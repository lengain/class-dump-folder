//
//  main.m
//  LNClassDump
//
//  Created by 童玉龙 on 2021/4/30.
//

#import <Foundation/Foundation.h>
#import "LNCommad.h"
#import "LNClassDump.h"
void print_usage(void);
void exe_text(void);
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc == 1) {
            print_usage();
            return 0;
        }
        
        NSString *exePath = [LNCommad executePath];
        const char *firstArg = argv[1];
        if (firstArg[0] == '-' && firstArg[1] == 'l') {
            NSString *regex = nil;
            if (argc > 2) {
                regex = [NSString stringWithUTF8String:argv[2]];
            }
            if (strcmp(firstArg, "-l") == 0) {
                [LNClassDump printAllMachOFileAtPath:exePath];
            } else if (strcmp(firstArg, "-ld") == 0) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:ClassDumpPath]) {
                    [LNClassDump dumpExeMachOFileWithPath:exePath];
                }else {
                    NSLog(@"Please install class-dump at this path：%@",ClassDumpPath);
                }
            } else if (strcmp(firstArg, "-le") == 0) {
                [LNClassDump printExeMachOFileWithPath:exePath];
            } else {
                print_usage();
            }
        } else {
            print_usage();
        }
    }
    return 0;
}

void print_usage() {
    printf("class-dump-folder 1.0.0\n");
    printf("Usage: class-dump-folder [options]\n");
    printf("where options are:\n");
    printf("\t\t-l\t\tShow all Mach-O file at current path\n");
    printf("\t\t-le\t\tShow unix exe Mach-O file(MH_EXECUTE,MH_DYLIB) at current path\n");
    printf("\t\t-ld\t\tDump unix exe Mach-O file(MH_EXECUTE,MH_DYLIB) at current path\n");
}

void exe_text() {
    
}

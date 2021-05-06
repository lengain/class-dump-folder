//
//  LNCommad.m
//  LNClassDump
//
//  Created by 童玉龙 on 2021/4/30.
//

#import "LNCommad.h"
#import <unistd.h>

@implementation LNCommad

+ (NSString *)executePath {
    char buf[240] = {0};
    getwd(buf);
    return [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
}

+ (void)executeCommand:(NSString *)cmd {
    NSString *output = [NSString string];
    FILE *pipe = popen([cmd cStringUsingEncoding:NSASCIIStringEncoding], "r+");
    if (!pipe) return;
    char buf[1024];
    while (fgets(buf, 1024, pipe) != NULL)
        output = [output stringByAppendingFormat:@"%s", buf];
    pclose(pipe);
    printf("%s\n",output.UTF8String);
}

@end

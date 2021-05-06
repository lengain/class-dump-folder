//
//  LNCommad.h
//  LNClassDump
//
//  Created by 童玉龙 on 2021/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNCommad : NSObject

+ (NSString *)executePath;

+ (void)executeCommand:(NSString *)cmd;

@end

NS_ASSUME_NONNULL_END

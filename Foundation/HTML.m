//
//  HTML.m
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import "HTML.h"

@interface HTML ()

@end

@implementation HTML

+ (NSDictionary *)HTMLForSite:(Site *)site {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"" forKey:site.URI];
    for (Page *page in site.pages) {
        [dictionary setObject:@"" forKey:page.URI];
    }
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end

//
// Site.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "Site.h"

@implementation Site

+ (Site *)siteWithDictionary:(NSDictionary *)dictionary {
    NSMutableArray *pages = [NSMutableArray new];
    for (NSDictionary *page in (NSArray *)[dictionary objectForKey:@"pages"]) {
        [pages addObject:[Page pageWithDictionary:page]];
    }
    
    Site *site = [[Site alloc] init];
    site.name = [dictionary objectForKey:@"name"];
    site.twitterName = [dictionary objectForKey:@"twitterName"];
    site.githubName = [dictionary objectForKey:@"githubName"];
    site.pages = [NSArray arrayWithArray:pages];
    return site;
}

- (NSDictionary *)dictionary {
    return [NSDictionary new];
}

@end

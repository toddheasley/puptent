//
// Site.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "Site.h"

static NSString *kNameKey = @"name";
static NSString *kURIKey = @"URI";
static NSString *kTwitterNameKey = @"twitterName";
static NSString *kGithubNameKey = @"githubName";
static NSString *kPagesKey = @"pages";

@implementation Site

+ (Site *)siteWithDictionary:(NSDictionary *)dictionary {
    Site *site = [[Site alloc] init];
    site.URI = @"index.html";
    site.pages = [NSMutableArray arrayWithCapacity:0];
    if (dictionary != nil) {
        for (NSDictionary *page in (NSArray *)[dictionary objectForKey:kPagesKey]) {
            [site.pages addObject:[Page pageWithDictionary:page]];
        }
        site.name = [dictionary objectForKey:kNameKey];
        site.twitterName = [dictionary objectForKey:kTwitterNameKey];
        site.githubName = [dictionary objectForKey:kGithubNameKey];
    }
    return site;
}

- (NSArray *)indexedPages {
    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:0];
    for (Page *page in self.pages) {
        if (page.index) {
            [pages addObject:page];
        }
    }
    return [NSArray arrayWithArray:pages];
}

- (NSDictionary *)dictionary {
    NSMutableArray *pages = [NSMutableArray new];
    for (Page *page in self.pages) {
        [pages addObject:page.dictionary];
    }
    
    return @{
        kNameKey: self.name,
        kURIKey: self.URI,
        kTwitterNameKey: self.twitterName,
        kGithubNameKey: self.githubName,
        kPagesKey: [NSArray arrayWithArray:pages]
    };
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray arrayWithCapacity:0];
    [manifest addObject:self.URI];
    for (Page *page in self.pages) {
        [manifest addObjectsFromArray:page.manifest];
    }
    return manifest;
}

@end

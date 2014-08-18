//
//  Site.m
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import "Site.h"

static NSString *kNameKey = @"name";
static NSString *kURIKey = @"URI";
static NSString *kTwitterNameKey = @"twitterName";
static NSString *kDomainKey = @"domain";
static NSString *kPagesKey = @"pages";

@implementation Site

- (NSArray *)indexedPages {
    NSMutableArray *pages = [NSMutableArray array];
    for (Page *page in self.pages) {
        if (page.index) {
            [pages addObject:page];
        }
    }
    return [NSArray arrayWithArray:pages];
}

- (NSArray *)featuredPages {
    NSMutableArray *pages = [NSMutableArray array];
    for (Page *page in self.pages) {
        if (page.feature) {
            [pages addObject:page];
        }
    }
    return [NSArray arrayWithArray:pages];
}

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"";
        self.domain = @"";
        self.URI = @"index.html";
        self.twitterName = @"";
        self.pages = @[
            [[Page alloc] init]
        ];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSMutableArray *pages = [NSMutableArray new];
        for (NSDictionary *page in (NSArray *)[dictionary objectForKey:kPagesKey]) {
            [pages addObject:[[Page alloc] initWithDictionary:page]];
        }
        
        self.name = [dictionary objectForKey:kNameKey];
        self.domain = [dictionary objectForKey:kDomainKey];
        self.URI = [dictionary objectForKey:kURIKey];
        self.twitterName = [dictionary objectForKey:kTwitterNameKey];
        self.pages = [NSArray arrayWithArray:pages];
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableArray *pages = [NSMutableArray new];
    for (Page *page in self.pages) {
        [pages addObject:page.dictionary];
    }
    
    return @{
        kNameKey: self.name,
        kDomainKey: self.domain,
        kURIKey: self.URI,
        kTwitterNameKey: self.twitterName,
        kPagesKey: [NSArray arrayWithArray:pages]
    };
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray new];
    [manifest addObject:self.URI];
    for (Page *page in self.pages) {
        [manifest addObjectsFromArray:page.manifest];
    }
    return [NSArray arrayWithArray:manifest];
}

- (NSString *)description {
    if (self.domain.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", self.domain, [super description]];
    }
    return [super description];
}

@end

//
// Page.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "Page.h"

static NSString *kIndexKey = @"index";
static NSString *kNameKey = @"name";
static NSString *kURIKey = @"URI";
static NSString *kSectionsKey = @"sections";

@implementation Page

+ (Page *)pageWithDictionary:(NSDictionary *)dictionary {
    Page *page = [[Page alloc] init];
    page.name = [dictionary objectForKey:kNameKey];
    page.URI = [dictionary objectForKey:kURIKey];
    page.sections = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *section in (NSArray *)[dictionary objectForKey:kSectionsKey]) {
        [page.sections addObject:[PageSection sectionWithDictionary:section]];
    }
    if ([[dictionary objectForKey:kIndexKey] boolValue]) {
        page.index = YES;
    }
    return page;
}

- (NSDictionary *)dictionary {
    NSMutableArray *sections = [NSMutableArray new];
    for (PageSection *section in self.sections) {
        [sections addObject:section.dictionary];
    }
    
    return @{
        @"index": self.index ? @YES : @NO,
        kNameKey: self.name,
        kURIKey: self.URI,
        kSectionsKey: [NSArray arrayWithArray:sections]
    };
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray arrayWithCapacity:0];
    [manifest addObject:self.URI];
    for (PageSection *section in self.sections) {
        [manifest addObjectsFromArray:section.manifest];
    }
    return manifest;
}

@end

@implementation PageSection

+ (PageSection *)sectionWithDictionary:(NSDictionary *)dictionary {
    PageSection *section = [[PageSection alloc] init];
    
    return section;
}

- (NSDictionary *)dictionary {
    return [NSDictionary new];
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray arrayWithCapacity:0];
    return [NSArray arrayWithArray:manifest];
}

@end

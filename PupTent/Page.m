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
static NSString *kTypeKey = @"type";
static NSString *kTextKey = @"text";
static NSString *kMediaKey = @"media";

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
        kIndexKey: self.index ? @YES : @NO,
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
    section.type = [[dictionary objectForKey:kTypeKey] intValue];
    section.text = [dictionary objectForKey:kTextKey];
    section.media = [NSMutableArray arrayWithArray:[dictionary objectForKey:kMediaKey]];
    return section;
}

- (NSDictionary *)dictionary {
    return @{
        kTypeKey: [NSNumber numberWithInt:self.type],
        kTextKey: self.text,
        kMediaKey: [NSArray arrayWithArray:self.media]
    };
}

- (NSArray *)manifest {
    return [NSArray arrayWithArray:self.media];
}

@end

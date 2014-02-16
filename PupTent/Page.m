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
    NSMutableArray *sections = [NSMutableArray new];
    for (NSDictionary *section in (NSArray *)[dictionary objectForKey:kSectionsKey]) {
        [sections addObject:[PageSection sectionWithDictionary:section]];
    }
    
    Page *page = [[Page alloc] init];
    if ([[dictionary objectForKey:kIndexKey] boolValue]) {
        page.index = YES;
    }
    page.name = [dictionary objectForKey:kNameKey];
    page.URI = [dictionary objectForKey:kURIKey];
    page.sections = sections;
    return page;
}

- (NSDictionary *)dictionary {
    NSMutableArray *sections = [NSMutableArray new];
    for (PageSection *section in self.sections) {
        [sections addObject:[section dictionary]];
    }
    
    return @{
        @"index": self.index ? @YES : @NO,
        kNameKey: self.name,
        kURIKey: self.URI,
        kSectionsKey: [NSArray arrayWithArray:sections]
    };
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

@end

//
// Page.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "Page.h"

@implementation Page

+ (Page *)pageWithDictionary:(NSDictionary *)dictionary {
    NSMutableArray *sections = [NSMutableArray new];
    for (NSDictionary *section in (NSArray *)[dictionary objectForKey:@"sections"]) {
        [sections addObject:[PageSection sectionWithDictionary:section]];
    }
    
    Page *page = [[Page alloc] init];
    if ([[dictionary objectForKey:@"index"] boolValue]) {
        page.index = YES;
    }
    page.name = [dictionary objectForKey:@"name"];
    page.URI = [dictionary objectForKey:@"URI"];
    page.sections = sections;
    return page;
}

- (NSDictionary *)dictionary {
    return [NSDictionary new];
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

//
//  Page.m
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import "Page.h"

static NSString *kIndexKey = @"index";
static NSString *kNameKey = @"name";
static NSString *kURIKey = @"URI";
static NSString *kSectionsKey = @"sections";
static NSString *kTypeKey = @"type";
static NSString *kTextKey = @"text";

@implementation Page

- (instancetype)init {
    self = [super init];
    if (self) {
        self.index = YES;
        self.name = @"";
        self.URI = @"";
        self.sections = @[
            [[PageSection alloc] init]
        ];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSMutableArray *sections = [NSMutableArray new];
        for (NSDictionary *section in (NSArray *)[dictionary objectForKey:kSectionsKey]) {
            [sections addObject:[[PageSection alloc] initWithDictionary:section]];
        }
        
        self.index = [[dictionary objectForKey:kIndexKey] boolValue];
        self.name = [dictionary objectForKey:kNameKey];
        self.URI = [dictionary objectForKey:kURIKey];
        self.sections = [NSArray arrayWithArray:sections];
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableArray *sections = [NSMutableArray new];
    for (PageSection *section in self.sections) {
        [sections addObject:section.dictionary];
    }
    
    return @{
        kIndexKey: @(self.index),
        kNameKey: self.name,
        kURIKey: self.URI,
        kSectionsKey: [NSArray arrayWithArray:sections]
    };
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray new];
    [manifest addObject:self.URI];
    for (PageSection *section in self.sections) {
        [manifest addObjectsFromArray:section.manifest];
    }
    
    return [NSArray arrayWithArray:manifest];
}

- (NSString *)description {
    if (self.URI.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", self.URI, [super description]];
    }
    return [super description];
}

@end

@implementation PageSection

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = PageSectionTypeBasic;
        self.text = @"";
        self.URI = @"";
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.type = [[dictionary objectForKey:kTypeKey] integerValue];
        self.text = [dictionary objectForKey:kTextKey];
        self.URI = [dictionary objectForKey:kURIKey];
    }
    return self;
}

- (NSDictionary *)dictionary {
    return @{
        kTypeKey: @(self.type),
        kTextKey: self.text,
        kURIKey: self.URI
    };
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray new];
    if (self.URI.length > 0) {
        
        // Add associated media file to manifest
        [manifest addObject:self.URI];
    }
    return [NSArray arrayWithArray:manifest];
}

- (NSString *)description {
    NSString *description;
    switch (self.type) {
        case PageSectionTypeBasic:
            description = @"PageSectionTypeBasic";
            break;
        case PageSectionTypeImage:
            description = @"PageSectionTypeImage";
            break;
        case PageSectionTypeAudio:
            description = @"PageSectionTypeAudio";
            break;
        case PageSectionTypeVideo:
            description = @"PageSectionTypeVideo";
            break;
    }
    return [NSString stringWithFormat:@"%@ %@", description, [super description]];
}

@end

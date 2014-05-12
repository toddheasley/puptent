//
// Site.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "Site.h"
#import "HTML.h"

static NSString *kManifestURI = @"index.json";
static NSString *kStylesheetURI = @"default.css";
static NSString *kMediaPath = @"media"; // Suggested media directory
static NSString *kTouchIcon = @"apple-touch-icon.png";
static NSString *kTouchIconData = @"iVBORw0KGgoAAAANSUhEUgAAAJgAAACYCAYAAAAYwiAhAAAAcElEQVR42u3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BhppwABkzBLogAAAABJRU5ErkJggg==";
static NSString *kGitURIs = @"README, README.md, CNAME";

static NSString *kIndexKey = @"index";
static NSString *kFeatureKey = @"feature";
static NSString *kNameKey = @"name";
static NSString *kDomainKey = @"domain";
static NSString *kTwitterNameKey = @"twitterName";
static NSString *kURIKey = @"URI";
static NSString *kPagesKey = @"pages";
static NSString *kSectionsKey = @"sections";
static NSString *kTypeKey = @"type";
static NSString *kTextKey = @"text";

@implementation Site

+ (BOOL)siteExistsAtPath:(NSString *)path {
    path = [NSString stringWithFormat:@"%@%@", path, kManifestURI];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        return YES;
    }
    return NO;
}

+ (Site *)siteAtPath:(NSString *)path error:(NSError **)error {
    path = [[path componentsSeparatedByString:kManifestURI] objectAtIndex:0];
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@", path, kManifestURI] options:0 error:error];
    if (data == nil) {
        
        // Site manifest not found or can't be read
        return nil;
    }
    NSDictionary *dictionary = dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (dictionary == nil) {
        
        // Site manifest contains errors
        return nil;
    }
    Site *site = [Site siteWithDictionary:dictionary];
    site.path = path;
    return site;
}

+ (void)pitchSite:(Site *)site atPath:(NSString *)path {
    
    // Write skeleton files (manifest, stylesheet, touch icon and media directory) to path
    [[NSJSONSerialization dataWithJSONObject:site.dictionary options:0 error:nil] writeToFile:[NSString stringWithFormat:@"%@%@", path, kManifestURI] atomically:YES];
    [[NSData data] writeToFile:[NSString stringWithFormat:@"%@%@", path, kStylesheetURI] atomically:YES];
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@", path, kMediaPath] withIntermediateDirectories:NO attributes:nil error:nil];
    [[[NSData alloc] initWithBase64EncodedString:kTouchIconData options:0] writeToFile:[NSString stringWithFormat:@"%@%@", path, kTouchIcon] atomically:YES];
}

- (void)build {
    NSDictionary *dictionary = [HTML HTMLForSite:self];
    for (NSString *URI in dictionary) {
        [[((NSString *)[dictionary objectForKey:URI]) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[NSString stringWithFormat:@"%@%@", self.path, URI] atomically:YES];
    }
}

- (void)clean {
    NSArray *manifest = @[
        [[[NSBundle mainBundle] executablePath] lastPathComponent],
        kManifestURI,
        kStylesheetURI,
        kMediaPath,
        kTouchIcon
    ];
    manifest = [manifest arrayByAddingObjectsFromArray:[kGitURIs componentsSeparatedByString:@", "]];
    manifest = [manifest arrayByAddingObjectsFromArray:self.manifest];
    for (NSString *URI in [[NSFileManager defaultManager] enumeratorAtPath:self.path]) {
        if ([manifest containsObject:URI] || [[URI substringToIndex:1] isEqualToString:@"."]) {
            continue;
        }
        
        // File not found in current site manifest; move file to trash
        [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:[self.path stringByAppendingPathComponent:URI]] resultingItemURL:nil error:nil];
    }
}

- (void)setDomain:(NSURL *)domain {
    _domain = [NSURL URLWithString:[domain.absoluteString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/ "]]];
}

- (NSString *)manifestURI {
    return kManifestURI;
}

- (NSString *)stylesheetURI {
    return kStylesheetURI;
}

- (NSString *)touchIcon {
    return kTouchIcon;
}

- (NSString *)mediaPath {
    return kMediaPath;
}

+ (Site *)siteWithDictionary:(NSDictionary *)dictionary {
    Site *site = [[Site alloc] init];
    site.name = [dictionary objectForKey:kNameKey];
    site.domain = [NSURL URLWithString:[dictionary objectForKey:kDomainKey]];
    site.URI = [dictionary objectForKey:kURIKey];
    site.twitterName = [dictionary objectForKey:kTwitterNameKey];
    site.pages = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *page in (NSArray *)[dictionary objectForKey:kPagesKey]) {
        [site.pages addObject:[Page pageWithDictionary:page]];
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

- (NSArray *)featuredPages {
    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:0];
    for (Page *page in self.pages) {
        if (page.feature) {
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
        kDomainKey: self.domain.absoluteString,
        kURIKey: self.URI,
        kTwitterNameKey: self.twitterName,
        kPagesKey: [NSArray arrayWithArray:pages]
    };
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray arrayWithCapacity:0];
    [manifest addObject:self.URI];
    for (Page *page in self.pages) {
        [manifest addObjectsFromArray:page.manifest];
    }
    return [NSArray arrayWithArray:manifest];
}

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"";
        self.domain = [NSURL URLWithString:@""];
        self.URI = @"";
        self.twitterName = @"";
        self.pages = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

@end

@implementation Page

+ (Page *)pageWithDictionary:(NSDictionary *)dictionary {
    Page *page = [[Page alloc] init];
    page.name = [dictionary objectForKey:kNameKey];
    page.URI = [dictionary objectForKey:kURIKey];
    page.sections = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *section in (NSArray *)[dictionary objectForKey:kSectionsKey]) {
        [page.sections addObject:[PageSection sectionWithDictionary:section]];
    }
    page.index = [[dictionary objectForKey:kIndexKey] boolValue];
    page.feature = [[dictionary objectForKey:kFeatureKey] boolValue];
    return page;
}

- (NSDictionary *)dictionary {
    NSMutableArray *sections = [NSMutableArray new];
    for (PageSection *section in self.sections) {
        [sections addObject:section.dictionary];
    }
    return @{
        kIndexKey: @(self.index),
        kFeatureKey: @(self.feature),
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
    return [NSArray arrayWithArray:manifest];
}

- (id)init {
    self = [super init];
    if (self) {
        self.index = YES;
        self.feature = NO;
        self.name = @"";
        self.URI = @"";
        self.sections = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

@end

@implementation PageSection

+ (PageSection *)sectionWithDictionary:(NSDictionary *)dictionary {
    PageSection *section = [[PageSection alloc] init];
    section.type = [[dictionary objectForKey:kTypeKey] integerValue];
    section.text = [dictionary objectForKey:kTextKey];
    section.URI = [dictionary objectForKey:kURIKey];
    return section;
}

- (NSDictionary *)dictionary {
    return @{
        kTypeKey: @(self.type),
        kTextKey: self.text,
        kURIKey: self.URI
    };
}

- (NSArray *)manifest {
    NSMutableArray *manifest = [NSMutableArray arrayWithCapacity:0];
    if (self.URI.length > 0) {
        [manifest addObject:self.URI];
    }
    return [NSArray arrayWithArray:manifest];
}

- (id)init {
    self = [super init];
    if (self) {
        self.type = PageSectionTypeBasic;
        self.text = @"";
        self.URI = @"";
    }
    return self;
}


@end
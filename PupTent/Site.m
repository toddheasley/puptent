//
// Site.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "Site.h"
#import "HTML.h"

static NSString *kIndexFileName = @"index.json";
static NSString *kNameKey = @"name";
static NSString *kTwitterNameKey = @"twitterName";
static NSString *kGithubNameKey = @"githubName";
static NSString *kPagesKey = @"pages";

@interface Site ()

@property (nonatomic, strong) NSString *path;

@end

@implementation Site

+ (Site *)siteAtPath:(NSString *)path {
    return [[Site alloc] initWithPath:path];
}

- (id)initWithPath:(NSString *)path {
    NSArray *pathComponents = [path componentsSeparatedByString:kIndexFileName];
    path = [pathComponents objectAtIndex:0];
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@", path, kIndexFileName] options:0 error:&error];
    if (error != nil && error.code != NSFileReadNoSuchFileError) {
        
        // Existing site can't be read
        return nil;
    }
    
    self = [super init];
    if (self) {
        NSMutableArray *pages = [NSMutableArray new];
        
        // Attempt to read existing site at path
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (dictionary != nil) {
                for (NSDictionary *page in (NSArray *)[dictionary objectForKey:kPagesKey]) {
                    [pages addObject:[Page pageWithDictionary:page]];
                }
                self.name = [dictionary objectForKey:kNameKey];
                self.twitterName = [dictionary objectForKey:kTwitterNameKey];
                self.githubName = [dictionary objectForKey:kGithubNameKey];
            }
        }
        self.pages = [NSArray arrayWithArray:pages];
        self.path = path;
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableArray *pages = [NSMutableArray new];
    for (Page *page in self.pages) {
        [pages addObject:[page dictionary]];
    }
    
    return @{
        kNameKey: self.name,
        kTwitterNameKey: self.twitterName,
        kGithubNameKey: self.githubName,
        kPagesKey: [NSArray arrayWithArray:pages]
    };
}

- (void)save {
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self dictionary] options:0 error:nil];
    [data writeToFile:[NSString stringWithFormat:@"%@%@", self.path, kIndexFileName] atomically:YES];
    [HTML generateHTMLForSite:self];
}

@end

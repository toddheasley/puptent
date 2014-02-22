//
// SiteManager.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "SiteManager.h"
#import "HTML.h"

static NSString *kIndexURI = @"index.json";

@interface SiteManager ()

@property (nonatomic, strong) NSString *path;

@end

@implementation SiteManager

+ (SiteManager *)siteAtPath:(NSString *)path {
    path = [[path componentsSeparatedByString:kIndexURI] objectAtIndex:0];
    if (path == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@", path, kIndexURI] options:0 error:&error];
    if (error != nil && error.code != NSFileReadNoSuchFileError) {
        
        // Existing site can't be read
        return nil;
    }
    
    NSDictionary *dictionary = nil;
    if (data != nil) {
        dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    
    SiteManager *siteManager = [[SiteManager alloc] init];
    siteManager.path = path;
    siteManager.site = [Site siteWithDictionary:dictionary];
    return siteManager;
}

- (void)saveSite {
    NSMutableArray *manifest = [NSMutableArray arrayWithArray:self.site.manifest];
    
    // Generate JSON index
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self.site dictionary] options:0 error:nil];
    [data writeToFile:[NSString stringWithFormat:@"%@%@", self.path, kIndexURI] atomically:YES];
    [manifest addObject:kIndexURI];
    
    
    // Generate HTML
    NSDictionary *dataDictionary = [HTML dataForSite:self.site];
    for (NSString *URI in dataDictionary) {
        [(NSData *)[dataDictionary objectForKey:URI] writeToFile:[NSString stringWithFormat:@"%@%@", self.path, URI] atomically:YES];
    }
    
    NSLog(@"%@", [HTML pathForMediaWithType:@"png"]);
    
    // Clean up
    /*
    NSError *error;
    NSString *URI;
    BOOL success;
    while (URI = [[[NSFileManager defaultManager] enumeratorAtPath:self.path] nextObject]) {
        if ([manifest containsObject:URI]) {
            continue;
        }
        success = [[NSFileManager defaultManager] removeItemAtPath:[self.path stringByAppendingPathComponent:URI] error:&error];
        if (! success && error) {
            NSLog(@"%@", error);
        }
    }
    */
}

@end

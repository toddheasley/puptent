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

- (NSString *)pathForMediaType:(NSString *)type withData:(NSData *)data {
    NSString *path = [NSString stringWithFormat:@"%@%@", self.path, [HTML mediaPath]];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        // Create media directory
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    // Generate path and save media
    path = [HTML pathForMediaType:type];
    if ([data writeToFile:[NSString stringWithFormat:@"%@%@", self.path, path] atomically:YES]) {
        
        // Return new path
        return path;
    }
    return nil;
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
    [manifest addObjectsFromArray:[HTML resources]];
    [manifest addObject:[HTML mediaPath]];
    
    // Clean up unlinked files
    NSError *error;
    BOOL success;
    for (NSString *URI in [[NSFileManager defaultManager] enumeratorAtPath:self.path]) {
        if ([manifest containsObject:URI]) {
            continue;
        }
        success = [[NSFileManager defaultManager] removeItemAtPath:[self.path stringByAppendingPathComponent:URI] error:&error];
        if (! success && error) {
            
        }
    }
}

@end

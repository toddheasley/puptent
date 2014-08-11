//
//  Manager.m
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import "Manager.h"
#import "HTML.h"

static NSString *kManifestURI = @"index.json";
static NSString *kBookmarkIconURI = @"apple-touch-icon.png";
static NSString *kBookmarkIconData = @"iVBORw0KGgoAAAANSUhEUgAAAJgAAACYCAYAAAAYwiAhAAAAcElEQVR42u3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BhppwABkzBLogAAAABJRU5ErkJggg==";
static NSString *kStylesheetURI = @"default.css";
static NSString *kMediaPath = @"media"; // Suggested media directory
static NSString *kGitURIs = @"README, README.md, CNAME";

@interface Manager ()

@property (strong, readwrite) NSString *path;

@end

@implementation Manager

+ (BOOL)siteExistsAtPath:(NSString *)path {
    path = [NSString stringWithFormat:@"%@%@", path, kManifestURI];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        return YES;
    }
    return NO;
}

+ (instancetype)managerForSiteAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
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
    
    Manager *manager = [[Manager alloc] init];
    manager.path = path;
    manager.site = [[Site alloc] initWithDictionary:dictionary];
    return manager;
}

+ (NSError *)pitchSiteAtPath:(NSString *)path {
    NSError *error;
    Site *site = [[Site alloc] init];
    
    // Write JSON manifest
    [[NSJSONSerialization dataWithJSONObject:site.dictionary options:0 error:&error] writeToFile:[NSString stringWithFormat:@"%@%@", path, kManifestURI] atomically:YES];
    
    // Write empty root HTML file
    [[NSData data] writeToFile:[NSString stringWithFormat:@"%@%@", path, site.URI] atomically:YES];
    
    // Write empty CSS file
    [[NSData data] writeToFile:[NSString stringWithFormat:@"%@%@", path, kStylesheetURI] atomically:YES];
    
    // Create empty media directory
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@", path, kMediaPath] withIntermediateDirectories:NO attributes:nil error:&error];
    
    // Write blank bookmark icon PNG
    [[[NSData alloc] initWithBase64EncodedString:kBookmarkIconData options:0] writeToFile:[NSString stringWithFormat:@"%@%@", path, kBookmarkIconURI] atomically:YES];
    
    return error;
}

- (NSError *)build {
    NSDictionary *dictionary = [HTML HTMLForSite:self.site];
    for (NSString *URI in dictionary) {
        [[((NSString *)[dictionary objectForKey:URI]) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[NSString stringWithFormat:@"%@%@", self.path, URI] atomically:YES];
    }
    return nil;
}

- (NSError *)clean {
    
    // Build manifest of files to keep
    NSArray *manifest = @[
        [[[NSBundle mainBundle] executablePath] lastPathComponent],
        kManifestURI,
        kStylesheetURI,
        kMediaPath,
        kBookmarkIconURI
    ];
    manifest = [manifest arrayByAddingObjectsFromArray:[kGitURIs componentsSeparatedByString:@", "]];
    manifest = [manifest arrayByAddingObjectsFromArray:self.site.manifest];
    
    NSError *error;
    for (NSString *URI in [[NSFileManager defaultManager] enumeratorAtPath:self.path]) {
        if ([manifest containsObject:URI] || [[URI substringToIndex:1] isEqualToString:@"."]) {
            continue;
        }
        
        // File not found in current site manifest; move file to trash
        [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:[self.path stringByAppendingPathComponent:URI]] resultingItemURL:nil error:&error];
    }
    return error;
}

- (NSString *)manifestURI {
    return kManifestURI;
}

- (NSString *)stylesheetURI {
    return kStylesheetURI;
}

- (NSString *)bookmarkIconURI {
    return kBookmarkIconURI;
}

- (NSString *)mediaPath {
    return kMediaPath;
}

@end

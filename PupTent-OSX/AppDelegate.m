//
// AppDelegate.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "AppDelegate.h"
#import "SiteManager.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    SiteManager *siteManager = [SiteManager siteAtPath:@"/Users/toddheasley/Desktop/Test/"];
    
    NSLog(@"%@", siteManager.path);
    NSLog(@"%@", siteManager.site.dictionary);
    NSLog(@"%@", siteManager.site.manifest);
    
    [siteManager saveSite];
}

/*
 NSData *mediaData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@bigcartel-app.jpg", self.path]];
 NSString *mediaPath = [self pathForMediaType:@"jpg" withData:mediaData];
 PageSection *section = [((Page *)[self.site.pages objectAtIndex:0]).sections objectAtIndex:0];
 [section.media replaceObjectAtIndex:0 withObject:mediaPath];
 */

@end

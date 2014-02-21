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
    NSLog(@"%@", [siteManager.site dictionary]);
}

@end

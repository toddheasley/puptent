//
// AppDelegate.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "AppDelegate.h"
#import "Site.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/toddheasley/Desktop/index.json" options:0 error:&error];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    Site *site = [Site siteWithDictionary:dictionary];
    
    for (int i = 0; i < site.pages.count; i++) {
        NSLog(@"%@", ((Page *)[site.pages objectAtIndex:i]).name);
    }
    NSLog(@"%@", site.pages);
}

@end

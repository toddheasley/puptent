//
//  main.m
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Manager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *name = [[[NSBundle mainBundle] executablePath] lastPathComponent];
        NSString *path = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] bundlePath]];
        NSArray *options = @[
            @"pitch",
            @"build",
            @"clean"
        ];
        
        if (argv[1] == NULL) {
            NSLog(@"%@ options: %@", name, [options componentsJoinedByString:@", "]);
            return 0;
        }
        
        NSInteger option = [options indexOfObject:[NSString stringWithUTF8String:argv[1]]];
        if (option == NSNotFound) {
            NSLog(@"%@ options: %@", name, [options componentsJoinedByString:@", "]);
            return 0;
        }
        
        if (option == 0) {
            if ([Manager siteExistsAtPath:path]) {
                NSLog(@"%@ %@ failed: site already exists at path %@", name, [options objectAtIndex:option], path);
                return 1;
            }
            
            NSError *error = [Manager pitchSiteAtPath:path];
            if (error != nil) {
                NSLog(@"%@ %@ failed: error %ld pitching site at path %@", name, [options objectAtIndex:option], (long)error.code, path);
                return 1;
            }
            
            NSLog(@"%@ %@ completed", name, [options objectAtIndex:option]);
            return 0;
        }
        
        NSError *error;
        Manager *manager = [Manager managerForSiteAtPath:path error:&error];
        if (error != nil) {
            if (error.code == 260) {
                NSLog(@"%@ %@ failed: site not found at path %@", name, [options objectAtIndex:option], path);
                return 1;
            }
            NSLog(@"%@ %@ failed: site manifest at path %@ contains errors", name, [options objectAtIndex:option], path);
            return 1;
        }
        if (option == 1) {
            [manager build];
            
            NSLog(@"%@ %@ completed", name, [options objectAtIndex:option]);
            return 0;
        }
        if (option == 2) {
            [manager clean];
            
            NSLog(@"%@ %@ completed", name, [options objectAtIndex:option]);
            return 0;
        }
    }
    return 1;
}

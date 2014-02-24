//
// AppDelegate.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "AppDelegate.h"
#import "SiteManager.h"

@interface AppDelegate ()

- (IBAction)presentOpenPanel:(id)sender;

@end

@implementation AppDelegate

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    return YES;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self presentOpenPanel:self];
}

- (IBAction)presentOpenPanel:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.delegate = self;
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = YES;
    openPanel.allowedFileTypes = @[@"pup"];
    openPanel.allowsMultipleSelection = NO;
    openPanel.canCreateDirectories = YES;
    if ([openPanel runModal] == NSOKButton) {
        SiteManager *siteManager = [SiteManager siteAtPath:openPanel.URL.path];
        [siteManager saveSite];
        [self.window makeKeyAndOrderFront:self.window];
    }
}

#pragma mark NSOpenSavePanelDelegate

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    return YES;
}

@end

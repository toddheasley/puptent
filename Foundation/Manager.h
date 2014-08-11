//
//  Manager.h
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Site.h"

@interface Manager : NSObject

@property (strong) Site *site;
@property (strong, readonly) NSString *path;
@property (strong, readonly) NSString *manifestURI;
@property (strong, readonly) NSString *bookmarkIconURI;
@property (strong, readonly) NSString *stylesheetURI;
@property (strong, readonly) NSString *mediaPath;

+ (BOOL)siteExistsAtPath:(NSString *)path;
+ (instancetype)managerForSiteAtPath:(NSString *)path error:(NSError **)error;
+ (NSError *)pitchSiteAtPath:(NSString *)path;
- (NSError *)build;
- (NSError *)clean;

@end

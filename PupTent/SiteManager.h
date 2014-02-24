//
// SiteManager.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Site.h"

@interface SiteManager : NSObject

@property (nonatomic, strong, readonly) NSString *path;
@property (nonatomic, strong) Site *site;

+ (NSString *)type;
+ (SiteManager *)siteAtPath:(NSString *)path;
- (NSString *)pathForMediaType:(NSString *)type withData:(NSData *)data;
- (void)saveSite;

@end

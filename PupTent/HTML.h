//
// HTML.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Site.h"

@interface HTML : NSObject

+ (NSDictionary *)dataForSite:(Site *)site;
+ (NSString *)pathForMediaType:(NSString *)type;
+ (NSArray *)resources;
+ (NSString *)mediaPath;

@end

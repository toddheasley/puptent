//
// HTML.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Site.h"

@interface HTML : NSObject

+ (void)generateHTMLForSite:(Site *)site;
+ (void)removeHTMLForPage:(Page *)page;

@end

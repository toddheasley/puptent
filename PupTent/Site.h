//
// Site.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Page.h"

@interface Site : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *twitterName;
@property (nonatomic, strong) NSString *githubName;
@property (nonatomic, strong) NSArray *pages;

+ (Site *)siteWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end

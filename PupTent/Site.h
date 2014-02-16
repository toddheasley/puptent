//
// Site.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Page.h"

@class Site;

@protocol SiteDelegate <NSObject>

@optional

@end

@interface Site : NSObject

@property (nonatomic, weak) id<SiteDelegate> delegate;
@property (nonatomic, strong, readonly) NSString *path;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *twitterName;
@property (nonatomic, strong) NSString *githubName;
@property (nonatomic, strong) NSArray *pages;

+ (Site *)siteAtPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;
- (NSDictionary *)dictionary;
- (void)save;

@end

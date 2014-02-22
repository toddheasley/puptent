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
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *URI;
@property (nonatomic, strong) NSString *twitterName;
@property (nonatomic, strong) NSString *githubName;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong, readonly) NSArray *indexedPages;
@property (nonatomic, strong, readonly) NSDictionary *dictionary;
@property (nonatomic, strong, readonly) NSArray *manifest;

+ (Site *)siteWithDictionary:(NSDictionary *)dictionary;

@end

//
// Site.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PageSectionType) {
    PageSectionTypeBasic,
    PageSectionTypeImage,
    PageSectionTypeAudio,
    PageSectionTypeVideo
};

@interface Site : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong, readonly) NSString *manifestURI;
@property (nonatomic, strong, readonly) NSString *stylesheetURI;
@property (nonatomic, strong, readonly) NSString *touchIcon;
@property (nonatomic, strong, readonly) NSString *mediaPath;

+ (BOOL)siteExistsAtPath:(NSString *)path;
+ (Site *)siteAtPath:(NSString *)path error:(NSError **)error;
+ (void)pitchSite:(Site *)site atPath:(NSString *)path;
- (void)build;
- (void)clean;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *URI;
@property (nonatomic, strong) NSString *twitterName;
@property (nonatomic, strong) NSURL *domain;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong, readonly) NSArray *indexedPages;
@property (nonatomic, strong, readonly) NSArray *featuredPages;
@property (nonatomic, strong, readonly) NSDictionary *dictionary;
@property (nonatomic, strong, readonly) NSArray *manifest;

+ (Site *)siteWithDictionary:(NSDictionary *)dictionary;

@end

@interface Page : NSObject

@property (nonatomic, assign) BOOL index;
@property (nonatomic, assign) BOOL feature;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *URI;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong, readonly) NSDictionary *dictionary;
@property (nonatomic, strong, readonly) NSArray *manifest;

+ (Page *)pageWithDictionary:(NSDictionary *)dictionary;

@end

@interface PageSection : NSObject

@property (nonatomic, assign) PageSectionType type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *URI;
@property (nonatomic, strong, readonly) NSDictionary *dictionary;
@property (nonatomic, strong, readonly) NSArray *manifest;

+ (PageSection *)sectionWithDictionary:(NSDictionary *)dictionary;

@end

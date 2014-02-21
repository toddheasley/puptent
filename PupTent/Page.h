//
// Page.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>

typedef enum {
    PageSectionTypeText,
    PageSectionTypeImage,
    PageSectionTypeAudio,
    PageSectionTypeVideo
} PageSectionType;

@interface Page : NSObject

@property (nonatomic, assign) BOOL index;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *URI;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong, readonly) NSDictionary *dictionary;
@property (nonatomic, strong, readonly) NSArray *manifest;

+ (Page *)pageWithDictionary:(NSDictionary *)dictionary;

@end

@interface PageSection : NSObject

@property (nonatomic, assign) PageSectionType type;
@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, strong, readonly) NSDictionary *dictionary;
@property (nonatomic, strong, readonly) NSArray *manifest;

+ (PageSection *)sectionWithDictionary:(NSDictionary *)dictionary;

@end

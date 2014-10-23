//
//  Page.h
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Archiving.h"

typedef NS_ENUM(NSInteger, PageSectionType) {
    PageSectionTypeBasic,
    PageSectionTypeImage,
    PageSectionTypeAudio,
    PageSectionTypeVideo
};

@interface Page : NSObject <Archiving>

@property (assign) BOOL index;
@property (strong) NSString *name;
@property (strong) NSString *URI;
@property (strong) NSArray *sections;

@end

@interface PageSection : NSObject <Archiving>

@property (assign) PageSectionType type;
@property (strong) NSString *text;
@property (strong) NSString *URI;

@end

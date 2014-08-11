//
//  Site.h
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Archiving.h"
#import "Page.h"

@interface Site : NSObject <Archiving>

@property (strong) NSString *name;
@property (strong) NSString *URI;
@property (strong) NSString *twitterName;
@property (strong) NSString *domain;
@property (strong) NSArray *pages;
@property (strong, readonly) NSArray *indexedPages;
@property (strong, readonly) NSArray *featuredPages;

@end

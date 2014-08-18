//
//  HTML.h
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import "Site.h"

@protocol HTMLDelegate <NSObject>

- (NSError *)HTML:(NSString *)HTML forURI:(NSString *)URI;

@end

@interface HTML : NSObject

@property (nonatomic, weak) id <HTMLDelegate>delegate;
@property (nonatomic, strong) NSString *bookmarkIconURI;
@property (nonatomic, strong) NSString *stylesheetURI;
@property (nonatomic, strong) Site *site;

- (NSError *)generateHTML;

@end

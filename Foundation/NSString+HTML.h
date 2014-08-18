//
//  NSString+HTML.h
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

+ (NSString *)HTMLStringFromString:(NSString *)string detectLinks:(BOOL)detectLinks;

@end

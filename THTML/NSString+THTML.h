//
// NSString+THTML.h
// THTML
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>

@interface NSString (THTML)

+ (NSString *)HTMLStringFromString:(NSString *)string detectLinks:(BOOL)detectLinks;

@end

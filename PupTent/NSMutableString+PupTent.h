//
// NSMutableString+PupTent.h
// PupTent
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>

@interface NSMutableString (PupTent)

- (void)replaceOccurrencesOfTag:(NSString *)tag withString:(NSString *)string;
- (void)replaceSubstringFromTag:(NSString *)startTag toTag:(NSString *)endTag withString:(NSString *)string;
- (NSMutableString *)substringFromTag:(NSString *)startTag toTag:(NSString *)endTag;
- (void)collapseEmptyLines;

@end

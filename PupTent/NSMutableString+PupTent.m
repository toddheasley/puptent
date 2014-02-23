//
// NSMutableString+PupTent.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "NSMutableString+PupTent.h"

@implementation NSMutableString (PupTent)

- (void)replaceOccurrencesOfTag:(NSString *)tag withString:(NSString *)string {
    [self replaceOccurrencesOfString:tag withString:string options:0 range:NSMakeRange(0, self.length)];
}

- (void)replaceSubstringFromTag:(NSString *)startTag toTag:(NSString *)endTag withString:(NSString *)string {
    NSString *substring = [NSString stringWithFormat:@"%@%@%@", startTag, [self substringFromTag:startTag toTag:endTag], endTag];
    [self replaceOccurrencesOfString:substring withString:string options:0 range:NSMakeRange(0, self.length)];
}

- (NSMutableString *)substringFromTag:(NSString *)startTag toTag:(NSString *)endTag {
    NSString *string = @"";
    NSRange start = [self rangeOfString:startTag];
    NSRange end = [self rangeOfString:endTag];
    if (start.location != NSNotFound && end.location != NSNotFound) {
        string = [self substringWithRange:NSMakeRange(start.location + start.length, end.location - (start.location + start.length))];
    }
    return [NSMutableString stringWithString:string];
}

- (void)collapseEmptyLines {
    while ([self rangeOfString:@"\n\n"].location != NSNotFound) {
        [self replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:0 range:NSMakeRange(0, self.length)];
    }
}

@end

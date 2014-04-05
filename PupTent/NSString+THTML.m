//
// NSString+THTML.m
// THTML
//
// (c) 2014 @toddheasley
//

#import "NSString+THTML.h"

@implementation NSString (THTML)

+ (NSString *)HTMLStringFromString:(NSString *)string detectLinks:(BOOL)detectLinks {
    NSError *error;
    
    if (detectLinks) {
        
        // Hyperlink absolute URLs
        NSRegularExpression *URLPattern = [NSRegularExpression regularExpressionWithPattern:@"(https?:\\/\\/)([\\w\\-\\.!~?&+\\*'\"(),\\/]+)" options:NSRegularExpressionCaseInsensitive error:&error];
        string = [URLPattern stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"<a href=\"$1$2\">$2</a>"];
        
        // Hyperlinke relative URIs
        NSRegularExpression *URIPattern = [NSRegularExpression regularExpressionWithPattern:@"(\\\n|\\s)/([\\w\\-\\.!~#?&=+\\*'\"(),\\/]+)" options:NSRegularExpressionCaseInsensitive error:&error];
        string = [URIPattern stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"$1<a href=\"/$2\">$2</a>"];
        
        // Hyperlink email addresses
        NSRegularExpression *emailPattern = [NSRegularExpression regularExpressionWithPattern:@"(^|\\s)([A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4})" options:NSRegularExpressionCaseInsensitive error:&error];
        string = [emailPattern stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"$1<a href=\"mailto:$2\">$2</a>"];
        
        // Hyperlink Twitter names
        NSRegularExpression *namePattern = [NSRegularExpression regularExpressionWithPattern:@"(^|\\s)@([a-z0-9_]+)" options:NSRegularExpressionCaseInsensitive error:&error];
        string = [namePattern stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"$1<a href=\"https://twitter.com/$2\">@$2</a>"];
        
        // Hyperlink Twitter hashtags
        NSRegularExpression *hashtagPattern = [NSRegularExpression regularExpressionWithPattern:@"(^|\\s)#([a-z0-9_]+)" options:NSRegularExpressionCaseInsensitive error:&error];
        string = [hashtagPattern stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"$1<a href=\"https://twitter.com/search?q=%23$2&src=hash\">#$2</a>"];
    }
    
    // Convert line breaks
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    
    if (error != nil) {
        NSLog(@"%@", error);
    }
    return string;
}

@end

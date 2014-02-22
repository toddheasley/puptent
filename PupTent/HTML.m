//
// HTML.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "HTML.h"

static NSString *kHTMLMediaPath = @"media";
static NSString *kHTMLResources = @"apple-touch-icon.png,favicon.ico,screen.css,jquery.js,swipe.js";
static NSString *kHTMLGenerator = @"Pup Tent 1.0";

@interface HTML ()

+ (NSArray *)resources;
+ (NSString *)pathForResource:(NSString *)resource;
+ (NSData *)dataForResource:(NSString *)resource;
+ (NSData *)dataForIndex:(Site *)site;
+ (NSData *)dataForPage:(Page *)page inSite:(Site *)site;

@end

@implementation HTML

+ (NSDictionary *)dataForSite:(Site *)site {
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *resource in [HTML resources]) {
        [data setObject:[HTML dataForResource:resource] forKey:resource];
    }
    [data setObject:[HTML dataForIndex:site] forKey:site.URI];
    for (Page *page in site.pages) {
        [data setObject:[HTML dataForPage:page inSite:site] forKey:page.URI];
    }
    return data;
}

+ (NSString *)pathForMediaWithType:(NSString *)type {
    NSString *characters = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *path = [NSMutableString stringWithString:@""];
    for (uint i = 0; i < 4; i++) {
        [path appendFormat: @"%c", [characters characterAtIndex:(arc4random() % characters.length)]];
    }
    [path appendString:[NSString stringWithFormat:@"%lu", (long)[[NSDate date] timeIntervalSince1970]]];
    return [NSString stringWithFormat:@"%@/%@.%@", kHTMLMediaPath, path, type];
}

+ (NSArray *)resources {
    return [kHTMLResources componentsSeparatedByString:@","];
}

+ (NSString *)pathForResource:(NSString *)resource {
    NSArray *resourceComponents = [resource componentsSeparatedByString:@"."];
    return [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"HTML.bundle/%@", [resourceComponents objectAtIndex:0]] ofType:[resourceComponents objectAtIndex:1]];
}

+ (NSData *)dataForResource:(NSString *)resource {
    return [NSData dataWithContentsOfFile:[HTML pathForResource:resource]];
}

+ (NSData *)dataForIndex:(Site *)site {
    NSString *template = [NSString stringWithContentsOfFile:[HTML pathForResource:@"index.html"] encoding:NSUTF8StringEncoding error:nil];
    NSArray *templateComponents = [template componentsSeparatedByString:@"<!-- ---- -->"];
    
    // Construct HTML string from template components
    NSMutableString *HTMLString = [NSMutableString stringWithString:[templateComponents objectAtIndex:0]];
    [HTMLString replaceOccurrencesOfString:@"<!-- GENERATOR -->" withString:kHTMLGenerator options:0 range:NSMakeRange(0, HTMLString.length)];
    [HTMLString replaceOccurrencesOfString:@"<!-- SITE_NAME -->" withString:site.name options:0 range:NSMakeRange(0, HTMLString.length)];
    if (site.twitterName != nil) {
        [HTMLString appendString:[templateComponents objectAtIndex:1]];
        [HTMLString replaceOccurrencesOfString:@"<!-- TWITTER_NAME -->" withString:site.twitterName options:0 range:NSMakeRange(0, HTMLString.length)];
    }
    NSMutableString *pageString;
    if (site.indexedPages.count > 0) {
        [HTMLString appendString:[templateComponents objectAtIndex:2]];
        for (Page *page in site.indexedPages) {
            pageString = [NSMutableString stringWithString:[templateComponents objectAtIndex:3]];
            [pageString replaceOccurrencesOfString:@"<!-- PAGE_URI -->" withString:page.URI options:0 range:NSMakeRange(0, pageString.length)];
            [pageString replaceOccurrencesOfString:@"<!-- PAGE_NAME -->" withString:page.name options:0 range:NSMakeRange(0, pageString.length)];
            [HTMLString appendString:pageString];
        }
        [HTMLString appendString:[templateComponents objectAtIndex:4]];
    }
    [HTMLString appendString:[templateComponents objectAtIndex:5]];
    [HTMLString replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:0 range:NSMakeRange(0, HTMLString.length)];
    
    return [HTMLString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)dataForPage:(Page *)page inSite:(Site *)site {
    NSString *template = [NSString stringWithContentsOfFile:[HTML pathForResource:@"page.html"] encoding:NSUTF8StringEncoding error:nil];
    NSArray *templateComponents = [template componentsSeparatedByString:@"<!-- ---- -->"];
    
    // Construct HTML string from template components
    NSMutableString *HTMLString = [NSMutableString stringWithString:[templateComponents objectAtIndex:0]];
    [HTMLString replaceOccurrencesOfString:@"<!-- GENERATOR -->" withString:kHTMLGenerator options:0 range:NSMakeRange(0, HTMLString.length)];
    [HTMLString replaceOccurrencesOfString:@"<!-- SITE_NAME -->" withString:site.name options:0 range:NSMakeRange(0, HTMLString.length)];
    [HTMLString replaceOccurrencesOfString:@"<!-- PAGE_NAME -->" withString:page.name options:0 range:NSMakeRange(0, HTMLString.length)];
    NSMutableString *sectionString;
    for (PageSection *section in page.sections) {
        sectionString = [NSMutableString stringWithString:[templateComponents objectAtIndex:1]];
        [sectionString replaceOccurrencesOfString:@"<!-- SECTION_TEXT -->" withString:section.text options:0 range:NSMakeRange(0, sectionString.length)];
        [HTMLString appendString:sectionString];
    }
    [HTMLString appendString:[templateComponents objectAtIndex:2]];
    [HTMLString replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:0 range:NSMakeRange(0, HTMLString.length)];
    
    return [HTMLString dataUsingEncoding:NSUTF8StringEncoding];
}

@end

//
// HTML.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "HTML.h"
#import "NSString+THTML.h"

@interface HTML ()

+ (NSString *)headForSite:(Site *)site currentPage:(Page *)currentPage;
+ (NSString *)headerForSite:(Site *)site currentPage:(Page *)currentPage;
+ (NSString *)footerForSite:(Site *)site;
+ (NSString *)menuForSite:(Site *)site currentPage:(Page *)currentPage;
+ (NSString *)mainForPages:(NSArray *)pages;
+ (NSString *)mainForPage:(Page *)page;

@end

@implementation HTML

+ (NSDictionary *)HTMLForSite:(Site *)site {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    [dictionary setObject:[NSString stringWithFormat:@"%@%@%@%@%@", [HTML headForSite:site currentPage:nil], [HTML headerForSite:site currentPage:nil], [HTML mainForPages:site.featuredPages], [HTML menuForSite:site currentPage:nil], [HTML footerForSite:site]] forKey:site.URI];
    for (Page *page in site.pages) {
        [dictionary setObject:[NSString stringWithFormat:@"%@%@%@%@%@", [HTML headForSite:site currentPage:page], [HTML headerForSite:site currentPage:page], [HTML mainForPage:page], [HTML menuForSite:site currentPage:page], [HTML footerForSite:site]] forKey:page.URI];
    }
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

+ (NSString *)headForSite:(Site *)site currentPage:(Page *)currentPage {
    NSString *title = site.name;
    if (currentPage != nil && currentPage.name.length > 0) {
        title = [NSString stringWithFormat:@"%@ - %@", currentPage.name, site.name];
    }
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<!DOCTYPE html>\n"];
    [string appendFormat:@"<title>%@</title>\n", title];
    [string appendFormat:@"<meta name=\"generator\" content=\"%@\">\n", [[[NSBundle mainBundle] executablePath] lastPathComponent]];
    [string appendString:@"<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\">\n"];
    [string appendFormat:@"<meta name=\"apple-mobile-web-app-title\" content=\"%@\">\n", site.name];
    [string appendFormat:@"<link rel=\"apple-touch-icon\" href=\"%@\">\n", site.touchIcon];
    [string appendFormat:@"<link rel=\"stylesheet\" href=\"%@\">\n", site.stylesheetURI];
    return [NSString stringWithString:string];
}

+ (NSString *)headerForSite:(Site *)site currentPage:(Page *)currentPage {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<header>\n"];
    if (currentPage != nil && ! [currentPage.URI isEqualToString:site.URI]) {
        [string appendFormat:@"    <h1><a href=\"%@\">%@</a></h1>\n", site.URI, site.name];
    } else {
        [string appendFormat:@"    <h1>%@</h1>\n", site.name];
    }
    [string appendString:@"</header>\n"];
    return [NSString stringWithString:string];
}

+ (NSString *)footerForSite:(Site *)site {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<footer>\n"];
    if (site.twitterName.length > 0) {
        [string appendFormat:@"    <p><a href=\"https://twitter.com/%@\">@%@</a></p>\n", site.twitterName, site.twitterName];
    }
    [string appendString:@"</footer>"];
    return [NSString stringWithString:string];
}

+ (NSString *)menuForSite:(Site *)site currentPage:(Page *)currentPage {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<menu>\n"];
    if (site.indexedPages.count > 0) {
        [string appendString:@"    <ul>\n"];
        for (Page *page in site.indexedPages) {
            if (currentPage != nil && [currentPage.URI isEqualToString:page.URI]) {
                [string appendFormat:@"        <li><span>%@</span> &nearr;</li>\n", page.name];
                continue;
            }
            [string appendFormat:@"        <li><a href=\"%@\">%@</a></li>\n", page.URI, page.name];
        }
        [string appendString:@"    </ul>\n"];
    }
    [string appendString:@"</menu>\n"];
    return [NSString stringWithString:string];
}

+ (NSString *)mainForPages:(NSArray *)pages {
    NSMutableString *string = [NSMutableString string];
    if (pages.count > 0) {
        [string appendString:@"<main>\n"];
        [string appendString:@"    <ul>\n"];
        for (Page *page in pages) {
            NSString *imageURI = @"";
            for (PageSection *section in page.sections) {
                if (section.type != PageSectionTypeImage) {
                    continue;
                }
                imageURI = section.URI;
                break;
            }
            if (imageURI.length > 0) {
                [string appendFormat:@"        <li><a href=\"%@\"><img src=\"%@\"></a></li>\n", page.URI, imageURI];
                continue;
            }
            [string appendFormat:@"        <li><span><a href=\"%@\">%@</a></span></li>\n", page.URI, page.name];
        }
        [string appendString:@"    </ul>\n"];
        [string appendString:@"</main>\n"];
    }
    return [NSString stringWithString:string];
}

+ (NSString *)mainForPage:(Page *)page {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<main>\n"];
    [string appendFormat:@"    <h1>%@</h1>\n", page.name];
    for (PageSection *section in page.sections) {
        switch (section.type) {
            case PageSectionTypeBasic:
                [string appendFormat:@"    <p>%@</p>\n", [NSString HTMLStringFromString:section.text detectLinks:YES]];
                break;
            case PageSectionTypeImage:
                [string appendFormat:@"    <figure><a href=\"%@\"><img src=\"%@\"></a></figure>\n", section.URI, section.URI];
                break;
            case PageSectionTypeAudio:
                [string appendFormat:@"    <audio src=\"%@\" preload=\"metadata\" controls>\n", section.URI];
                break;
            case PageSectionTypeVideo:
                [string appendFormat:@"    <video src=\"%@\" preload=\"metadata\" controls>\n", section.URI];
                break;
        }
    }
    [string appendString:@"</main>\n"];
    return [NSString stringWithString:string];
}

@end

//
// HTML.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "HTML.h"

@interface HTML ()

+ (NSString *)headForSite:(Site *)site currentPage:(Page *)currentPage;
+ (NSString *)menuForSite:(Site *)site currentPage:(Page *)currentPage;
+ (NSString *)bodyForPages:(NSArray *)pages;
+ (NSString *)bodyForPage:(Page *)page;

@end

@implementation HTML

+ (NSDictionary *)HTMLForSite:(Site *)site {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    [dictionary setObject:[NSString stringWithFormat:@"%@%@%@", [HTML headForSite:site currentPage:nil], [HTML bodyForPages:site.featuredPages], [HTML menuForSite:site currentPage:nil]] forKey:site.URI];
    for (Page *page in site.pages) {
        [dictionary setObject:[NSString stringWithFormat:@"%@%@%@", [HTML headForSite:site currentPage:page], [HTML bodyForPage:page], [HTML menuForSite:site currentPage:page]] forKey:page.URI];
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

+ (NSString *)menuForSite:(Site *)site currentPage:(Page *)currentPage {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<menu>\n"];
    if (currentPage != nil && ! [currentPage.URI isEqualToString:site.URI]) {
        [string appendFormat:@"    <h1><a href=\"%@\">%@</a></h1>\n", site.URI, site.name];
    } else {
        [string appendFormat:@"    <h1>%@</h1>\n", site.name];
    }
    if (site.indexedPages.count > 0) {
        [string appendString:@"    <ul>\n"];
        for (Page *page in site.indexedPages) {
            if (currentPage != nil && [currentPage.URI isEqualToString:page.URI]) {
                [string appendFormat:@"        <li>%@</li>\n", page.name];
                continue;
            }
            [string appendFormat:@"        <li><a href=\"%@\">%@</a></li>\n", page.URI, page.name];
        }
        [string appendString:@"    </ul>\n"];
    }
    [string appendString:@"</menu>"];
    return [NSString stringWithString:string];
}

+ (NSString *)bodyForPages:(NSArray *)pages {
    NSMutableString *string = [NSMutableString string];
    if (pages.count > 0) {
        [string appendString:@"<article>\n"];
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
                [string appendFormat:@"    <p><a href=\"%@\"><img src=\"%@\"></a></p>\n", page.URI, imageURI];
                continue;
            }
            [string appendFormat:@"    <p><a href=\"%@\">%@</a></p>\n", page.URI, page.name];
        }
        [string appendString:@"</article>\n"];
    }
    return [NSString stringWithString:string];
}

+ (NSString *)bodyForPage:(Page *)page {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<article>\n"];
    [string appendFormat:@"    <h1>%@</h1>\n", page.name];
    for (PageSection *section in page.sections) {
        switch (section.type) {
            case PageSectionTypeBasic:
                [string appendFormat:@"    <p>%@</p>\n", section.text];
                break;
            case PageSectionTypeImage:
                [string appendFormat:@"    <p><img src=\"%@\"></p>\n", section.URI];
                break;
            case PageSectionTypeAudio:
                [string appendFormat:@"    <audio src=\"%@\" preload=\"metadata\" controls>\n", section.URI];
                break;
            case PageSectionTypeVideo:
                [string appendFormat:@"    <video src=\"%@\" preload=\"metadata\" controls>\n", section.URI];
                break;
        }
    }
    [string appendString:@"</article>\n"];
    return [NSString stringWithString:string];
}

@end

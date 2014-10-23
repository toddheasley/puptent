//
//  HTML.m
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import "HTML.h"
#import "NSString+HTML.h"

@interface HTML ()

- (NSString *)headHTMLForPage:(NSInteger)pageIndex;
- (NSString *)headerHTMLForPage:(NSInteger)pageIndex;
- (NSString *)footerHTML;
- (NSString *)menuHTMLForPage:(NSInteger)pageIndex;
- (NSString *)pageHTML:(NSInteger)pageIndex;

@end

@implementation HTML

- (NSError *)generateHTML {
    NSError *error;
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger i = 0; i < self.site.pages.count; i++) {
        
        // Assemble page HTML
        [string setString:@""];
        [string appendString:[self headHTMLForPage:i]];
        [string appendString:[self headerHTMLForPage:i]];
        [string appendString:[self pageHTML:i]];
        [string appendString:[self menuHTMLForPage:i]];
        [string appendString:[self footerHTML]];
        
        error = [self.delegate HTML:[NSString stringWithString:string] forURI:((Page *)[self.site.pages objectAtIndex:i]).URI];
        if (error) {
            return error;
        }
    }
    
    // Assemble site index HTML
    [string setString:@""];
    [string appendString:[self headHTMLForPage:-1]];
    [string appendString:[self headerHTMLForPage:-1]];
    [string appendString:[self menuHTMLForPage:-1]];
    [string appendString:[self footerHTML]];
    
    [self.delegate HTML:[NSString stringWithString:string] forURI:self.site.URI];
    return error;
}

- (NSString *)headHTMLForPage:(NSInteger)pageIndex {
    Page *page;
    if (pageIndex >= 0) {
        page = [self.site.pages objectAtIndex:pageIndex];
    }
    
    NSString *title = self.site.name;
    if (page != nil && page.name.length > 0) {
        title = [NSString stringWithFormat:@"%@ - %@", page.name, self.site.name];
    }
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<!DOCTYPE html>\n"];
    [string appendFormat:@"<title>%@</title>\n", title];
    [string appendFormat:@"<meta name=\"generator\" content=\"%@\">\n", [[[NSBundle mainBundle] executablePath] lastPathComponent]];
    [string appendString:@"<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\">\n"];
    [string appendFormat:@"<meta name=\"apple-mobile-web-app-title\" content=\"%@\">\n", self.site.name];
    [string appendFormat:@"<link rel=\"apple-touch-icon\" href=\"%@\">\n", self.bookmarkIconURI];
    [string appendFormat:@"<link rel=\"stylesheet\" href=\"%@\">\n", self.stylesheetURI];
    if (self.site.twitterName.length > 0 && page != nil && page.name.length > 0) {
        
        // Add Twitter Card support
        for (PageSection *section in page.sections) {
            if (section.type != PageSectionTypeImage) {
                continue;
            }
            [string appendFormat:@"<meta name=\"twitter:creator\" content=\"%@\">\n", self.site.twitterName];
            [string appendFormat:@"<meta name=\"twitter:card\" content=\"photo\">\n"];
            [string appendFormat:@"<meta name=\"twitter:title\" content=\"\">\n"];
            [string appendFormat:@"<meta name=\"twitter:image\" content=\"%@/%@\">\n", self.site.domain, section.URI];
            break;
        }
    }
    return [NSString stringWithString:string];
}

- (NSString *)headerHTMLForPage:(NSInteger)pageIndex {
    Page *page;
    if (pageIndex >= 0) {
        page = [self.site.pages objectAtIndex:pageIndex];
    }
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<header>\n"];
    if (page != nil && ! [page.URI isEqualToString:self.site.URI]) {
        [string appendFormat:@"    <h1><a href=\"%@\">%@</a></h1>\n", self.site.URI, self.site.name];
    } else {
        [string appendFormat:@"    <h1>%@</h1>\n", self.site.name];
    }
    [string appendString:@"</header>\n"];
    return [NSString stringWithString:string];
}

- (NSString *)footerHTML {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<footer>\n"];
    if (self.site.twitterName.length > 0) {
        [string appendFormat:@"    <p><a href=\"https://twitter.com/%@\">@%@</a></p>\n", self.site.twitterName, self.site.twitterName];
    }
    [string appendString:@"</footer>"];
    return [NSString stringWithString:string];
}

- (NSString *)menuHTMLForPage:(NSInteger)pageIndex {
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"<menu>\n"];
    [string appendString:@"    <hr>\n"];
    if (self.site.indexedPages.count > 0) {
        [string appendString:@"    <ul>\n"];
        for (Page *page in self.site.indexedPages) {
            if (pageIndex >= 0 && [((Page *)[self.site.pages objectAtIndex:pageIndex]).URI isEqualToString:page.URI]) {
                [string appendFormat:@"        <li><span>%@</span></li>\n", page.name];
                continue;
            }
            [string appendFormat:@"        <li><a href=\"%@\">%@</a></li>\n", page.URI, page.name];
        }
        [string appendString:@"    </ul>\n"];
    }
    [string appendString:@"</menu>\n"];
    return [NSString stringWithString:string];
}

- (NSString *)pageHTML:(NSInteger)pageIndex {
    Page *page = [self.site.pages objectAtIndex:pageIndex];
    
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

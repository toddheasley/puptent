//
// HTML.m
// PupTent
//
// (c) 2014 @toddheasley
//

#import "HTML.h"
#import "NSMutableString+PupTent.h"
#import "THTML.h"

static NSString *kHTMLMediaPath = @"media";
static NSString *kHTMLResources = @"apple-touch-icon.png,favicon.ico,screen.css,jquery.js,swipe.js";
static NSString *kHTMLGenerator = @"Pup Tent 1.0";

@interface HTML ()

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

+ (NSString *)pathForMediaType:(NSString *)type {
    NSString *characters = @"0123456789";
    NSMutableString *path = [NSMutableString stringWithString:@""];
    [path appendString:[NSString stringWithFormat:@"%d-", abs([[NSDate date] timeIntervalSince1970])]];
    for (uint i = 0; i < 4; i++) {
        [path appendFormat: @"%c", [characters characterAtIndex:(arc4random() % characters.length)]];
    }
    return [NSString stringWithFormat:@"%@/%@.%@", kHTMLMediaPath, path, type];
}

+ (NSString *)mediaPath {
    return kHTMLMediaPath;
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
    NSMutableString *template = [NSMutableString stringWithContentsOfFile:[HTML pathForResource:@"index.html"] encoding:NSUTF8StringEncoding error:nil];
    [template replaceOccurrencesOfTag:@"<!-- GENERATOR -->" withString:kHTMLGenerator];
    [template replaceOccurrencesOfTag:@"<!-- SITE_NAME -->" withString:site.name];
    
    NSMutableString *twitterTemplate = [NSMutableString stringWithString:@""];
    if (site.twitterName.length > 0) {
        twitterTemplate = [template substringFromTag:@"<!-- TWITTER[ -->" toTag:@"<!-- ]TWITTER -->"];
        [twitterTemplate replaceOccurrencesOfTag:@"<!-- TWITTER_NAME -->" withString:site.twitterName];
    }
    [template replaceSubstringFromTag:@"<!-- TWITTER[ -->" toTag:@"<!-- ]TWITTER -->" withString:twitterTemplate];
    
    NSMutableString *pages = [NSMutableString stringWithString:@""];
    NSMutableString *pageTemplate;
    for (Page *page in site.indexedPages) {
        pageTemplate = [template substringFromTag:@"<!-- PAGE[ -->" toTag:@"<!-- ]PAGE -->"];
        [pageTemplate replaceOccurrencesOfTag:@"<!-- PAGE_URI -->" withString:page.URI];
        [pageTemplate replaceOccurrencesOfTag:@"<!-- PAGE_NAME -->" withString:page.name];
        [pages appendString:pageTemplate];
    }
    [template replaceSubstringFromTag:@"<!-- PAGE[" toTag:@"<!-- ]PAGE -->" withString:pages];
    
    [template collapseEmptyLines];
    return [template dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)dataForPage:(Page *)page inSite:(Site *)site {
    NSMutableString *template = [NSMutableString stringWithContentsOfFile:[HTML pathForResource:@"page.html"] encoding:NSUTF8StringEncoding error:nil];
    [template replaceOccurrencesOfTag:@"<!-- GENERATOR -->" withString:kHTMLGenerator];
    [template replaceOccurrencesOfTag:@"<!-- SITE_NAME -->" withString:site.name];
    [template replaceOccurrencesOfTag:@"<!-- PAGE_NAME -->" withString:page.name];
    
    NSMutableString *sections = [NSMutableString stringWithString:@""];
    NSMutableString *sectionTemplate;
    NSMutableString *sectionImage, *sectionMedia, *sectionAudio, *sectionVideo, *sectionText;
    for (PageSection *section in page.sections) {
        sectionTemplate = [template substringFromTag:@"<!-- SECTION[ -->" toTag:@"<!-- ]SECTION -->"];
        
        PageSectionType type = section.type;
        if (section.media.count < 1) {
            type = PageSectionTypeBasic;
        }
        sectionImage = [NSMutableString stringWithString:@""];
        sectionAudio = [NSMutableString stringWithString:@""];
        sectionVideo = [NSMutableString stringWithString:@""];
        switch (type) {
            case PageSectionTypeImage:
                sectionImage = [sectionTemplate substringFromTag:@"<!-- SECTION_IMAGE[ -->" toTag:@"<!-- ]SECTION_IMAGE -->"];
                sectionMedia = [NSMutableString stringWithString:@""];
                for (NSString *media in section.media) {
                    [sectionMedia appendString:[sectionImage substringFromTag:@"<!-- SECTION_MEDIA[ -->" toTag:@"<!-- ]SECTION_MEDIA -->"]];
                    [sectionMedia replaceOccurrencesOfTag:@"<!-- SECTION_MEDIA -->" withString:media];
                }
                [sectionImage replaceSubstringFromTag:@"<!-- SECTION_MEDIA[" toTag:@"<!-- ]SECTION_MEDIA -->" withString:sectionMedia];
                sectionMedia = [NSMutableString stringWithString:@""];
                if (section.media.count > 1) {
                    for (uint i = 1; i <= section.media.count; i++) {
                        [sectionMedia appendString:[sectionImage substringFromTag:@"<!-- SECTION_INDEX[ -->" toTag:@"<!-- ]SECTION_INDEX -->"]];
                        [sectionMedia replaceOccurrencesOfTag:@"<!-- SECTION_INDEX -->" withString:[NSString stringWithFormat:@"%u", i]];
                    }
                }
                [sectionImage replaceSubstringFromTag:@"<!-- SECTION_INDEX[" toTag:@"<!-- ]SECTION_INDEX -->" withString:sectionMedia];
                break;
            case PageSectionTypeAudio:
                sectionAudio = [sectionTemplate substringFromTag:@"<!-- SECTION_AUDIO[ -->" toTag:@"<!-- ]SECTION_AUDIO -->"];
                [sectionAudio replaceOccurrencesOfTag:@"<!-- SECTION_MEDIA -->" withString:[section.media objectAtIndex:0]];
                break;
            case PageSectionTypeVideo:
                sectionVideo = [sectionTemplate substringFromTag:@"<!-- SECTION_VIDEO[ -->" toTag:@"<!-- ]SECTION_VIDEO -->"];
                [sectionVideo replaceOccurrencesOfTag:@"<!-- SECTION_MEDIA -->" withString:[section.media objectAtIndex:0]];
                break;
            default:
                break;
        }
        [sectionTemplate replaceSubstringFromTag:@"<!-- SECTION_IMAGE[ -->" toTag:@"<!-- ]SECTION_IMAGE -->" withString:sectionImage];
        [sectionTemplate replaceSubstringFromTag:@"<!-- SECTION_AUDIO[ -->" toTag:@"<!-- ]SECTION_AUDIO -->" withString:sectionAudio];
        [sectionTemplate replaceSubstringFromTag:@"<!-- SECTION_VIDEO[ -->" toTag:@"<!-- ]SECTION_VIDEO -->" withString:sectionAudio];
        
        sectionText = [NSMutableString stringWithString:@""];
        if (section.text.length > 0) {
            sectionText = [sectionTemplate substringFromTag:@"<!-- SECTION_TEXT[ -->" toTag:@"<!-- ]SECTION_TEXT -->"];
            [sectionText replaceOccurrencesOfTag:@"<!-- SECTION_TEXT -->" withString:[NSString HTMLStringFromString:section.text detectLinks:YES]];
        }
        [sectionTemplate replaceSubstringFromTag:@"<!-- SECTION_TEXT[ -->" toTag:@"<!-- ]SECTION_TEXT -->" withString:sectionText];
        
        [sections appendString:sectionTemplate];
    }
    [template replaceSubstringFromTag:@"<!-- SECTION[ -->" toTag:@"<!-- ]SECTION -->" withString:sections];
    
    [template collapseEmptyLines];
    return [template dataUsingEncoding:NSUTF8StringEncoding];
}

@end

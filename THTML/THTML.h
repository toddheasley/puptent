//
// THTML.h
// THTML
//
// (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#import <Availability.h>

#if !defined __THTML
    #define __THTML

    #if ! TARGET_OS_IPHONE && !defined __IPHONE_7_0
        #warning "THTML requires iOS 7"
    #endif

    #import "NSString+THTML.h"
#endif

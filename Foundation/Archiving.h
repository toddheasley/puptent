//
//  Archiving.h
//  PupTent
//
//  (c) 2014 @toddheasley
//

#import <Foundation/Foundation.h>

@protocol Archiving <NSObject>

@property (strong, readonly) NSDictionary *dictionary;
@property (strong, readonly) NSArray *manifest;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

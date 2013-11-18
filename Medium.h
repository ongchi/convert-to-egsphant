//
//  Medium.h
//  DicomToEgsphant
//
//  Created by ? on 23/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Medium : NSObject <NSCoding> {
    NSMutableDictionary *properties;
}

-(NSMutableDictionary*) properties;
-(void) setProperties:(NSDictionary*) newProperties;

@end

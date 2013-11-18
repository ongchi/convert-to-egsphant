//
//  Ramp.h
//  DicomToEgsphant
//
//  Created by ? on 23/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RampSetting : NSObject <NSCoding> {
    NSMutableDictionary *properties;
    NSMutableArray *mediums;
}

-(NSMutableDictionary*) properties;
-(void) setProperties:(NSDictionary*) newProperties;

-(NSMutableArray*) mediums;
-(void) setMediums:(NSArray*) newMediums;

@end

//
//  Ramp.m
//  DicomToEgsphant
//
//  Created by ? on 23/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RampSetting.h"


@implementation RampSetting

-(id) init
{
    if (self=[super init])
    {
        NSArray *keys = [NSArray arrayWithObjects: @"title", nil];
        NSArray *vlaues = [NSArray arrayWithObjects: @"New Ramp Setting", nil];
        properties = [[NSMutableDictionary alloc] initWithObjects: vlaues forKeys: keys];
        
        mediums = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self=[super init])
    {
        [self setProperties:[coder decodeObjectForKey:@"properties"]];
        [self setMediums:[coder decodeObjectForKey:@"mediums"]];
    }
    return self;
}

-(void) dealloc
{
    [properties release];
    [mediums release];
    
    [super dealloc];
}

-(NSMutableDictionary*) properties
{
    return properties;
}

-(void) setProperties:(NSDictionary*) newProperties;
{
    if (properties != newProperties)
    {
        [properties autorelease];
        properties = [[NSMutableDictionary alloc] initWithDictionary: newProperties];
    }
}

-(NSMutableArray*) mediums
{
    return mediums;
}

-(void) setMediums:(NSArray*) newMediums;
{
    if (mediums != newMediums)
    {
        [mediums autorelease];
        mediums = [[NSMutableArray alloc] initWithArray: newMediums];
    }
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:properties forKey:@"properties"];
    [coder encodeObject:mediums forKey:@"mediums"];
}

@end

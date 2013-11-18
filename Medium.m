//
//  Medium.m
//  DicomToEgsphant
//
//  Created by ? on 23/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Medium.h"


@implementation Medium

-(id) init
{
    if (self =[super init])
    {
        NSArray *keys = [NSArray arrayWithObjects: @"medium", @"estepe", @"ctlb", @"ctub", @"denlb", @"denub", nil];
        NSArray *values = [NSArray arrayWithObjects: @"MEDIUM_NAME", @"1", @"0", @"1000", @"0", @"1", nil];
        properties = [[NSMutableDictionary alloc] initWithObjects: values forKeys: keys];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        [self setProperties: [coder decodeObjectForKey:@"properties"]];
    }
    return self;
}

-(void) dealloc
{
    [properties release];
    
    [super dealloc];
}

-(NSMutableDictionary*) properties
{
    return properties;
}

-(void) setProperties:(NSDictionary*) newProperties
{
    if (properties != newProperties)
    {
        [properties autorelease];
        properties = [[NSMutableDictionary alloc] initWithDictionary: newProperties];
    }
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:properties forKey:@"properties"];
}

@end

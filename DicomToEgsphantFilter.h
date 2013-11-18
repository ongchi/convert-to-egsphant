//
//  DicomToEgsphantFilter.h
//  DicomToEgsphant
//
//  Copyright (c) 2007 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>

@interface DicomToEgsphantFilter : PluginFilter {
    IBOutlet NSView *accessoryView;
    IBOutlet id selectedRamp;
    
    NSMutableArray *_rampSettings;
    NSMutableArray *mediums;
}

-(NSMutableArray*) rampSettings;
-(NSMutableArray*) mediums;
-(void) setRampSettings:(NSArray*) newRampSettings;

-(long) filterImage:(NSString*) menuName;

-(void) endSavePanel:(NSSavePanel*) sheet
          returnCode:(int) retCode
         contextInfo:(void*) contextInfo;
-(int) ctToMediumNumber:(float) ctval;
-(float) ctToMediumDensity:(float) ctval;

-(void) saveConfigToDisk;
-(void) loadConfigFromDisk;

@end

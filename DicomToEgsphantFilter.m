//
//  DicomToEgsphantFilter.m
//  DicomToEgsphant
//
//  Copyright (c) 2007 Wang. All rights reserved.
//

#import "DicomToEgsphantFilter.h"

@implementation DicomToEgsphantFilter

// medium                  (CTmax-CTmin)/(max density - min density)
// ------                  --------------------------------------
// AIR700ICRU                       (50-0)/(0.044-0.001)
// LUNG700ICRU                      (300-50)/(0.302-0.044)
// ICRUTISSUE700ICRU                (1125-300)/(1.101-0.302)
// ICRPBONE700ICRU                  (3000-1125)/(2.088-1.101)

-(int) ctToMediumNumber:(float) ctval
{
    float ctlb, ctub;
    int i;
    for (i=0; i<[[self mediums] count]; i++)
    {
        ctlb = [[[[[self mediums] objectAtIndex:i] properties] objectForKey:@"ctlb"] floatValue];
        ctub = [[[[[self mediums] objectAtIndex:i] properties] objectForKey:@"ctub"] floatValue];
        if ((ctval>=ctlb) && (ctval<ctub))
            return i+1;
    }
    // out of boundary
    return 0;
}

-(float) ctToMediumDensity:(float) ctval
{
    int mediumNum;
    float ctlb, ctub, denlb, denub;
    mediumNum = [self ctToMediumNumber:ctval];
    // since medium number start at 1, object index will be medium number - 1
    ctlb = [[[[[self mediums] objectAtIndex:mediumNum-1] properties] objectForKey:@"ctlb"] floatValue];
    ctub = [[[[[self mediums] objectAtIndex:mediumNum-1] properties] objectForKey:@"ctub"] floatValue];
    denlb = [[[[[self mediums] objectAtIndex:mediumNum-1] properties] objectForKey:@"denlb"] floatValue];
    denub = [[[[[self mediums] objectAtIndex:mediumNum-1] properties] objectForKey:@"denub"] floatValue];
    
    return (ctval-ctlb)*(denub-denlb)/(ctub-ctlb)+denlb;
}

-(void) endSavePanel:(NSSavePanel*) sheet
          returnCode:(int) retCode
         contextInfo:(void*) contextInfo
{
    [self saveConfigToDisk];
    
    if (retCode != NSFileHandlingPanelOKButton) return;
    
    // display a waiting window
    id waitWindow = [viewerController startWaitWindow:@"Exporting..."];
    
    // fetch pixel value from current series
    NSMutableString *phantom = [NSMutableString stringWithCapacity: 100];
    
    long i, j, k;
    float *fImage;
    NSArray *pixList = [viewerController pixList];
    DCMPix *curPix;
    
    curPix = [pixList objectAtIndex:0];
    
    // number of medium in this phantom
    [phantom appendFormat:@"%d\n", [[self mediums] count]];
    
    // list of mediums
    for (i=0; i<[[self mediums] count]; i++)
        [phantom appendFormat:@"%@\n", [[[[self mediums] objectAtIndex:i] properties] objectForKey:@"medium"]];
    
    // the ESTEPE value of the medium (dummy)
    for (i=0; i<[[self mediums] count]; i++)
        [phantom appendFormat:@"%f ", [[[[[self mediums] objectAtIndex:i] properties] objectForKey:@"estepe"] floatValue]];
    [phantom appendFormat:@"\n"];
    
    // th number of voxel in X, Y, Z dimensions
    [phantom appendFormat:@" %ld %ld %d\n", [curPix pwidth], [curPix pheight], [pixList count]];
    
    // voxel bondaries in X dimision (cm)
    for (i=0; i<=[curPix pwidth]; i++)
        [phantom appendFormat:@"%f ", ([curPix originX]+i*[curPix pixelSpacingX])/10];
    [phantom appendFormat:@"\n"];
    
    // voxel bondaries in Y dimision (cm)
    for (i=0; i<=[curPix pheight]; i++)
        [phantom appendFormat:@"%f ", ([curPix originY]+i*[curPix pixelSpacingY])/10];
    [phantom appendFormat:@"\n"];
    
    // voxel bondaries in Z dimision (cm)
    for (i=0; i<=[pixList count]; i++)
        [phantom appendFormat:@"%f ", ([curPix originZ]-0.5*[curPix sliceInterval]+i*[curPix sliceInterval])/10];
    [phantom appendFormat:@"\n"];
    
    // medium number in each voxel
    for (i=0; i<[pixList count]; i++)
    {
        curPix = [pixList objectAtIndex :i];
        fImage = [curPix fImage];
        for (j=0; j<[curPix pwidth]; j++)
        {
            for (k=0; k<[curPix pheight]; k++)
            {
                if (![self ctToMediumNumber:*fImage])
                {
                    NSRunInformationalAlertPanel( @"Alert", @"CT value out of boundary!\nCancel export to phantom.", nil, nil, nil );
                    [viewerController endWaitWindow: waitWindow];
                    return;
                }
                [phantom appendFormat:@"%d", [self ctToMediumNumber:*fImage]];
                fImage++;
            }
            [phantom appendFormat:@"\n"];
        }
        [phantom appendFormat:@"\n\n"];
    }
    
    // densities in each voxel
    for (i=0; i<[pixList count]; i++)
    {
        curPix = [pixList objectAtIndex :i];
        fImage = [curPix fImage];
        for (j=0; j<[curPix pwidth]; j++)
        {
            for (k=0; k<[curPix pheight]; k++)
            {
                [phantom appendFormat:@"%f ", [self ctToMediumDensity:*fImage]];
                fImage++;
            }
            [phantom appendFormat:@"\n"];
        }
        [phantom appendFormat:@"\n\n"];
    }
    
    // write phantom data to file
    [sheet setRequiredFileType:@"egsphant"];
    [phantom writeToFile: [sheet filename] atomically: YES];
    
    // close waiting window
    [viewerController endWaitWindow: waitWindow];
}

-(id) init
{
    if (self = [super init])
    {
        _rampSettings = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) dealloc
{
    [_rampSettings release];
    
    [super dealloc];
}

-(void) awakeFromNib
{
    [self loadConfigFromDisk];
}

-(NSString *) pathForConfigFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/OsiriX Data/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath: folder attributes: nil];
    }
    
    NSString *fileName = @"plugin.DicomToEgsphant.config";
    return [folder stringByAppendingPathComponent: fileName];
}

-(void) saveConfigToDisk
{
    NSString *path = [self pathForConfigFile];
    
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue: [self rampSettings] forKey:@"rampSettings"];
    [NSKeyedArchiver archiveRootObject: rootObject toFile: path];
}

-(void) loadConfigFromDisk
{
    NSString *path = [self pathForConfigFile];
    NSDictionary *rootObject;
    
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    [self setRampSettings: [rootObject valueForKey:@"rampSettings"]];
}

-(NSMutableArray*) rampSettings
{
    return _rampSettings;
}

-(NSMutableArray*) mediums
{
    return[[_rampSettings objectAtIndex:[selectedRamp indexOfSelectedItem]] mediums];
}

-(void) setRampSettings:(NSArray*) newRampSettings
{
    if (_rampSettings != newRampSettings)
    {
        [_rampSettings autorelease];
        _rampSettings = [[NSMutableArray alloc] initWithArray: newRampSettings];
    }
}

-(long) filterImage:(NSString*) menuName
{
    NSArray *topLevelObjects;
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"RampSelector" bundle:thisBundle];
	[nib instantiateNibWithOwner:self topLevelObjects:&topLevelObjects];
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setAccessoryView:accessoryView];
	[panel beginSheetForDirectory:nil
	                         file:nil
	               modalForWindow:[viewerController window]
	                modalDelegate:self
	               didEndSelector:@selector(endSavePanel:
                                            returnCode:
                                            contextInfo:)
	                  contextInfo:nil];
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"egsphant", nil]];
	
	return 0;
}

@end

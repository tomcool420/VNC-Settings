//
//  MLoader.m
//  SeatbeltToggler
//
//  Created by Thomas Cool on 10/22/10.
//  Copyright 2010 tomcool.org. All rights reserved.
//
#import "MLoader.h"
#import <BackRow/BackRow.h>

static NSString * const kVNCEnabledBool             = @"Enabled";
static NSString * const kVNCDefaultScreensizeBool   = @"DefaultScreenSize";
static NSString * const kVNCAspectRatioBool         = @"KeepAspectRatio";
static NSString * const kVNCScaleWidthInt           = @"ScaledWidth";
static NSString * const kVNCScaleHeightInt          = @"ScaledHeight";
static NSString * const kVNCForceFallbackBool       = @"ForceFallback";
static NSString * const kVNCPasswordString          = @"VNCPassword";

static int lastSelectedRow_ = -1;
#define PREFS [VNCSettingsController preferences]

@implementation VNCSettingsBundle
+(NSString *)displayName
{
    return @"VNC Settings";
}
-(NSString *)displayName
{
    return @"VNC Settings";
}
-(NSString *)summary
{
    return @"Control Brandon Holland's VNC implementation";
}
-(BRImage *)art
{
    return [[BRThemeInfo sharedTheme] appleTVIconOOB];
}
+(BRMenuController *)settingsController
{
    
    VNCSettingsController *m = [[VNCSettingsController alloc]init];
    return [m autorelease];
}
@end

enum {
    kVNCEnable=0,
    kVNCDefaultScreensize,
    kVNCKeepAspectRatio,
    kVNCScreenScaleWidth,
    kVNCScreenScaleHeight,
    kVNCForceFallback,
    kVNCPassword,
    kVNCOptions
};
@implementation VNCSettingsController
+(SMFPreferences *)preferences {
    static SMFPreferences *_preferences = nil;
    
    if(!_preferences)
    {
        _preferences = [[SMFPreferences alloc] initWithPersistentDomainName:@"com.whatanutbar.exposed"];
        [_preferences registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES],kVNCEnabledBool,
                                        [NSNumber numberWithBool:YES],kVNCDefaultScreensizeBool,
                                        [NSNumber numberWithBool:YES],kVNCAspectRatioBool,
                                        [NSNumber numberWithInt:1280],kVNCScaleWidthInt,
                                        [NSNumber numberWithInt:720] ,kVNCScaleHeightInt,
                                        [NSNumber numberWithBool:YES],kVNCForceFallbackBool,
                                        @""                          ,kVNCPasswordString,
                                        nil]];

    }
    
    return _preferences;
}
-(void)reload
{
    [[self list]reload];
}
-(id)previewControlForItem:(long)item
{
    SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
    switch (item) {
        case kVNCEnable:
            [asset setTitle:@"Enable VNC"];
            [asset setSummary:@"Toggle to Enable or Disable VNC"];
            break;
        case kVNCDefaultScreensize:
            [asset setTitle:@"Keep Default Screen Size"];
            [asset setSummary:@"Toggle that sets screensize: OFF means custom scaling will be used"];
            break;
        case kVNCKeepAspectRatio:
            [asset setTitle:@"Keep Aspect Ratio"];
            [asset setSummary:@"If enabled, when on scale dimension is changed, the other will be changed accordingly"];
            break;
        case kVNCScreenScaleWidth:
            [asset setTitle:@"Scale Width"];
            [asset setSummary:@"Set scaled width (requires default screen size to be disabled"];
            break;
        case kVNCScreenScaleHeight:
            [asset setTitle:@"Scale Height"];
            [asset setSummary:@"Set scaled height (requires default screen size to be disabled"];
            break;
        case kVNCForceFallback:
            [asset setTitle:@"Force Fallback"];
            [asset setSummary:@"Forces the use of the fallback method (uses contexts instead of IOSurface)"];
            break;
        case kVNCPassword:
            [asset setTitle:@"VNC Password"];
            break;
        default:
            break;
    }
    [asset setCoverArt:[[BRThemeInfo sharedTheme]appleTVIcon]];
    SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
    [p setShowsMetadataImmediately:YES];
    [p setAsset:asset];
    [asset release];
    return [p autorelease];
}
- (long)itemCount							
{ 
    return kVNCOptions;
}
- (id)itemForRow:(long)row					
{ 
    switch (row) {
        case kVNCEnable:
        {
            SMFMenuItem *it = [SMFMenuItem menuItem];
            [it setTitle:[NSString stringWithFormat:@"VNC is %@",@"Enabled",nil]];
            [it setRightText:([[PREFS objectForKey:kVNCEnabledBool] boolValue]?@"YES":@"NO")];
            return it;
            break;
        }
        case kVNCDefaultScreensize:
        {
            SMFMenuItem *it = [SMFMenuItem menuItem];
            [it setTitle:@"Keep Default Screen Size"];
            [it setRightText:([[PREFS objectForKey:kVNCDefaultScreensizeBool] boolValue]?@"YES":@"NO")];
            return it;
            break;
        }
        case kVNCKeepAspectRatio:
        {
            SMFMenuItem *it = [SMFMenuItem menuItem];
            [it setTitle:@"Keep Aspect Ratio"];
            [it setRightText:([[PREFS objectForKey:kVNCAspectRatioBool] boolValue]?@"YES":@"NO")];
            if ([[PREFS objectForKey:kVNCDefaultScreensizeBool] boolValue]) {
                [it setDimmed:YES];
            }
            
            return it;
            break;
        }
        case kVNCScreenScaleWidth:
        {
            SMFMenuItem *it = [SMFMenuItem folderMenuItem];
            [it setTitle:@"Scale Width"];
            [it setRightText:[NSString stringWithFormat:@"%d",[[PREFS objectForKey:kVNCScaleWidthInt] intValue],nil]];
            if ([[PREFS objectForKey:kVNCDefaultScreensizeBool] boolValue]) {
                [it setDimmed:YES];
            }
            return it;
            break;
        }
            
        case kVNCScreenScaleHeight:
        {
            SMFMenuItem *it = [SMFMenuItem folderMenuItem];
            [it setTitle:@"Scale Height"];
            [it setRightText:[NSString stringWithFormat:@"%d",[[PREFS objectForKey:kVNCScaleHeightInt] intValue],nil]];
            if ([[PREFS objectForKey:kVNCDefaultScreensizeBool] boolValue]) {
                [it setDimmed:YES];
            }
            else if ([[PREFS objectForKey:kVNCAspectRatioBool] boolValue]) {
                [it setDimmed:YES];
            }
            return it;
            break;
        }
        case kVNCForceFallback:
        {
            SMFMenuItem *it = [SMFMenuItem menuItem];
            [it setTitle:@"Force Fallback"];
            [it setRightText:([[PREFS objectForKey:kVNCForceFallbackBool] boolValue]?@"YES":@"NO")];
            return it;
            break;
            
        }
        case kVNCPassword:
        {
            SMFMenuItem *it = [SMFMenuItem folderMenuItem];
            [it setTitle:@"VNC Password"];
            [it setRightText:([[PREFS objectForKey:kVNCPasswordString] isEqualToString:@""]?@"(No Password Setup)":[PREFS objectForKey:kVNCPasswordString])];

            return it;
            break;
            
        }
            
        default:
            break;
    }
    return nil;
}

- (id)titleForRow:(long)row					
{ 
    
    return [[self itemForRow:row] text];
}


+(NSString *)rootMenuLabel
{
    return @"org.tomcool.SeabeltToggler";
}
-(id)init
{
    if ((self = [super init])!=nil) {
        [self setListTitle:@"VNC Options"];
        [[self list]addDividerAtIndex:1 withLabel:@""];
        [[self list]addDividerAtIndex:3 withLabel:@""];
        [[self list]addDividerAtIndex:5 withLabel:@""];
        
    }
    return self;
}
-(void)itemSelected:(long)selected
{
    BOOL sendNote=NO;
    switch (selected) {
        case kVNCEnable:
            [PREFS setObject:[NSNumber numberWithBool:![[PREFS objectForKey:kVNCEnabledBool]boolValue]] forKey:kVNCEnabledBool];
            sendNote=YES;
            break;
        case kVNCDefaultScreensize:
            [PREFS setObject:[NSNumber numberWithBool:![[PREFS objectForKey:kVNCDefaultScreensizeBool]boolValue]] forKey:kVNCDefaultScreensizeBool];
            sendNote=YES;
            break;
        case kVNCKeepAspectRatio:
            [PREFS setObject:[NSNumber numberWithBool:![[PREFS objectForKey:kVNCAspectRatioBool]boolValue]] forKey:kVNCAspectRatioBool];
            sendNote=YES;
            break;

        case kVNCForceFallback:
            [PREFS setObject:[NSNumber numberWithBool:![[PREFS objectForKey:kVNCForceFallbackBool]boolValue]] forKey:kVNCForceFallbackBool];
            sendNote=YES;
            break;
        case kVNCScreenScaleWidth:
        {
            SMFPasscodeController *p = [SMFPasscodeController passcodeWithTitle:@"Scaled Width" 
                                                                withDescription:@"Set value to which to scale width"
                                                                      withBoxes:4
                                                                   withDelegate:self];
            [p setInitialValue:[[PREFS objectForKey:kVNCScaleWidthInt]intValue]];
            lastSelectedRow_=kVNCScreenScaleWidth;
            [[self stack] pushController:p];
            
            break;
        }
        case kVNCScreenScaleHeight:
        {
            SMFPasscodeController *p = [SMFPasscodeController passcodeWithTitle:@"Scaled Height" 
                                                                withDescription:@"Set value to which to scale height"
                                                                      withBoxes:4
                                                                   withDelegate:self];
            [p setInitialValue:[[PREFS objectForKey:kVNCScaleHeightInt]intValue]];
            lastSelectedRow_=kVNCScreenScaleHeight;
            [[self stack] pushController:p];
            
            break;
        }
        case kVNCPassword:
        {
            BRTextEntryController *tc = [[BRTextEntryController alloc] initWithTextEntryStyle:1];
            [tc setListTitle:@"Please Enter Desired VNC Password"];
            //[tc setInitialTextEntryText:[PREFS objectForKey:kVNCPasswordString]];
            [tc setTextFieldDelegate:self];
            lastSelectedRow_=kVNCPassword;
            [[self stack]pushController:[tc autorelease]];
            
            break;
        }
        default:
            break;
    }
    if (sendNote) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VNCSettingsUpdated" object:self];
    }
    lastSelectedRow_=selected;
    [[self list] reload];
}
- (void) textDidEndEditing: (id) sender
{
    BOOL sendNote=NO;
    if (lastSelectedRow_==kVNCScreenScaleWidth) {
        int r= [[sender stringValue] intValue];
        [PREFS setObject:[NSNumber numberWithInt:r] forKey:kVNCScaleWidthInt];
        sendNote=YES;
    }
    else if (lastSelectedRow_==kVNCScreenScaleHeight) {
        int r= [[sender stringValue] intValue];
        [PREFS setObject:[NSNumber numberWithInt:r] forKey:kVNCScaleHeightInt];
        sendNote=YES;
    }
    else if (lastSelectedRow_==kVNCPassword)
    {
        NSString *s = [sender stringValue];
        [PREFS setObject:s forKey:kVNCPasswordString];
        sendNote=YES;
    }
    if (sendNote) {
       [[NSNotificationCenter defaultCenter] postNotificationName:@"VNCSettingsUpdated" object:self];
    }
    [[self stack]popController];
    [[self list] reload];
}
- (void) textDidChange: (id) sender
{
    
}
@end
//
//  awoPhotoArrayController.m
//  icloud_poc_osx
//
//  Created by JASON CROSS on 7/29/12.
//  Copyright (c) 2012 JASON CROSS. All rights reserved.
//

#import "awoPhotoArrayController.h"
#import "Photo.h"

@implementation awoPhotoArrayController

@synthesize photosTable;

- (id) init {
    self = [super init];
    if (nil != self) {
        // other devices need to know when the transaction log file is changed for Core Data's SQLite file
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentDidChange)
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                   object:nil];
    }
    return self;
}

- (id) newObject
{
    id newObj = [super newObject];
    NSDate * now = [NSDate date];
    [newObj setValue: now
              forKey:@"dateAdded"];
    
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSImage imageFileTypes]];
    NSWindow * mainWin = [NSApp mainWindow];
    [panel beginSheetModalForWindow:mainWin
                  completionHandler:^ (NSInteger result)
     {
         if (result == NSOKButton)
         {
             NSImage *image = [[NSImage alloc] initWithContentsOfURL:
                               [panel URL]];
             
             Photo * photo = (Photo *) newObj;
             [photo saveImage:image];
         }
         panel = nil; // prevent strong ref cycle
         [self.photosTable reloadData];
     }];
    return newObj;
}



#pragma mark - iCloud
- (void) contentChange: (NSNotification*) note
{
    // merge changes into context
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
    
    // need to update the list of photos with any changes
    [[self photosTable] reloadData];
}

#pragma mark - memory management

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

//
//  awoPhotoArrayController.m
//  artwallorganizerosx
//
//  Created by JASON CROSS on 7/29/12.
//  Copyright (c) 2012 JASON CROSS. All rights reserved.
//

#import "awoPhotoArrayController.h"
#import "awoAppDelegate.h"
#import "Photo.h"

@implementation awoPhotoArrayController

@synthesize photosTable;

- (id) init {
    self = [super init];
    if (nil != self) {
        // other devices need to know when the transaction log file is changed for Core Data's SQLite file
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentChange:)
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                   object:nil];
    }
    return self;
}

- (id) newObject
{
    awoAppDelegate * appDelegate = (awoAppDelegate *)[NSApp delegate];
    NSManagedObject *newManagedObject = [appDelegate newObject];
    Photo * newPhoto = (Photo *)newManagedObject;
    
    NSDate * now = [NSDate date];
    [newPhoto setValue: now
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
             
             [newPhoto saveImage:image];
         }
         panel = nil; // prevent strong ref cycle
         [appDelegate saveContext];
         [self.photosTable reloadData];
     }];
    return newPhoto;
}

- (void) remove:(id)sender
{
    NSUInteger selectedIndex = [self.photosTable selectedRow];
    awoAppDelegate * appDelegate = (awoAppDelegate *)[NSApp delegate];
    NSMutableArray * photos = [appDelegate photos];
    NSManagedObject * objectToRemove = [photos objectAtIndex:selectedIndex];
    [self removeObject:objectToRemove];
}

- (void) removeObject:(id)object
{
    awoAppDelegate * appDelegate = (awoAppDelegate *)[NSApp delegate];
    [appDelegate removeObject:object];
    [self.photosTable reloadData];
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

//
//  awoAppDelegate.h
//  artwallorganizerosx
//
//  Created by JASON CROSS on 8/2/12.
//  Copyright (c) 2012 JASON CROSS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface awoAppDelegate : NSObject <NSApplicationDelegate, NSFilePresenter> {
    NSURL* _ubContainer;
    NSOperationQueue * _presentedItemOperationQueue;
}


@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray * photos;


- (void) saveContext;
- (IBAction)saveAction:(id)sender;
- (NSManagedObject *) newObject;
- (void) removeObject:(id)object;

@end

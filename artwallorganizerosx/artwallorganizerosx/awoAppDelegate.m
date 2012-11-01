//
//  awoAppDelegate.m
//  artwallorganizerosx
//
//  Created by JASON CROSS on 8/2/12.
//  Copyright (c) 2012 JASON CROSS. All rights reserved.
//

#import "awoAppDelegate.h"

@implementation awoAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize photos = _photos;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    

}

// Returns the directory the application uses to store the Core Data store file.
// This code uses a directory named "ca.jasoncross.artwallorganizerosx" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"ca.jasoncross.artwallorganizerosx"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"artwallorganizerosx" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// This implementation creates and return a coordinator, having added the store for the application to it.
// (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    // Find the location of the ubiquity container on the filesystem
    NSFileManager *fileManager = [NSFileManager defaultManager];
    _ubContainer = [fileManager URLForUbiquityContainerIdentifier:@"ZT7E887Q9H.ca.jasoncross.artwallorganizer"];
    NSLog(@"Laptop ubuity container: %@", _ubContainer);
    
    // construct the dictionary that tells core data
    // where the transaction log should be stored
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:@"artwallorganizer"
                forKey:NSPersistentStoreUbiquitousContentNameKey];
    [options setObject:_ubContainer
                forKey:NSPersistentStoreUbiquitousContentURLKey];
    
    // this helps with core data versioning mis matches
    [options setObject:[NSNumber numberWithBool:YES]
                forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:[NSNumber numberWithBool:YES]
                forKey:NSInferMappingModelAutomaticallyOption];
    
    // specify a new directory and create it in the ubiquity container
    NSURL *nosyncDir = [_ubContainer URLByAppendingPathComponent:@"artwallorganizer.nosync"];
    [fileManager createDirectoryAtURL:nosyncDir
          withIntermediateDirectories:YES
                           attributes:nil
                                error:nil];

    NSURL *storeURL = nil;
    storeURL = [nosyncDir URLByAppendingPathComponent:@"icloud_poc.sqlite"];
    /*
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey]
                                                                          error:&error];
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path]
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:
                                            @"Expected a folder to store application data, found a file (%@).",
                                            [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN"
                                        code:101
                                    userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"artwallorganizerosx.storedata"];
     */
    //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    NSError *error = nil;
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSPersistentStore * successfulOpen = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:storeURL
                                                                         options:options
                                                                           error:&error];
    if(!successfulOpen) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the
// persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - NSFilePresenter protocol

- (NSURL *) presentedItemURL {
    if (nil == _ubContainer) {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        _ubContainer = [fileManager URLForUbiquityContainerIdentifier:@"ZT7E887Q9H.ca.jasoncross.artwallorganizer"];
    }
    return _ubContainer;
}

- (NSOperationQueue *) presentedItemOperationQueue {
    if (nil == _presentedItemOperationQueue) {
        _presentedItemOperationQueue = [[NSOperationQueue alloc] init];
    }
    return _presentedItemOperationQueue;
}


#pragma mark -

// Returns the NSUndoManager for the application. In this case, the manager returned is
// that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to
// the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void) setPhotos:(NSMutableArray *)a
{
    if (_photos == a) {
        return;
    }
    _photos = a;
}

- (NSMutableArray *) photos
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Photo" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
        _photos = [[NSMutableArray alloc] init];
    }
    else
    {
        _photos = [NSMutableArray arrayWithArray:array];
    }
    
    return _photos;
}

- (void)saveContext
{
    __block NSError *error = nil;
    static BOOL filePresenterAdded = NO;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            NSFileCoordinator * fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
            __block BOOL saveSuccessful = NO;
            [fileCoordinator coordinateWritingItemAtURL:_ubContainer
                                                options:NSFileCoordinatorWritingForMerging
                                                  error:&error
                                             byAccessor:^(NSURL *newURL) {
                                                 if (filePresenterAdded == NO) {
                                                     [NSFileCoordinator addFilePresenter:self];
                                                     NSArray * presenters = [NSFileCoordinator filePresenters];
                                                     NSLog(@"file presenters: %@", presenters);
                                                     filePresenterAdded = YES;
                                                 }
                                                 saveSuccessful = [managedObjectContext save:&error];
                                             }];
            
            
                if (saveSuccessful == NO) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

- (NSManagedObject *) newObject
{
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                                      inManagedObjectContext:self.managedObjectContext];
    [self saveContext];
    return newManagedObject;
}

- (void) removeObject:(id)object
{
    [self.managedObjectContext deleteObject:object];
    [self.photos removeObject:object];
    [self saveContext];
}


@end

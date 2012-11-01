//
//  awoAppDelegate.m
//  icloud_poc
//
//  Created by JASON CROSS on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "awoAppDelegate.h"

#import "awoMasterViewController.h"

@implementation awoAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
        awoMasterViewController *controller = (awoMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        awoMasterViewController *controller = (awoMasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    
    [NSFileCoordinator addFilePresenter:self];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            BOOL saveSuccessful = [managedObjectContext save:&error];
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

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"icloud_poc" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    // Find the location of the ubiquity container on the filesystem
    NSFileManager * fileManager = [NSFileManager defaultManager];
    _ubContainer = [fileManager URLForUbiquityContainerIdentifier:@"ZT7E887Q9H.ca.jasoncross.artwallorganizer"];
    NSLog(@"iPad ubuity container: %@", _ubContainer);
    
    // construct the dictionary that tells core data
    // where the transaction log should be stored
    NSMutableDictionary * options = [NSMutableDictionary dictionary];
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
    //storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"icloud_poc.sqlite"];
    //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    NSError *error = nil;
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSPersistentStore * successfulOpen = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:storeURL
                                                                         options:options
                                                                           error:&error];
    if (!successfulOpen) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    __persistentStoreCoordinator = coordinator;
    
    return __persistentStoreCoordinator;
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


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) dealloc {
    [NSFileCoordinator removeFilePresenter:self];
}

@end

//
//  awoMasterViewController.h
//  icloud_poc
//
//  Created by JASON CROSS on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class awoDetailViewController;

#import <CoreData/CoreData.h>


@interface awoMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, 
UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIPopoverController * imagePickerPopover;
}

@property (strong, nonatomic) awoDetailViewController *detailViewController;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

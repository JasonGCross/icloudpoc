//
//  awoDocument.m
//  icloud_poc_osx
//
//  Created by JASON CROSS on 7/29/12.
//  Copyright (c) 2012 JASON CROSS. All rights reserved.
//

#import "awoDocument.h"

@implementation awoDocument

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *src = [self fileURL];
        NSURL *dest = NULL;
        NSURL *ubiquityContainerURL = [[[NSFileManager defaultManager]
                                        URLForUbiquityContainerIdentifier:nil]
                                       URLByAppendingPathComponent:@"Documents"];
        if (ubiquityContainerURL == nil) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  NSLocalizedString(@"iCloud does not appear to be configured.", @""),
                                  NSLocalizedFailureReasonErrorKey, nil];
            NSError *error = [NSError errorWithDomain:@"Application" code:404
                                             userInfo:dict];
            [self presentError:error modalForWindow:[self windowForSheet] delegate:nil
            didPresentSelector:NULL contextInfo:NULL];
        }
        else {
            dest = [ubiquityContainerURL URLByAppendingPathComponent:
                    [src lastPathComponent]];
        }
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"awoDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}


@end

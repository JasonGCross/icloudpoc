//
//  Photo.h
//  icloud_poc
//
//  Created by JASON CROSS on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Sub_Photo.h"

@interface Photo : Sub_Photo

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
- (void) saveImage: (UIImage *)newImage;
@property (nonatomic, strong) UIImage * originalImage;
@property (nonatomic, strong) UIImage * thumbnailImage;



#else
- (void) saveImage: (NSImage *)newImage;
@property (nonatomic, strong) NSImage * originalImage;
@property (nonatomic, strong) NSImage * thumbnailImage;


#endif

@end

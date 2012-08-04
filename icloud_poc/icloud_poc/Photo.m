//
//  Photo.m
//  icloud_poc
//
//  Created by JASON CROSS on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize originalImage;
@synthesize thumbnailImage;


#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
- (NSData *) thumbnailDataFromImage:(UIImage *)image {
    CGSize origImageSize = [image size];
    CGRect newRect = CGRectMake(0, 0, 35, 35);
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    [path addClip];
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    [image drawInRect:projectRect];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *data = UIImagePNGRepresentation(smallImage);
    UIGraphicsEndImageContext();
    
    return data;
}

- (void) saveImage: (UIImage *)newImage
{
    self.originalImageData = UIImagePNGRepresentation(newImage);
    self.thumbnailImageData = [self thumbnailDataFromImage:newImage];
}

- (UIImage *) originalImage
{
    return [[UIImage alloc] initWithData:self.originalImageData];
}

- (UIImage *) thumbnailImage
{
    return [[UIImage alloc] initWithData:self.thumbnailImageData];
}





#else
- (NSData *) thumbnailDataFromImage:(NSImage *)image {
    CGSize origImageSize = [image size];
    CGRect newRect = CGRectMake(0, 0, 17, 17);
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    NSImage *ret = [[NSImage alloc] initWithSize:newRect.size];
    [ret lockFocus];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleBy:ratio];
    [transform concat];
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [ret unlockFocus];
    NSData *data = [ret TIFFRepresentation];

    return data;
}

- (void) saveImage:(NSImage *)newImage {
    self.originalImageData = [newImage TIFFRepresentation];
    self.thumbnailImageData = [self thumbnailDataFromImage:newImage];
}

- (NSImage *) originalImage
{
    return [[NSImage alloc] initWithData:self.originalImageData];
}

- (NSImage *) thumbnailImage
{
    return [[NSImage alloc] initWithData:self.thumbnailImageData];
}


#endif




@end

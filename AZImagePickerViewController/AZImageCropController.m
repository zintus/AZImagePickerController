//
//  AZImageCropController.m
//  AZImagePickerViewController
//
//  Created by Alex Zinchenko on 30/07/2012.
//  Copyright (c) 2012 Alex Zinchenko. All rights reserved.
//

#import "AZImageCropController.h"
#import "MaskView.h"

@interface AZImageCropController () <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView* scroller;

@property (nonatomic, retain) UIImage* originalImage;
@property (nonatomic, retain) UIImageView* imageView;

@end

@implementation AZImageCropController

#pragma mark Init/Dealloc

- (id) initWithImage:(UIImage*) image
{
	self = [super init];
	if (!self)
		return self;
	
	self.originalImage = image;

	
	return self;
}

- (void) releaseOutlets
{
	self.originalImage = nil;
	self.imageView = nil;
	self.scroller = nil;
}

- (void) dealloc
{
	[self releaseOutlets];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	//scroller area is larger than image by this factor
	float factor = 2.,
		originalWidth = self.originalImage.size.width,
		originalHeight = self.originalImage.size.height;
	
	self.imageView = [[[UIImageView alloc] initWithImage:self.originalImage] autorelease];
	[self.scroller addSubview:self.imageView];
	[self.scroller setContentSize:self.imageView.frame.size];
	
	//inset image by a black area
	float insetWidth = originalWidth * (factor - 1.) / 2.;
	float insetHeight = originalHeight * (factor - 1.) / 2.;
	
	//find smallest needed zoom value to fit all image
	float zoomx = self.scroller.frame.size.width / originalWidth;
	float zoomy = self.scroller.frame.size.height / originalHeight;
	float minZoom = MIN(zoomx * (1 - maskedWidthFraction), zoomy * (1 - maskedHeightFraction));
	
	[self.scroller setMinimumZoomScale:minZoom];
	[self.scroller setZoomScale:minZoom];
	
	insetHeight *= minZoom;
	insetWidth *= minZoom;
	
	[self.scroller setContentInset:UIEdgeInsetsMake(insetHeight, insetWidth, insetHeight, insetWidth)];
	
	//reposition to center
	float screenOffsetX = self.scroller.frame.size.width / 2.;
	screenOffsetX -= self.imageView.frame.size.width / 2.;
	
	float screenOffsetY = self.scroller.frame.size.height / 2.;
	screenOffsetY -= self.imageView.frame.size.height / 2.;
	[self.scroller setContentOffset:CGPointMake(-screenOffsetX, -screenOffsetY)];
	
	self.scroller.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[self releaseOutlets];
}

#pragma mark UIScrollView delegate

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

#pragma mark Actions

- (IBAction)actRetake:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#define clamp(x) (x > 0. ? x : 0.)

- (IBAction)actUse:(id)sender
{
	float dx = self.scroller.bounds.size.width * maskedWidthFraction;
	float dy = self.scroller.bounds.size.height * maskedHeightFraction;
	
	float sizeX = 0., sizeY = 0.;
	//find image or mask size
	//right
	float maskX = self.scroller.bounds.size.width - dx / 2;
	float imageX = self.imageView.frame.size.width - self.scroller.contentOffset.x;
	sizeX = maskX > imageX ? imageX : maskX;
	sizeX -= dx / 2;
	//bottom
	float maskY = self.scroller.bounds.size.height - dy / 2;
	float imageY = self.imageView.frame.size.height - self.scroller.contentOffset.y;
	sizeY = maskY > imageY ? imageY : maskY;
	sizeY -= dy / 2;
	//left
	float maskLeft = dx / 2;
	float imageLeft = -self.scroller.contentOffset.x;
	float leftOff = imageLeft > maskLeft ? imageLeft - maskLeft : 0.;
	//up
	float maskUp = dy / 2;
	float imageUp = -self.scroller.contentOffset.y;
	float upOff = imageUp > maskUp ? imageUp - maskUp : 0.;
	
	float windowY = self.scroller.bounds.size.height - dy;
	
	CGSize size = CGSizeMake(floorf(sizeX - leftOff), floorf(sizeY - upOff));
	
	//force scale to 2.
	UIGraphicsBeginImageContextWithOptions(size, NO, 2.);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
	
	CGContextTranslateCTM(ctx, -leftOff, size.height + upOff + clamp(maskY - imageY) - clamp(imageUp - maskUp));
	
	CGContextScaleCTM(ctx, 1, -1);
	CGPoint screenOffset = self.scroller.contentOffset;
	
	//originate to mask upper left corner
	screenOffset.x += dx / 2.;
	screenOffset.y += dy / 2.;
	
	//change offset to lower left corner
	screenOffset.y += windowY;
	screenOffset.y -= self.imageView.frame.size.height;
	
    CGPoint bufferOffset = screenOffset;
	CGContextTranslateCTM(ctx, -bufferOffset.x, bufferOffset.y);

	float angle = 180.0;
	if (self.originalImage.imageOrientation == UIImageOrientationRight)
		angle = 90.;
	else if (self.originalImage.imageOrientation == UIImageOrientationLeft)
		angle = -90.;
	else if (self.originalImage.imageOrientation == UIImageOrientationUp)
		angle = 0.;
	
	self.originalImage = [self image:self.originalImage rotatedByDegrees:angle];

	CGContextDrawImage(ctx,
					   self.imageView.frame,
					   self.originalImage.CGImage);
	
	
	UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if (self.delegate)
	{
		[self.delegate imageCropController:self didFinisedCroppingResultingInImage:img];
	}
}

#pragma mark Image utilities

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

- (UIImage *)image:(UIImage*) image rotatedByDegrees:(CGFloat)degrees
{
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	[rotatedViewBox release];
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

@end

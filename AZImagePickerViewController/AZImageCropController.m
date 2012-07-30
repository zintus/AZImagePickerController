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

- (id) initWithImage:(UIImage*) image
{
	self = [super init];
	if (!self)
		return self;
	
	self.originalImage = image;

	
	return self;
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
	
	[self.scroller setContentInset:UIEdgeInsetsMake(insetHeight, insetWidth, insetHeight, insetWidth)];
	
	//find smallest needed zoom value to fit all image
	float zoomx = self.scroller.frame.size.width / originalWidth;
	float zoomy = self.scroller.frame.size.height / originalHeight;
	float minZoom = MIN(zoomx * (1 - maskedWidthFraction), zoomy * (1 - maskedHeightFraction));
	
	[self.scroller setMinimumZoomScale:minZoom];
	[self.scroller setZoomScale:minZoom];
	
	//reposition to center
	float screenOffsetX = self.scroller.frame.size.width / 2.;
	screenOffsetX -= self.imageView.frame.size.width / 2.;
	
	float screenOffsetY = self.scroller.frame.size.height / 2.;
	screenOffsetY -= self.imageView.frame.size.height / 2.;
	[self.scroller setContentOffset:CGPointMake(-screenOffsetX, -screenOffsetY)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (IBAction)actUse:(id)sender
{
	float dx = self.scroller.bounds.size.width * maskedWidthFraction;
	float dy = self.scroller.bounds.size.height * maskedHeightFraction;
	
	CGSize size = CGSizeMake(self.scroller.bounds.size.width - dx, self.scroller.bounds.size.height - dy);
	
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(ctx, dx / 2, dy / 2);
	CGContextScaleCTM(ctx, -1, -1);
	CGContextDrawImage(ctx, self.imageView.bounds, self.originalImage.CGImage);
	
	UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.imageView.image = img;
}

@end

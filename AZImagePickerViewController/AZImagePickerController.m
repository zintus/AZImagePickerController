//
//  AZImagePickerViewController.m
//  AZImagePickerViewController
//
//  Created by Alex Zinchenko on 30/07/2012.
//  Copyright (c) 2012 Alex Zinchenko. All rights reserved.
//

#import "AZImagePickerController.h"
#import "AZImageCropController.h"

NSString* const AZImagePickerControllerResultingImage = @"AZImagePickerControllerResultingImage";

@interface AZImagePickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AZImageCropControllerDelegate>

@property (nonatomic, retain, readwrite) UIImagePickerController* imagePicker;
@property (nonatomic, retain) NSMutableDictionary* pickingInfo;

@end

@implementation AZImagePickerController

#pragma mark init/dealloc
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		self.imagePicker = [[[UIImagePickerController alloc] init] autorelease];
		self.imagePicker.allowsEditing = NO;
		self.imagePicker.delegate = self;
		
		self.viewControllers = @[self.imagePicker];
		self.navigationBarHidden = YES;
    }
    return self;
}

- (void) releaseOutlets
{
	self.imagePicker = nil;
}

- (void) dealloc
{
	self.pickingInfo = nil;
	[self releaseOutlets];
	[super dealloc];
}

#pragma mark Lifecycle

- (void) viewDidUnload
{
	[super viewDidUnload];
	[self releaseOutlets];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.pickingInfo = [NSMutableDictionary dictionaryWithDictionary:info];
	UIImage* pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	AZImageCropController* cropper = [[[AZImageCropController alloc] initWithImage:pickedImage] autorelease];
	cropper.delegate = self;
	[self pushViewController:cropper animated:YES];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	if (self.viewControllers.count == 1)
		[self dismissModalViewControllerAnimated:YES];
}

#pragma mark ImageCropperControllerDelegate

- (void) imageCropController:(AZImageCropController *)cropper didFinisedCroppingResultingInImage:(UIImage *)image
{
	[self.pickingInfo setObject:image forKey:AZImagePickerControllerResultingImage];
	if (self.pickerDelegate)
		[self.pickerDelegate imagePickerController:self didFinishPickingMediaWithInfo:self.pickingInfo];
}

@end

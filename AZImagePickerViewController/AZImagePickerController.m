//
//  AZImagePickerViewController.m
//  AZImagePickerViewController
//
//  Created by Alex Zinchenko on 30/07/2012.
//  Copyright (c) 2012 Alex Zinchenko. All rights reserved.
//

#import "AZImagePickerController.h"
#import "AZImageCropController.h"

@interface AZImagePickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain, readwrite) UIImagePickerController* imagePicker;
 

@end

@implementation AZImagePickerController

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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	AZImageCropController* cropper = [[[AZImageCropController alloc] initWithImage:pickedImage] autorelease];
	[self pushViewController:cropper animated:YES];
}

@end

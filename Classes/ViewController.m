//
//  ViewController.m
//  AZImagePickerViewController
//
//  Created by Alex Zinchenko on 30/07/2012.
//  Copyright (c) 2012 Alex Zinchenko. All rights reserved.
//

#import "ViewController.h"
#import "AZImagePickerController.h"

@interface ViewController () <AZImagePickerControllerDelegate>

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.imageView = nil;
}

- (void) dealloc
{
	self.imageView = nil;
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)grabImage:(id)sender
{
	AZImagePickerController* ctrl = [[[AZImagePickerController alloc] init] autorelease];
	ctrl.pickerDelegate = self;
	[self presentModalViewController:ctrl animated:YES];
}

#pragma mark AZImagePickerControllerDelegate

- (void)imagePickerController:(AZImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.imageView.image = [info objectForKey:AZImagePickerControllerResultingImage];
	
	[self dismissModalViewControllerAnimated:YES];
}

@end

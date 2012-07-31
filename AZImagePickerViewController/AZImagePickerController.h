//
//  AZImagePickerViewController.h
//  AZImagePickerViewController
//
//  Created by Alex Zinchenko on 30/07/2012.
//  Copyright (c) 2012 Alex Zinchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const AZImagePickerControllerResultingImage;

@class AZImagePickerController;
@protocol AZImagePickerControllerDelegate <NSObject>

@required
- (void) imagePickerController:(AZImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

@end

@interface AZImagePickerController : UINavigationController

@property (nonatomic, retain, readonly) UIImagePickerController* imagePicker;
@property (nonatomic, assign) id<AZImagePickerControllerDelegate> pickerDelegate;


@end

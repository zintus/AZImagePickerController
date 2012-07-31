//
//  AZImageCropController.h
//  AZImagePickerViewController
//
//  Created by Alex Zinchenko on 30/07/2012.
//  Copyright (c) 2012 Alex Zinchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZImageCropController;

@protocol AZImageCropControllerDelegate <NSObject>

@required
- (void) imageCropController:(AZImageCropController *)cropper didFinisedCroppingResultingInImage:(UIImage *)image;

@end

@interface AZImageCropController : UIViewController

- (id) initWithImage:(UIImage*) image;

@property (nonatomic, assign) id<AZImageCropControllerDelegate> delegate;

@end

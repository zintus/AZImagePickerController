//
//  MaskView.m
//  AZImagePickerViewController
//
//  Created by Alex Zinchenko on 30/07/2012.
//  Copyright (c) 2012 Alex Zinchenko. All rights reserved.
//

#import "MaskView.h"

@implementation MaskView


- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	int heightOffset = floorf((1 - (maskedHeightFraction / 2.)) * rect.size.height);
	int widthOffset = floorf((1 - (maskedWidthFraction / 2.)) * rect.size.width);
	int invHeightOffset = rect.size.height - heightOffset;
	int invWidthOffset = rect.size.width - widthOffset;
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0. alpha:0.6].CGColor);
	//top area
	CGContextFillRect(ctx, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 0, heightOffset, 0)));
	
	//bottom area
	CGContextFillRect(ctx, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(heightOffset, 0, 0, 0)));
	
	//left/right
	CGContextFillRect(ctx, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(heightOffset, widthOffset, heightOffset, 0)));
	CGContextFillRect(ctx, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(invHeightOffset, 0, invHeightOffset, widthOffset)));
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextStrokeRectWithWidth(ctx, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(invHeightOffset, invWidthOffset, invHeightOffset, invWidthOffset)), 1.);
}


@end

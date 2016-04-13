//
//  RERatingControl.h
//  RERatingControl
//
//  Created by Nikolay Korotkov on 22/04/15.
//  Copyright (c) 2015 Simple Communication. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RERatingControlDelegate <NSObject>

@optional

- (void)ratingDidChangeTo:(NSInteger)rating;

@end

IB_DESIGNABLE

@interface RERatingControl : UIView

@property (nonatomic, assign) IBInspectable NSInteger numberOfStars;
@property (nonatomic, strong) IBInspectable UIImage *starImageEmpty;
@property (nonatomic, strong) IBInspectable UIImage *starImageFull;
@property (nonatomic, strong) IBInspectable UIColor *fullTintColor;

@property (nonatomic, weak) IBOutlet id <RERatingControlDelegate> delegate;

@end

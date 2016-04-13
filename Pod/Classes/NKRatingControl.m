//
//  RERatingControl.m
//  RERatingControl
//
//  Created by Nikolay Korotkov on 22/04/15.
//  Copyright (c) 2015 Simple Communication. All rights reserved.
//

#import "NKRatingControl.h"

static NSTimeInterval const animationDuration = 0.25;
static NSTimeInterval const animationDelay = 0.015;
static CGFloat const animationScaleRatio = 1.5;

@interface REStarButton : UIButton

@property (nonatomic, assign, getter=isFull) BOOL full;
@property (nonatomic, strong) UIImage *starImageEmpty;
@property (nonatomic, strong) UIImage *starImageFull;
@property (nonatomic, strong) UIColor *fullTintColor;

- (void)makeFullWithDelay:(NSTimeInterval)delay;
- (void)makeEmptyWithDelay:(NSTimeInterval)delay;

@end


@implementation REStarButton


- (instancetype)initWithFrame:(CGRect)frame

{
    self = [super initWithFrame:frame];
    if (self) {
        
        _full = NO;
        
    }
    return self;
}

- (void)makeEmptyWithDelay:(NSTimeInterval)delay {
    
//    if (!self.isFull) {
//        return;
//    }
    
    self.full = NO;
    
    UIImageView *fullStar = [[UIImageView alloc] initWithImage:self.starImageFull];
    [self addSubview:fullStar];
    
    CGFloat xOffset = CGRectGetMidX(self.bounds) - CGRectGetMidX(fullStar.bounds);
    CGFloat yOffset = CGRectGetMidY(self.bounds) - CGRectGetMidY(fullStar.bounds);
    
    fullStar.frame = CGRectOffset(fullStar.frame, xOffset, yOffset);
    
    [self setImage:self.starImageEmpty forState:UIControlStateNormal];
    
    [self setTintColor:self.superview.tintColor];
    
    [UIView animateWithDuration:animationDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        fullStar.transform = CGAffineTransformMakeTranslation(0, 10);
        fullStar.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [fullStar removeFromSuperview];
        
    }];
    
   
    
}

- (void)makeFullWithDelay:(NSTimeInterval)delay {
    
    
//    if (self.isFull) {
//        return;
//    }
    
    self.full = YES;
    
    UIImageView *fullStar = [[UIImageView alloc] initWithImage:self.starImageFull];
    
    
    CGFloat xOffset = CGRectGetMidX(self.bounds) - CGRectGetMidX(fullStar.bounds);
    CGFloat yOffset = CGRectGetMidY(self.bounds) - CGRectGetMidY(fullStar.bounds);
    
    fullStar.frame = CGRectOffset(fullStar.frame, xOffset, yOffset);
    fullStar.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    [self addSubview:fullStar];
    
    [UIView animateKeyframesWithDuration:animationDuration delay:delay options:0 animations:^{
        
        CGFloat ratio = 0.35;
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:ratio animations:^{
            fullStar.transform = CGAffineTransformMakeScale(animationScaleRatio, animationScaleRatio);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:ratio relativeDuration:1 - ratio animations:^{
            fullStar.transform = CGAffineTransformIdentity;
        }];
        
    } completion:^(BOOL finished) {
        
        if (self.isFull) {
            
            [self setImage:self.starImageFull forState:UIControlStateNormal];
            [self setTintColor:self.fullTintColor];
            
        }

        [fullStar removeFromSuperview];
        
    }];
    
}

@end




//-------------------------------------------------------------------------------


@interface RERatingControl ()

@property (nonatomic, strong) NSArray *stars;
@property (nonatomic ,assign, getter=isUpdating) BOOL updating;


@end


@implementation RERatingControl 


- (instancetype)initWithCoder:(NSCoder *)coder

{
    self = [super initWithCoder:coder];
    if (self) {
        
        [self commonInit];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self commonInit];
        
    }
    return self;
}

- (void)commonInit {
    
    _numberOfStars = 5;
    _updating = NO;
  
    [self setOpaque:NO];
    self.backgroundColor = [UIColor clearColor];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    if (self.numberOfStars < 1) {
        NSLog(@"RERatingControl: invalid number of stars");
        return;
    }
    
    
    if ((!self.starImageEmpty) || (!self.starImageFull)) {
        
        NSLog(@"RERatingControl: images are not set");
        return;
    }
    
    CGFloat starWidth = CGRectGetWidth(self.frame) / self.numberOfStars;
    CGRect frame = CGRectMake(0, 0, starWidth, CGRectGetHeight(self.frame));
    NSMutableArray *tempArray = [NSMutableArray new];
    
    
    for (NSInteger i = 0; i < self.numberOfStars; i++) {
        
        REStarButton *btn = [REStarButton buttonWithType:UIButtonTypeSystem];
        [btn setFrame:CGRectOffset(frame, starWidth * i, 0)];
        [btn setImage:self.starImageEmpty forState:UIControlStateNormal];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:btn];
        [tempArray addObject:btn];
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        btn.starImageEmpty = self.starImageEmpty;
        btn.starImageFull = self.starImageFull;
        btn.fullTintColor = self.fullTintColor;
        
    }
    
    self.stars = [NSArray arrayWithArray:tempArray];

    
}

- (void)buttonPressed:(id)sender {
    
    
//    static int touchNumber = 0;
//    NSLog(@"\nTouch number: %d", touchNumber);
//    touchNumber++;
    
    if (self.isUpdating) {
        
        return;
    }
    
    self.updating = YES;
    NSInteger index = [self.stars indexOfObject:sender];
    __block NSTimeInterval delay = 0;
    
    [self.stars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        REStarButton *btn = (REStarButton*)obj;

        if (idx <= index) {
            
            if (!btn.isFull) {
                
              //  NSLog(@"\nadding a star at index: %ld", (long)idx);
                [btn makeFullWithDelay:delay];
                delay += animationDelay;

            }
            
        } else {
            
            if (btn.isFull) {
                
             //   NSLog(@"\nremoving a star at index: %ld", (long)idx);
                [btn makeEmptyWithDelay:0];
            }
            
        }
        
    }];
    
    if ([self.delegate respondsToSelector:@selector(ratingDidChangeTo:)]) {
        
        [self.delegate ratingDidChangeTo:index + 1];
        
    }
    
    
    self.updating = NO;
    
}


@end

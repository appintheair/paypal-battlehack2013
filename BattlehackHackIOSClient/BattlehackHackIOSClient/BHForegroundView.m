//
//  BHForegroundView.m
//  BattlehackHackIOSClient
//
//  Created by Alex on 11/17/13.
//  Copyright (c) 2013 Empatika. All rights reserved.
//

#import "BHForegroundView.h"
#import <QuartzCore/QuartzCore.h>

@interface BHForegroundView()
{
    int test;
}

@property (nonatomic, retain) CAGradientLayer *gradient;

@end

@implementation BHForegroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        test = 0 ;
        self.gradient = [CAGradientLayer layer];
        _gradient.frame = self.bounds;
        _gradient.colors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithRed:0. green:255./255 blue:0. alpha:1.].CGColor,
                           (id)[UIColor colorWithRed:0. green:0./255 blue:0. alpha:1.].CGColor,
                           nil];
        _gradient.locations = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.7],
                              nil];
        [self.layer addSublayer:self.gradient];
        [NSTimer scheduledTimerWithTimeInterval:.01
                                         target:self
                                       selector:@selector(animateLayer)
                                       userInfo:nil
                                        repeats:YES];
    }
    return self;
}

- (void)animateLayer
{
    test = (test + 1) % 255;
    UIColor *topColor = [UIColor colorWithRed:0. green:(255. - test) / 255. blue:0. alpha:1.];
    UIColor *bottomColor = [UIColor colorWithRed:0. green:test  / 255. blue:0. alpha:1.];
    NSArray *newColors = [NSArray arrayWithObjects:
                          (id)topColor.CGColor,
                          (id)bottomColor.CGColor,
                          nil];
    [(CAGradientLayer *)[self.layer.sublayers firstObject] setColors:newColors];
}


@end

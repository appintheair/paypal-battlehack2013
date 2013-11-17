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
    UIColor *color1;
    UIColor *color2;
    UIColor *color3;
    UIImageView *_imageView;
    UIImageView *_backgroundView;
}

@property (nonatomic, retain) CAGradientLayer *gradient;

@end

@implementation BHForegroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.frame];
        [_imageView setImage:[UIImage imageNamed:@"splash.png"]];
        _backgroundView = [[UIImageView alloc] initWithFrame:self.frame];
        [_backgroundView setImage:[UIImage imageNamed:@"back.png"]];
        [self addSubview:_backgroundView];
        [self addSubview:_imageView];
    }
    return self;
}


@end

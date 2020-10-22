//
//  OTAnnotationToolbarView_Private.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTAnnotationScrollView.h"

@interface OTAnnotationToolbarView ()
- (instancetype)initWithFrame:(CGRect)frame
         annotationScrollView:(OTAnnotationScrollView *)annotationScrollView;

- (instancetype)initUniversalWithFrame:(CGRect)frame
                  annotationScrollView:(OTAnnotationScrollView *)annotationScrollView;
@end

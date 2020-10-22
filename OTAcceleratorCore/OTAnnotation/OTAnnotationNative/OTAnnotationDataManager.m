//
//  AnnotationManager.m
//
//  Copyright © 2016 Tokbox. All rights reserved.
//

#import "OTAnnotationDataManager.h"

@interface OTAnnotationDataManager()
@property (nonatomic) NSMutableArray<id<OTAnnotatable>> *mutableAnnotatable;
@property (nonatomic) id<OTAnnotatable> peakOfAnnotatable;
@property (nonatomic) id<OTAnnotatable> peakOfRemoteAnnotatable;
@end

@implementation OTAnnotationDataManager

- (NSArray<id<OTAnnotatable>> *)annotatable {
    return [_mutableAnnotatable copy];
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableAnnotatable = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addAnnotatable:(id<OTAnnotatable>)annotatable {
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(OTAnnotatable)]) return;
    [_mutableAnnotatable addObject:annotatable];
    
    if ([annotatable isMemberOfClass:[OTAnnotationPath class]] || [annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
        _peakOfAnnotatable = annotatable;
    }
    else if ([annotatable isMemberOfClass:[OTRemoteAnnotationPath class]] || [annotatable isMemberOfClass:[OTRemoteAnnotationTextView class]]) {
        _peakOfRemoteAnnotatable = annotatable;
    }
    [self annotatable];
}

- (id<OTAnnotatable>)pop {
    
    if (!_peakOfAnnotatable) return nil;
    
    // remove annotatable
    id popAnnotatable = _peakOfAnnotatable;
    [_mutableAnnotatable removeObject:_peakOfAnnotatable];
    
    [self resetPeakOfAnnotatable];

    return popAnnotatable;
}

- (id<OTAnnotatable>)popRemote {
    
    if (!_peakOfRemoteAnnotatable) return nil;
    
    // remove remote annotatable
    id popAnnotatable = _peakOfRemoteAnnotatable;
    [_mutableAnnotatable removeObject:_peakOfRemoteAnnotatable];
    
    [self resetPeakOfRemoteAnnotatable];
    
    return popAnnotatable;
}

- (void)remove:(id<OTAnnotatable>)annotatable {
    [_mutableAnnotatable removeObject:annotatable];
    [self resetPeakOfRemoteAnnotatable];
    [self annotatable];
}

- (BOOL)containsAnnotatable:(id<OTAnnotatable>)annotatable {
    if (!annotatable || ![annotatable conformsToProtocol:@protocol(OTAnnotatable)]) return NO;
    return [self.annotatable containsObject:annotatable];
}

- (void)resetPeakOfAnnotatable {
    // remove to the next peak
    NSUInteger index = _mutableAnnotatable.count - 1;
    while (index != NSUIntegerMax) {
        
        id<OTAnnotatable> annotatable = [_mutableAnnotatable objectAtIndex:index];
        if ([annotatable isMemberOfClass:[OTAnnotationPath class]] || [annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
            _peakOfAnnotatable = annotatable;
            break;
        }
        else {
            index -= 1;
        }
    }
    
    if (index == NSUIntegerMax) {
        _peakOfAnnotatable = nil;
    }
}

- (void)resetPeakOfRemoteAnnotatable {
    // remove to the next peak
    NSUInteger index = _mutableAnnotatable.count - 1;
    while (index != NSUIntegerMax) {
        
        id<OTAnnotatable> annotatable = [_mutableAnnotatable objectAtIndex:index];
        if ([annotatable isMemberOfClass:[OTRemoteAnnotationPath class]] || [annotatable isMemberOfClass:[OTRemoteAnnotationTextView class]]) {
            _peakOfRemoteAnnotatable = annotatable;
            break;
        }
        else {
            index -= 1;
        }
    }
    
    if (index == NSUIntegerMax) {
        _peakOfRemoteAnnotatable = nil;
    }
}

- (void)popAll {

    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    for (id annotatable in _mutableAnnotatable) {
        if ([annotatable isMemberOfClass:[OTAnnotationPath class]] || [annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
            [objectsToRemove addObject:annotatable];
            
            if ([annotatable isMemberOfClass:[OTAnnotationTextView class]]) {
                OTAnnotationTextView *textView = (OTAnnotationTextView *)annotatable;
                [textView removeFromSuperview];
            }
        }
    }
    [_mutableAnnotatable removeObjectsInArray:objectsToRemove];
    
    self.peakOfAnnotatable = nil;
    [self annotatable];
}

- (void)popRemoteAll {
    
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    for (id annotatable in _mutableAnnotatable) {
        if ([annotatable isMemberOfClass:[OTRemoteAnnotationPath class]] || [annotatable isMemberOfClass:[OTRemoteAnnotationTextView class]]) {
            [objectsToRemove addObject:annotatable];
            
            if ([annotatable isMemberOfClass:[OTRemoteAnnotationTextView class]]) {
                OTRemoteAnnotationTextView *textView = (OTRemoteAnnotationTextView *)annotatable;
                [textView removeFromSuperview];
            }
        }
    }
    
    [_mutableAnnotatable removeObjectsInArray:objectsToRemove];
    self.peakOfRemoteAnnotatable = nil;
    [self annotatable];
}

@end

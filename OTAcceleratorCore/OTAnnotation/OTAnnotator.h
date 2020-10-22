//
//  OTAnnotator.h
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OTAcceleratorCore/OTAcceleratorSession.h>
#import "OTAnnotationScrollView.h"

typedef NS_ENUM(NSUInteger, OTAnnotationSignal) {
    OTAnnotationSessionDidConnect = 0,
    OTAnnotationSessionDidDisconnect,
    OTAnnotationConnectionCreated,
    OTAnnotationConnectionDestroyed,
    OTAnnotationSessionDidBeginReconnecting,
    OTAnnotationSessionDidReconnect,
    OTAnnotationSessionDidFail
};

typedef void (^OTAnnotationBlock)(OTAnnotationSignal signal, NSError *error);

typedef void (^OTAnnotationDataSendingBlock)(NSArray *data, NSError * error);

typedef void (^OTAnnotationDataReceivingBlock)(NSArray *data);

@class OTAnnotator;

@protocol OTAnnotatorDataSource <NSObject>
- (OTAcceleratorSession *)sessionOfOTAnnotator:(OTAnnotator *)annotator;
@end


@protocol AnnotationDelegate <NSObject>

- (void)annotator:(OTAnnotator *)annotator
           signal:(OTAnnotationSignal)signal
            error:(NSError *)error;

- (void)annotator:(OTAnnotator *)annotator sendAnnotationWithData:(NSArray *)data error:(NSError *)error;

- (void)annotator:(OTAnnotator *)annotator receivedAnnotationData:(NSArray *)data;

@end

@interface OTAnnotator : NSObject

/**
 *  The object that acts as the data source of the text chat.
 *
 *  The delegate must adopt the OTAnnotatorDataSource protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<OTAnnotatorDataSource> dataSource;

/**
 *  Registers to the shared session: [OTAcceleratorSession] and connect.
 *
 *  @return An error to indicate whether it connects successfully, non-nil if it fails.
 */
- (NSError *)connect;

/**
 *  An alternative connect method with a completion block handler.
 *
 *  @param handler The completion handler to call with the change.
 */
- (void)connectWithCompletionHandler:(OTAnnotationBlock)handler;

/**
 *  De-registers to the shared session: [OTAcceleratorSession] and stops publishing/subscriber.
 *
 *  @return An error to indicate whether it disconnects successfully, non-nil if it fails.
 */
- (NSError *)disconnect;

/**
 *  The completion handler to call with the sending data.
 */
@property (copy, nonatomic) OTAnnotationDataSendingBlock dataSendingHandler;

/**
 *  The completion handler to call with the receiving data.
 */
@property (copy, nonatomic) OTAnnotationDataReceivingBlock dataReceivingHandler;

/**
 *  The object that acts as the delegate of the annotator.
 *
 *  The delegate must adopt the AnnotationDelegate protocol. The delegate is not retained.
 */
@property (weak, nonatomic) id<AnnotationDelegate> delegate;

/**
 *  The associated annotation scroll view.
 *
 *  @discussion This will be nil until OTAnnotationSessionDidConnect being signaled.
 *
 *  ******************************************************************************************
 *  The annotationScrollView.scrollView.contentSize is a critical data for remote annotation
 *  ******************************************************************************************
 */
@property (readonly, nonatomic) OTAnnotationScrollView *annotationScrollView;

@property (nonatomic) BOOL stopSendingAnnotation;

@property (nonatomic) BOOL stopReceivingAnnotation;

- (void)cleanRemoteCanvas;

#pragma mark - advanced
/**
 *  Manually subscribe to a stream with a specfieid name.
 *
 *  @return An error to indicate whether it subscribes successfully, non-nil if it fails.
 */
- (NSError *)subscribeToStreamWithName:(NSString *)name;

/**
 *  Manually subscribe to a stream with a specfieid stream id.
 *
 *  @return An error to indicate whether it subscribes successfully, non-nil if it fails.
 */
- (NSError *)subscribeToStreamWithStreamId:(NSString *)streamId;

@end

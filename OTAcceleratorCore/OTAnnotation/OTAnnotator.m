//
//  OTAnnotator.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

// defines for image scaling
// From https://bugs.chromium.org/p/webrtc/issues/detail?id=4643#c7 :
// Don't send any image larger than 1280px on either edge. Additionally, don't
// send any image with dimensions %16 != 0
#define MAX_EDGE_SIZE_LIMIT 1280.0f
#define EDGE_DIMENSION_COMMON_FACTOR 16.0f

#import <OTAcceleratorCore/OTAcceleratorSession.h>
#import "OTAnnotator.h"
#import "OTAnnotationToolbarView_UserInterfaces.h"
#import "UIColor+HexString.h"
#import "JSON.h"

@interface OTAnnotator() <OTSessionDelegate, OTAnnotationViewDelegate> {
    NSMutableDictionary *signalingPoint;
    NSMutableArray *signalingPoints;
    OTStream *latestScreenShareStream;
    
    NSMutableArray *ovalPoints;
}

@property (nonatomic) OTAnnotationScrollView *annotationScrollView;
@property (nonatomic) OTAcceleratorSession *session;
@property (strong, nonatomic) OTAnnotationBlock handler;

@end

@implementation OTAnnotator

- (void)setDataSource:(id<OTAnnotatorDataSource>)dataSource {
    _dataSource = dataSource;
    _session = [_dataSource sessionOfOTAnnotator:self];
}

- (NSError *)connect {
    if (!self.delegate && !self.handler) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eraseButtonPressed:) name:kOTAnnotationToolbarDidPressEraseButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanButtonPressed:) name:kOTAnnotationToolbarDidPressCleanButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidAdd:) name:kOTAnnotationToolbarDidAddTextAnnotation object:nil];
    return [self.session registerWithAccePack:self];
}

- (void)connectWithCompletionHandler:(OTAnnotationBlock)handler {
    self.handler = handler;
    [self connect];
}

- (NSError *)disconnect {
    if (self.annotationScrollView) {
        [self.annotationScrollView.annotationView removeAllAnnotatables];
        [self.annotationScrollView.annotationView removeAllRemoteAnnotatables];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return [self.session deregisterWithAccePack:self];
}

- (void)notifiyAllWithSignal:(OTAnnotationSignal)signal error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, error);
    }
    
    if (self.delegate) {
        [self.delegate annotator:self signal:signal error:error];
    }
}

- (void) sessionDidConnect:(OTSession *)session {
    
    self.annotationScrollView = [[OTAnnotationScrollView alloc] init];
    self.annotationScrollView.scrollView.contentSize = self.annotationScrollView.bounds.size;
    self.annotationScrollView.annotationView.annotationViewDelegate = self;
    [self notifiyAllWithSignal:OTAnnotationSessionDidConnect
                         error:nil];
}

- (void) sessionDidDisconnect:(OTSession *)session {
    self.annotationScrollView = nil;
    
    [self notifiyAllWithSignal:OTAnnotationSessionDidDisconnect
                         error:nil];
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    if (stream.videoType == OTStreamVideoTypeScreen) {
        latestScreenShareStream = stream;
    }
    
    if (!latestScreenShareStream) {
        latestScreenShareStream = stream;
    }
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    if ([latestScreenShareStream.streamId isEqualToString:stream.streamId]) {
        latestScreenShareStream = nil;
    }
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTAnnotationSessionDidFail
                         error:error];
}

- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection {
    [self notifiyAllWithSignal:OTAnnotationConnectionCreated
                         error:nil];
}

- (void)session:(OTSession *)session connectionDestroyed:(OTStream *)stream {
    [self notifiyAllWithSignal:OTAnnotationConnectionDestroyed
                         error:nil];
}

- (void)sessionDidBeginReconnecting:(OTSession *)session {
    [self notifiyAllWithSignal:OTAnnotationSessionDidBeginReconnecting
                         error:nil];
}

- (void)sessionDidReconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTAnnotationSessionDidReconnect
                         error:nil];
}

- (void)cleanRemoteCanvas {
    [self cleanButtonPressed:nil];
}

// OPENTOK SIGNALING
- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
    
    if (self.stopReceivingAnnotation) return;
    
    // TODO for the next person who sees this: a workaround for making the web annotation work
    if ([type isEqualToString:@"otAnnotation_requestPlatform"]) {
        [self.session signalWithType:@"otAnnotation_mobileScreenShare" string:[JSON stringify:@{@"platform":@"ios"}] connection:nil error:nil];
        return;
    }
        
    if (![type isEqualToString:@"otAnnotation_pen"] &&
        ![type isEqualToString:@"otAnnotation_text"] &&
        ![type isEqualToString:@"otAnnotation_undo"] &&
        ![type isEqualToString:@"otAnnotation_clear"]) {
        
        return;
    }

    if (self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected &&
        ![self.session.connection.connectionId isEqualToString:connection.connectionId]) {
        
        // make sure contentSize is up-to-date
//        self.annotationScrollView.scrollView.contentSize = self.annotationScrollView.bounds.size;
        
        NSArray *jsonArray = [JSON parseJSON:string];
        
        // notify receving data
        if (self.dataReceivingHandler) {
            self.dataReceivingHandler(jsonArray);
        }
        
        if (self.delegate) {
            [self.delegate annotator:self receivedAnnotationData:jsonArray];
        }
        
        if ([type isEqualToString:@"otAnnotation_undo"]) {
            
            if (jsonArray.count == 1 && [jsonArray.firstObject isEqual:[NSNull null]]) {
                [self.annotationScrollView.annotationView removeRemoteAnnotatableWithGUID:nil];
                return;
            }
            
            for (NSString *guid in jsonArray) {
                [self.annotationScrollView.annotationView removeRemoteAnnotatableWithGUID:guid];
            }
            return;
        }
        
        if ([type isEqualToString:@"otAnnotation_clear"]) {
            [self.annotationScrollView.annotationView removeAllRemoteAnnotatables];
            return;
        }
        
        if (jsonArray.count == 0) return;
        
        // draw text
        if ([type isEqualToString:@"otAnnotation_text"] && jsonArray.count == 1) {
            [self drawText:[jsonArray firstObject]];
            return;
        }
        
        // set path attributes
        NSDictionary *firstJsonObject = [jsonArray firstObject];
        if (firstJsonObject[@"color"] && firstJsonObject[@"guid"] && firstJsonObject[@"lineWidth"]) {
            NSString *remoteGUID = firstJsonObject[@"guid"];
            UIColor *drawingColor = [UIColor colorFromHexString:[jsonArray firstObject][@"color"]];
            CGFloat lineWidth = [[jsonArray firstObject][@"lineWidth"] floatValue];
            
            self.annotationScrollView.annotationView.remoteAnnotatable = [[OTRemoteAnnotationPath alloc] initWithStrokeColor:drawingColor
                                                                                                                   remoteGUID:remoteGUID];
            OTRemoteAnnotationPath *currentPath = (OTRemoteAnnotationPath *)self.annotationScrollView.annotationView.currentAnnotatable;
            currentPath.lineWidth = lineWidth;
        }
        else {
            self.annotationScrollView.annotationView.remoteAnnotatable = [[OTRemoteAnnotationPath alloc] initWithStrokeColor:nil];
        }
        
        // draw oval
        if ([jsonArray.lastObject isKindOfClass:[NSDictionary class]] && [jsonArray.lastObject[@"selectedItem"][@"id"] isEqualToString:@"OT_oval"]) {
            
            if (!ovalPoints) {
                ovalPoints = [NSMutableArray arrayWithCapacity:10];
            }
            
            [ovalPoints addObjectsFromArray:jsonArray];
            
            // this is a workaround because an oval data array is composed by two signals. one has seven elements and another has three elements. 
            if (ovalPoints.count == 10) {
                jsonArray = [NSArray arrayWithArray:ovalPoints];
                ovalPoints = nil;
            }
            else {
                return;
            }
        }
        
        // calculate drawing position
        for (NSDictionary *json in jsonArray) {
            
            // this is the unique property from web
            NSString *platform = json[@"platform"];
            if (platform && [platform isEqualToString:@"web"]) {
                [self drawOnFitModeWithJson:json path:(OTRemoteAnnotationPath *)self.annotationScrollView.annotationView.remoteAnnotatable];
                continue;
            }
            
            // the size of remote canvas(same with the ss size)
            CGFloat remoteCanvasWidth = [json[@"canvasWidth"] floatValue];
            CGFloat remoteCanvasHeight = [json[@"canvasHeight"] floatValue];
            
            // video W/H(width/height produced by the core codes of SS and Opentok)
            CGFloat videoWidth = [json[@"videoWidth"] floatValue];
            CGFloat videoHeight = [json[@"videoHeight"] floatValue];
            
            // the size of the current canvas
            CGFloat thisCanvasWidth = CGRectGetWidth(self.annotationScrollView.annotationView.bounds);
            CGFloat thisCanvasHeight = CGRectGetHeight(self.annotationScrollView.annotationView.bounds);
            
            // the aspect ratio of the remote/current canvas
            CGFloat remoteCanvasAspectRatio = remoteCanvasWidth / remoteCanvasHeight;
            CGFloat thisCanvasAspectRatio = thisCanvasWidth / thisCanvasHeight;

            if ((remoteCanvasWidth == videoWidth && remoteCanvasHeight == videoHeight) || thisCanvasAspectRatio == remoteCanvasAspectRatio) {
                // draw on the fill mode or on the same aspect ratio
                [self drawOnFillModeWithJson:json path:(OTRemoteAnnotationPath *)self.annotationScrollView.annotationView.remoteAnnotatable];
            }
            else {
                // draw on irregular aspect ratio
                [self drawOnFitModeWithJson:json path:(OTRemoteAnnotationPath *)self.annotationScrollView.annotationView.remoteAnnotatable];
            }
        }
    }
}

- (void)eraseButtonPressed:(NSNotification *)notification {
    
    if (!notification || !notification.object || !latestScreenShareStream) return;

    NSString *jsonString;
    
    if ([notification.userInfo[@"annotation"] isMemberOfClass:[OTAnnotationPath class]] ) {
        OTAnnotationPath *path = (OTAnnotationPath *)notification.userInfo[@"annotation"];
        jsonString = [JSON stringify:@[path.uuid]];
    }
    else if ([notification.userInfo[@"annotation"] isMemberOfClass:[OTAnnotationTextView class]]) {
        jsonString = [JSON stringify:@[[NSNull null]]];
    }
    
    if (jsonString) {
        NSError *error;
        [self.session signalWithType:@"otAnnotation_undo" string:jsonString connection:latestScreenShareStream.connection error:&error];
        if (error) {
            NSLog(@"remoteEraseButtonPressed: %@", error);
        }
    }
}

- (void)cleanButtonPressed:(NSNotification *)notification {
    
    if (!latestScreenShareStream) return;
    
    NSError *error;
    [self.session signalWithType:@"otAnnotation_clear" string:nil connection:latestScreenShareStream.connection error:&error];
    if (error) {
        NSLog(@"remoteCleanButtonPressed: %@", error);
    }
}

- (void)textDidAdd:(NSNotification *)notification {
    
    if (!latestScreenShareStream) return;
    if (![notification.userInfo[@"annotation"] isMemberOfClass:[OTAnnotationTextView class]]) return;
    
    OTAnnotationTextView *textView = (OTAnnotationTextView *)notification.userInfo[@"annotation"];
    NSDictionary *data = @{
                           @"id": latestScreenShareStream.connection.connectionId,
                           @"fromId": self.session.connection.connectionId,
                           @"fromX": @(textView.frame.origin.x),
                           @"fromY": @(textView.frame.origin.y),
                           @"videoWidth": @(latestScreenShareStream.videoDimensions.width),
                           @"videoHeight": @(latestScreenShareStream.videoDimensions.height),
                           @"canvasWidth": @(self.annotationScrollView.scrollView.contentSize.width),
                           @"canvasHeight": @(self.annotationScrollView.scrollView.contentSize.height),
                           @"mirrored": @(NO),
                           @"platform": @"ios",
                           @"text": textView.text,
                           @"color": [UIColor hexStringFromColor:textView.textColor],
                           @"font": [NSString stringWithFormat:@"%@px Arial", @(textView.font.pointSize * [UIScreen mainScreen].scale)]
                           };
    NSError *error;
    NSString *jsonString = [JSON stringify:@[data]];
    
    [self.session signalWithType:@"otAnnotation_text" string:jsonString connection:latestScreenShareStream.connection error:&error];
    if (error) {
        NSLog(@"remoteCleanButtonPressed: %@", error);
    }
}

- (void)drawText:(NSDictionary *)json {
    
    CGFloat remoteCanvasWidth = [json[@"canvasWidth"] floatValue];
    CGFloat remoteCanvasHeight = [json[@"canvasHeight"] floatValue];
    CGFloat thisCanvasWidth = CGRectGetWidth(self.annotationScrollView.annotationView.bounds);
    CGFloat thisCanvasHeight = CGRectGetHeight(self.annotationScrollView.annotationView.bounds);
    
    // apply scale factor
    // Based on this: http://www.iosres.com/index-legacy.html
    // iPhone 4&4s aspect ratio is 3:2 = 0.666
    // iPhone 5&5s&6&6s aspect ratio is 16:9 = 0.5625
    // iPad aspect ratio is 4:3 = 0.75
    
    CGFloat scale = 1.0f;
    if (thisCanvasWidth < thisCanvasHeight || remoteCanvasWidth < remoteCanvasHeight) {
        scale = thisCanvasHeight / remoteCanvasHeight;
    }
    else {
        scale = thisCanvasWidth / remoteCanvasWidth;
    }
    
    remoteCanvasWidth *= scale;
    remoteCanvasHeight *= scale;
    
    // remote x and y
    CGFloat fromX = [json[@"fromX"] floatValue] * scale;
    CGFloat fromY = [json[@"fromY"] floatValue] * scale;
    
    OTAnnotationPoint *pt;
    
    if (thisCanvasWidth < thisCanvasHeight || remoteCanvasWidth < remoteCanvasHeight) {
        
        // letter boxing is produced on horizontal level
        CGFloat actualDrawingFromX = fromX - (remoteCanvasWidth / 2 - self.annotationScrollView.annotationView.center.x);
        pt = [OTAnnotationPoint pointWithX:actualDrawingFromX andY:fromY];
    }
    else {
        
        // letter boxing is produced on vertical level
        CGFloat actualDrawingFromY = fromY - (remoteCanvasHeight / 2 - self.annotationScrollView.annotationView.center.y);
        pt = [OTAnnotationPoint pointWithX:fromX andY:actualDrawingFromY];
    }

    CGPoint cgPt = [pt cgPoint];
    NSString *text = json[@"text"];
    UIColor *color = [UIColor colorFromHexString:json[@"color"]];
    
    NSString *fontSizeString = json[@"font"];
    NSArray *fontSizeStringArray = [fontSizeString componentsSeparatedByString:@" "];
    NSUInteger fontSize = [[fontSizeStringArray firstObject] integerValue];
    
    if (!text || !color || !fontSizeString || !fontSizeStringArray || fontSizeStringArray.count != 2) return;
    
    OTRemoteAnnotationTextView *annotationTextView = [[OTRemoteAnnotationTextView alloc] initWithText:text
                                                                                            textColor:color
                                                                                             fontSize:fontSize * scale];
    
    // add text annotation
    [self.annotationScrollView addContentView:annotationTextView];
    [self.annotationScrollView addTextAnnotation:annotationTextView];
    [annotationTextView commit];
    
    // reset position
    annotationTextView.frame = CGRectMake(cgPt.x,
                                          cgPt.y,
                                          CGRectGetWidth(annotationTextView.bounds),
                                          CGRectGetHeight(annotationTextView.bounds));
    [annotationTextView sizeToFit];
}

- (void)drawOnFillModeWithJson:(NSDictionary *)json
                          path:(OTRemoteAnnotationPath *)path {
    
    CGFloat remoteCanvasWidth = [json[@"canvasWidth"] floatValue];
    CGFloat remoteCanvasHeight = [json[@"canvasHeight"] floatValue];
    CGFloat xScaleFactor = self.annotationScrollView.bounds.size.width / remoteCanvasWidth;
    CGFloat yScaleFactor = self.annotationScrollView.bounds.size.height / remoteCanvasHeight;
    
    CGFloat fromX = [json[@"fromX"] floatValue] * xScaleFactor;
    CGFloat fromY = [json[@"fromY"] floatValue] * yScaleFactor;
    CGFloat toX = [json[@"toX"] floatValue] * xScaleFactor;
    CGFloat toY = [json[@"toY"] floatValue] * yScaleFactor;
    
    OTAnnotationPoint *pt1 = [OTAnnotationPoint pointWithX:fromX andY:fromY];
    OTAnnotationPoint *pt2 = [OTAnnotationPoint pointWithX:toX andY:toY];
    
    if ([json[@"smoothed"] boolValue]) {

        [path drawCurveFrom:pt1 to:pt2];

        if ([json[@"endPoint"] boolValue]) {
            [path drawToPoint:pt2];
        }
    }
    else {
        if (path.points.count == 0) {
            [path startAtPoint:pt1];
            [path drawToPoint:pt2];
        }
        else {
            [path drawToPoint:pt1];
            [path drawToPoint:pt2];
        }
    }
}

// this method is always work when web annotations as a subscriber
- (void)drawOnFitModeWithJson:(NSDictionary *)json
                         path:(OTRemoteAnnotationPath *)path {
    
    CGFloat remoteCanvasWidth = [json[@"canvasWidth"] floatValue];
    CGFloat remoteCanvasHeight = [json[@"canvasHeight"] floatValue];
    CGFloat thisCanvasWidth = CGRectGetWidth(self.annotationScrollView.annotationView.bounds);
    CGFloat thisCanvasHeight = CGRectGetHeight(self.annotationScrollView.annotationView.bounds);
    
    // apply scale factor
    // Based on this: http://www.iosres.com/index-legacy.html
    // iPhone 4&4s aspect ratio is 3:2 = 0.666
    // iPhone 5&5s&6&6s aspect ratio is 16:9 = 0.5625
    // iPad aspect ratio is 4:3 = 0.75
    
    CGFloat scale = 1.0f;
    if (thisCanvasWidth < thisCanvasHeight || remoteCanvasWidth < remoteCanvasHeight) {
        scale = thisCanvasHeight / remoteCanvasHeight;
    }
    else {
        scale = thisCanvasWidth / remoteCanvasWidth;
    }

    remoteCanvasWidth *= scale;
    remoteCanvasHeight *= scale;
    
    // remote x and y
    CGFloat fromX = [json[@"fromX"] floatValue] * scale;
    CGFloat fromY = [json[@"fromY"] floatValue] * scale;
    CGFloat toX = [json[@"toX"] floatValue] * scale;
    CGFloat toY = [json[@"toY"] floatValue] * scale;
    
    OTAnnotationPoint *pt1;
    OTAnnotationPoint *pt2;
    
    if (thisCanvasWidth < thisCanvasHeight || remoteCanvasWidth < remoteCanvasHeight) {
        
        // letter boxing is produced on horizontal level
        CGFloat actualDrawingFromX = fromX - (remoteCanvasWidth / 2 - self.annotationScrollView.annotationView.center.x);
        CGFloat actualDrawingToX = toX - (remoteCanvasWidth / 2 - self.annotationScrollView.annotationView.center.x);
        pt1 = [OTAnnotationPoint pointWithX:actualDrawingFromX andY:fromY];
        pt2 = [OTAnnotationPoint pointWithX:actualDrawingToX andY:toY];
    }
    else {
        
        // letter boxing is produced on vertical level
        CGFloat actualDrawingFromY = fromY - (remoteCanvasHeight / 2 - self.annotationScrollView.annotationView.center.y);
        CGFloat actualDrawingToY = toY - (remoteCanvasHeight / 2 - self.annotationScrollView.annotationView.center.y);
        pt1 = [OTAnnotationPoint pointWithX:fromX andY:actualDrawingFromY];
        pt2 = [OTAnnotationPoint pointWithX:toX andY:actualDrawingToY];
    }
    
    if ([json[@"smoothed"] boolValue]) {

        [path drawCurveFrom:pt1 to:pt2];

        if ([json[@"endPoint"] boolValue]) {
            [path drawToPoint:pt2];
        }
    }
    else {
        if (path.points.count == 0) {
            [path startAtPoint:pt1];
            [path drawToPoint:pt2];
        }
        else {
            [path drawToPoint:pt1];
            [path drawToPoint:pt2];
        }
    }
}

#pragma mark - OTAnnotationViewDelegate

- (void)annotationView:(OTAnnotationView *)annotationView
            touchBegan:(UITouch *)touch
             withEvent:(UIEvent *)event {
    
    if (self.stopSendingAnnotation) return;
    
    signalingPoints = [[NSMutableArray alloc] init];
    
    // update this to ensure color property is not affected by remote annotation data
    if (self.annotationScrollView.toolbarView) {
        OTAnnotationPath *path = (OTAnnotationPath *)self.annotationScrollView.annotationView.currentAnnotatable;
        path.strokeColor = self.annotationScrollView.toolbarView.colorPickerView.selectedColor;
    }
    
    [self signalAnnotatable:annotationView.currentAnnotatable
                     touch:touch
             addtionalInfo:@{@"startPoint":@(YES), @"endPoint":@(NO)}];
}

- (void)annotationView:(OTAnnotationView *)annotationView
            touchMoved:(UITouch *)touch
             withEvent:(UIEvent *)event {
    
    if (self.stopSendingAnnotation) return;
    
    if (!signalingPoints) {
        signalingPoints = [[NSMutableArray alloc] init];
    }
    
    [self signalAnnotatable:annotationView.currentAnnotatable
                     touch:touch
             addtionalInfo:@{@"startPoint":@(NO), @"endPoint":@(NO)}];

    if (self.dataReceivingHandler) {
        self.dataReceivingHandler(signalingPoints);
    }

    if (self.delegate) {
        [self.delegate annotator:self receivedAnnotationData:signalingPoints];
    }
}

- (void)annotationView:(OTAnnotationView *)annotationView
            touchEnded:(UITouch *)touch
             withEvent:(UIEvent *)event {
    
    if (self.stopSendingAnnotation) return;
    
    if (signalingPoint) {
        [self signalAnnotatable:annotationView.currentAnnotatable
                         touch:touch
                 addtionalInfo:@{@"startPoint":@(NO), @"endPoint":@(YES)}];  // the `endPoint` is not `NO` here because web does not recognize it, we can change this later.
    }
    else {
        NSMutableDictionary *lastPoint = (NSMutableDictionary *)[signalingPoints lastObject];
        lastPoint[@"startPoint"] = @(NO);
        lastPoint[@"endPoint"] = @(YES);
    }
    
    //Need this condition strictly for drawing straight lines
    if (signalingPoints.count == 1) {
        NSMutableDictionary *lastPoint = (NSMutableDictionary *)[signalingPoints lastObject];
        lastPoint[@"endPoint"] = @(YES);
    }

    NSError *error;
    NSString *jsonString = [JSON stringify:signalingPoints];
    [self.session signalWithType:@"otAnnotation_pen" string:jsonString connection:nil error:&error];
    
    // notify sending data
    if (self.dataReceivingHandler) {
        self.dataReceivingHandler(signalingPoints);
    }
    
    if (self.delegate) {
        [self.delegate annotator:self receivedAnnotationData:signalingPoints];
    }
    
    [signalingPoints addObject:touch];

    signalingPoints = nil;
}

- (void)signalAnnotatable:(id<OTAnnotatable>)annotatable
                   touch:(UITouch *)touch
           addtionalInfo:(NSDictionary *)info {
    
    if ([annotatable isKindOfClass:[OTAnnotationPath class]]) {
        
        CGPoint touchPoint = [touch locationInView:touch.view];
        if (!signalingPoint) {
            
            OTAnnotationPath *path = (OTAnnotationPath *)self.annotationScrollView.annotationView.currentAnnotatable;
            
            signalingPoint = [NSMutableDictionary dictionaryWithDictionary:info];
            signalingPoint[@"id"] = latestScreenShareStream.connection.connectionId;    // receiver id
            signalingPoint[@"platform"] = @"ios";
            signalingPoint[@"fromId"] = self.session.connection.connectionId;   // sender id
            signalingPoint[@"fromX"] = @(touchPoint.x);
            signalingPoint[@"fromY"] = @(touchPoint.y);
            signalingPoint[@"videoWidth"] = @(latestScreenShareStream.videoDimensions.width);
            signalingPoint[@"videoHeight"] = @(latestScreenShareStream.videoDimensions.height);
            signalingPoint[@"canvasWidth"] = @(self.annotationScrollView.scrollView.contentSize.width);
            signalingPoint[@"canvasHeight"] = @(self.annotationScrollView.scrollView.contentSize.height);
            signalingPoint[@"lineWidth"] = @(path.lineWidth * [UIScreen mainScreen].scale);
            signalingPoint[@"mirrored"] = @(NO);
            signalingPoint[@"guid"] = path.uuid;
            signalingPoint[@"smoothed"] = @(YES);    // this is to enable drawing smoothly
            signalingPoint[@"color"] = [UIColor hexStringFromColor:path.strokeColor];
        }
        else {
            signalingPoint[@"toX"] = @(touchPoint.x);
            signalingPoint[@"toY"] = @(touchPoint.y);
            [signalingPoints addObject:signalingPoint];
            signalingPoint = nil;
        }
    }
}

#pragma mark - advanced
- (NSError *)subscribeToStreamWithName:(NSString *)name {
    for (OTStream *stream in self.session.streams.allValues) {
        if ([stream.name isEqualToString:name]) {
            latestScreenShareStream = stream;
        }
    }
    
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is no such stream with name: %@", name]}];
}

- (NSError *)subscribeToStreamWithStreamId:(NSString *)streamId {
    for (OTStream *stream in self.session.streams.allValues) {
        if ([stream.streamId isEqualToString:streamId]) {
            latestScreenShareStream = stream;
        }
    }
    
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is no such stream with streamId: %@", streamId]}];
}

@end

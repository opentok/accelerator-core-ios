//
//  OTTextChatter.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextChat.h"

#import <OTKAnalytics/OTKLogger.h>

#import "OTTextMessage.h"
#import "OTTextMessage_Private.h"

#import "Constant.h"

static NSString* const kTextChatType = @"text-chat";

@interface OTTextChat() <OTSessionDelegate>

@property (nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTKLogger *logger;
@property (nonatomic) OTConnection *selfConnection;

@property (copy, nonatomic) OTTextChatConnectionBlock connectionHandler;
@property (copy, nonatomic) OTTextChatMessageBlock messageHandler;

@end

@implementation OTTextChat

- (void)setDataSource:(id<OTTextChatDataSource>)dataSource {
    _dataSource = dataSource;
    _session = [_dataSource sessionOfOTTextChat:self];
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                    source:[[NSBundle mainBundle] bundleIdentifier]
                                               componentId:kLogComponentIdentifier
                                                      guid:[[NSUUID UUID] UUIDString]];
        [_logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)connect {
    
    [_logger logEventAction:KLogActionStart
                  variation:KLogVariationAttempt
                 completion:nil];
    
    NSError *connectionError = [self.session registerWithAccePack:self];
    if(connectionError){
        
        [_logger logEventAction:KLogActionStart
                      variation:KLogVariationFailure
                     completion:nil];
        
        if (self.connectionHandler) {
            self.connectionHandler(OTTextChatConnectionEventSignalDidConnect, nil, connectionError);
        }
    }
    else {
        
        [_logger logEventAction:KLogActionStart
                      variation:KLogVariationSuccess
                     completion:nil];
    }
}

- (void)connectWithHandler:(OTTextChatConnectionBlock)handler
            messageHandler:(OTTextChatMessageBlock)messageHandler
{
    self.connectionHandler = handler;
    self.messageHandler = messageHandler;
    [self connect];
}

- (void)disconnect {
    
    [self.logger logEventAction:KLogActionEnd
                      variation:KLogVariationAttempt
                     completion:nil];
    
    NSError *disconnectionError = [self.session deregisterWithAccePack:self];
    if(disconnectionError){
        
        [self.logger logEventAction:KLogActionEnd
                          variation:KLogVariationFailure
                         completion:nil];
        
        if (self.connectionHandler) {
            self.connectionHandler(OTTextChatConnectionEventSignalDidDisconnect, nil, disconnectionError);
        }
    }
    else {
        
        [self.logger logEventAction:KLogActionEnd
                          variation:KLogVariationSuccess
                         completion:nil];
    }
}

- (void)sendMessage:(NSString *)text {
    [self sendCustomMessage:[OTTextMessage messageWithSenderId:self.selfConnection.connectionId alias:self.alias text:text]];
}

- (void)sendMessage:(NSString *)text
       toConnection:(OTConnection *)connection {
    [self sendCustomMessage:[OTTextMessage messageWithSenderId:self.selfConnection.connectionId alias:self.alias text:text] toConnection:nil];
}

- (void)sendCustomMessage:(OTTextMessage *)textMessage {
    [self sendCustomMessage:textMessage toConnection:nil];
}

- (void)sendCustomMessage:(OTTextMessage *)textMessage
             toConnection:(OTConnection *)connection {
    
    NSError *error;
    
    [self.logger logEventAction:KLogActionSendMessage variation:KLogVariationAttempt completion:nil];
    
    if (!textMessage.text || !textMessage.text.length) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Message format is wrong. Text is empty or null"}];
        
        if (self.messageHandler) {
            self.messageHandler(OTTextChatMessageEventSignalDidSendMessage, nil, error);
        }
        
        [self.logger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
        return;
    }
    
    if (self.session.sessionId) {
        
        NSString *jsonString = [textMessage getTextChatSignalJSONString];
        if (!jsonString) {
            
            if (self.messageHandler) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:-1
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Error in parsing sender data"}];
                self.messageHandler(OTTextChatMessageEventSignalDidSendMessage, nil, error);
            }
            
            [self.logger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
            return;
        }
        
        [self.session signalWithType:kTextChatType
                              string:jsonString
                          connection:connection
                               error:&error];
        
        if (error) {
            
            [self.logger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
            if (self.messageHandler) {
                self.messageHandler(OTTextChatMessageEventSignalDidSendMessage, nil, error);
            }
            return;
        }
        
        [self.logger logEventAction:KLogActionSendMessage variation:KLogVariationSuccess completion:nil];
        
        if (self.messageHandler) {
            self.messageHandler(OTTextChatMessageEventSignalDidSendMessage, textMessage, nil);
        }
    }
    else {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"OTSession did not connect"}];
        
        [self.logger logEventAction:KLogActionSendMessage variation:KLogVariationFailure completion:nil];
        
        if (self.messageHandler) {
            self.messageHandler(OTTextChatMessageEventSignalDidSendMessage, nil, error);
        }
    }
}

#pragma mark - OTSessionDelegate
- (void)sessionDidConnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidConnect");
    
    [_logger setSessionId:session.sessionId connectionId:session.connection.connectionId partnerId:@([self.session.apiKey integerValue])];
    
    self.selfConnection = session.connection;
    
    if (self.connectionHandler) {
        self.connectionHandler(OTTextChatConnectionEventSignalDidConnect, nil, nil);
    }
}

- (void)sessionDidDisconnect:(OTSession*)session {
    
    NSLog(@"TextChatComponent sessionDidDisconnect");
    
    if (self.connectionHandler) {
        self.connectionHandler(OTTextChatConnectionEventSignalDidDisconnect, nil, nil);
    }
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"didFailWithError: (%@)", error);
    
    if (self.connectionHandler) {
        self.connectionHandler(OTTextChatConnectionEventSignalDidConnect, nil, error);
    }
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {}
- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream{}

- (void)session:(OTSession*) session connectionCreated:(OTConnection*)connection {
    
    OTConnection *textChatConnection = session.connection;
    
    if (self.connectionHandler) {
        self.connectionHandler(OTTextChatConnectionEventSignalConnectionCreated, textChatConnection, nil);
    }
}

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection {
    
    OTConnection *textChatConnection = session.connection;
    
    if (self.connectionHandler) {
        self.connectionHandler(OTTextChatConnectionEventSignalConnectionDestroyed, textChatConnection, nil);
    }
}

- (void)session:(OTSession*)session
receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
    
    if (![type isEqualToString:kTextChatType]) return;
    
    if (![connection.connectionId isEqualToString:self.session.connection.connectionId]) {
        
        [self.logger logEventAction:KLogActionReceiveMessage variation:KLogVariationAttempt completion:nil];
        
        OTTextMessage *textMessage = [[OTTextMessage alloc] initWithJSONString:string];
        
        if (textMessage) {
            
            if (self.messageHandler) {
                self.messageHandler(OTTextChatMessageEventSignalDidReceiveMessage, textMessage, nil);
            }
            
            [self.logger logEventAction:KLogActionReceiveMessage variation:KLogVariationSuccess completion:nil];
        }
        else {
            
            [self.logger logEventAction:KLogActionReceiveMessage variation:KLogVariationFailure completion:nil];
        }
    }
}

@end

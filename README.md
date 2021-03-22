# Accelerator Core iOS

[![Build Status](https://travis-ci.org/opentok/accelerator-core-ios.svg?branch=main)](https://travis-ci.org/opentok/accelerator-core-ios)
[![Version Status](https://img.shields.io/cocoapods/v/OTAcceleratorCore.svg)](https://cocoapods.org/pods/OTAcceleratorCore)
[![license MIT](https://img.shields.io/cocoapods/l/OTAcceleratorCore.svg)](https://cocoapods.org/pods/OTAcceleratorCore)
[![Platform](https://img.shields.io/cocoapods/p/OTAcceleratorCore.svg)](https://cocoapods.org/pods/OTAcceleratorCore)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

<img src="https://assets.tokbox.com/img/vonage/Vonage_VideoAPI_black.svg" height="48px" alt="Tokbox is now known as Vonage" />

The Accelerator Core is a solution to integrate audio/video communication to any iOS applications via OpenTok platform. [Accelerator TextChat](https://github.com/opentok/accelerator-textchat-ios) and [Accelerator Annotation](https://github.com/opentok/accelerator-annotation-ios) have been deprecated and are now part of Accelerator Core.

Accelerator Core helps you with:

Core:
- one to one audio/video call
- multiparty audio/video call
- one to one screen sharing
- multiparty screen sharing
- UI components for handling audio/video enable&disable

TextChat:
- one to one text chat

Annotation:
- one to one audio/video call with annotations

# Configure, build and run the sample apps

The Accelerator Core workspace contains 3 sample apps, one for the Core, TextChat and Annotation components.

1. Get values for **API Key**, **Session ID**, and **Token**. See [Obtaining OpenTok Credentials](#obtaining-opentok-credentials) for important information.

1. Install CocoaPods as described in [CocoaPods Getting Started](https://guides.cocoapods.org/using/getting-started.html#getting-started).

1. In Terminal, `cd` to your project directory and type `pod install`.

1. Reopen your project in Xcode using the new `*.xcworkspace` file.

1. Replace the following empty strings with the corresponding API Key, Session ID, and Token values:

    ```objc
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Override point for customization after application launch.
        sharedSession = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:@"apikey" sessionId:@"sessionid" token:@"token"];
        return YES;
    }
    ```

1. Use Xcode to build and run the app on an iOS simulator or device.

1. For testing audio/video communication, we include a simple web app to make it easier: [Browser-Demo](https://github.com/opentok/accelerator-core-ios/blob/master/browser-demo.html). Simply open it and replace the corresponding API Key, Session ID, and Token values. Then save and load it to the browser. For multiparty, you can achieve by opening up multiple tabs.

1. You might want to run on other platforms:

[Accelerator Core Javascript](https://github.com/opentok/accelerator-core-js)

[Accelerator Core Android](https://github.com/opentok/accelerator-core-android)

## Core Sample Code

Each communicator instance will take the OpenTok session from OTOneToOneCommunicatorDataSource, so this applies to each communicator instance:

- Passing the session
    ```objc
    - (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
        return <#OTAcceleratorSession#>;
    }
    ```

- One-to-One

    ```objc
    self.communicator = [[OTOneToOneCommunicator alloc] init];
    self.communicator.dataSource = self;
    [self.communicator connectWithHandler:^(OTCommunicationSignal signal, NSError *error) {
        if (signal == OTPublisherCreated && !error) {
            weakSelf.communicator.publisherView.frame = CGRectMake(0, 0, 100, 100);
            [self.publisherView addSubview:weakSelf.communicator.publisherView];
        }
        else if (signal == OTSubscriberReady && !error) {
            weakSelf.communicator.subscriberView.frame = CGRectMake(0, 0, 100, 100);
            [self.subscriberView addSubview:weakSelf.communicator.subscriberView];
        }
    }];
    ```

- Multiparty

    ```objc
    self.communicator = [[OTMultiPartyCommunicator alloc] init];
    self.communicator.dataSource = self;
    [self.communicator connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
        if (signal == OTPublisherCreated && !error) {
            weakSelf.communicator.publisherView.frame = CGRectMake(0, 0, 100, 100);
            [self.publisherView addSubview:weakSelf.communicator.publisherView];
        }
        else if (signal == OTSubscriberReady && !error) {
            subscriber.subscriberView.frame = <#your desired frame for this remote subscriberview#>;
            // your logic to handle multiple remote subscriberview(s)
        }
    }];
    ```

- Screen Sharing

    Use `- (instancetype)initWithView:` or `- (instancetype)initWithView:name:` like so

    ```objc
    self.screenSharer = [[OTOneToOneCommunicator alloc] initWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    ```

    or

    ```objc
    self.screenSharer = [[OTMultiPartyCommunicator alloc] initWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    ```

- Pre-defined UI

    Enable audio&video control

    ```objc
    self.communicator.publisherView.controlView.isVerticalAlignment = YES;
    self.communicator.publisherView.controlView.frame = CGRectMake(10, 10, CGRectGetWidth(self.publisherView.frame) * 0.1, CGRectGetHeight(self.publisherView.frame) * 0.3);
    ```

    Handle video enable/disable control

    ```objc
    // default
    // enable handleAudioVideo property, the publisherView will be covered by a silhouette automatically.
    self.communicator.publisherView.handleAudioVideo = YES;

    // disable handleAudioVideo property, the publisherView will do nothing for enabling/disabling publishVideo.
    self.communicator.publisherView.handleAudioVideo = NO;
    ```

### Core Ready-to-Use Components

- One-to-One communication

![ready-in-use-2](./ready-in-use-2.png)
![ready-in-use-3](./ready-in-use-3.png)

```objc
OTOneToOneCommunicationController *vc = [OTOneToOneCommunicationController oneToOneCommunicationControllerWithSession:<#OTAcceleratorSession#>];
[self.navigationController pushViewController:vc animated:YES];
```

## TextChat Sample Code

- Passing the session

    ```objc
    - (OTAcceleratorSession *)sessionOfOTOneToOneCommunicator:(OTOneToOneCommunicator *)oneToOneCommunicator {
        return <#OTAcceleratorSession#>;
    }
    ```

- Start signaling text chat data

    ```objc
    // we assume self owns a table tableView
    [self.textChat connectWithHandler:^(OTTextChatConnectionEventSignal signal, OTConnection *connection, NSError *error) {
        if (signal == OTTextChatConnectionEventSignalDidConnect) {
            NSLog(@"Text Chat starts");
        }
        else if (signal == OTTextChatConnectionEventSignalDidDisconnect) {
            NSLog(@"Text Chat stops");
        }
    } messageHandler:^(OTTextChatMessageEventSignal signal, OTTextMessage *message, NSError *error) {
        if (signal == OTTextChatMessageEventSignalDidSendMessage || signal == OTTextChatMessageEventSignalDidReceiveMessage) {
            if (!error) {
                [weakSelf.textMessages addObject:message];
                [weakSelf.tableView reloadData];
            }
        }
    }];
    ```

- Stop signaling text chat data

    ```objc
    [self.textchat disconnect];
    ```

### JSON Requirements for Text Chat Signaling

The JSON used when using the OpenTok signaling API with the OpenTok Text Chat component describes the information used when submitting a chat message. This information includes the date, chat message text, sender alias, and sender ID. The JSON is formatted as shown in this example:

``` javascript
// var type = "text-chat"
```

```json
{
    "sentOn" : 1462396461923.305,
    "text" : "Hi",
    "sender" : {
        "alias" : "Tokboxer",
        "id" : "16FEB40D-C09B-4491-A983-44677B7EBB3E"
    }
}
```

This formatted JSON is converted to a string, which is submitted to the OpenTok signaling API. For more information, see:

- [Signaling - JavaScript](https://tokbox.com/developer/guides/signaling/js/)
- [Signaling - iOS](https://tokbox.com/developer/guides/signaling/ios/)
- [Signaling - Android](https://tokbox.com/developer/guides/signaling/android/)

For testing text chat, we include a simple web app to make it easier: [Browser-Demo-TextChat](https://github.com/opentok/accelerator-core-ios/blob/master/browser-demo-textchat.html). Simply open it and replace the corresponding API Key, Session ID, and Token values. Then save and load it to the browser.

## Annotation sample code

The `OTAnnotationScrollView` class is the backbone of the annotation features in this Sample.


```objc
self.annotationView = [[OTAnnotationScrollView alloc] init];
self.annotationView.frame = <# desired frame #>;
[self.annotationView initializeToolbarView];
self.annotationView.toolbarView.frame = <# desired frame #>;
```

If you would like to be annotated on either the entire screen or a specified portion of the screen:

```objc
self.annotator = [[OTAnnotator alloc] init];
[self.annotator connectForReceivingAnnotationWithSize:<# desired size #>
                                    completionHandler:^(OTAnnotationSignal signal, NSError *error) {
                                        if (signal == OTAnnotationSessionDidConnect){
                                            self.annotator.annotationScrollView.frame = self.view.bounds;
                                            [self.view addSubview:self.annotator.annotationScrollView];
                                        }
                                    }];

self.annotator.dataReceivingHandler = ^(NSArray *data) {
    NSLog(@"%@", data);
};
```

If you would like to annotate on a remote client's screen:

```objc
self.annotator = [[OTAnnotator alloc] init];
[self.annotator connectForSendingAnnotationWithSize:self.sharer.subscriberView.frame.size
                                completionHandler:^(OTAnnotationSignal signal, NSError *error) {
    
                                    if (signal == OTAnnotationSessionDidConnect){
        
                                        // configure annotation view
                                        self.annotator.annotationScrollView.frame = self.view.bounds;
                                        [self.view addSubview:self.annotator.annotationScrollView];

                                        // self.sharer.subscriberView is the screen shared from a remote client.
                                        // It does not make sense to `connectForSendingAnnotationWithSize` if you don't receive a screen sharing.
                                        [self.annotator.annotationScrollView addContentView:self.sharer.subscriberView];
        
                                        // configure annotation feature
                                        self.annotator.annotationScrollView.annotatable = YES;
                                        self.annotator.annotationScrollView.annotationView.currentAnnotatable = [OTAnnotationPath pathWithStrokeColor:[UIColor yellowColor]];
                                    }
                                }];

self.annotator.dataSendingHandler = ^(NSArray *data, NSError *error) {
    NSLog(@"%@", data);
};
```

### Class design

The following classes represent the software design for the OpenTok Annotations Accelerator Pack.

| Class                                  | Description                                                                                                                                                           |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `OTAnnotator`                          | The core component for enabling remote annotation across devices and platforms.                                                                                       |
| `OTAnnotationScrollView`               | Provides essentials components for annotating on either the entire screen or a specified portion of the screen.                                                       |
| `OTAnnotationToolbarView`              | A convenient annotation toolbar that is optionally available for your development. As an alternative, you can create your own toolbar using `OTAnnotationScrollView`. |
| `OTFullScreenAnnotationViewController` | A convenient view controller enables you to annotate the whole screen immediately.                                                                                    |

### 3rd Party Libraries

- [LHToolbar](https://github.com/Lucashuang0802/LHToolbar)

## Sample Apps that uses the Core

The following sample apps use `Accelerator Core`:

- [Accelerator Sample Apps](https://github.com/opentok/accelerator-sample-apps-ios)

The accelerator and sample app access the OpenTok session through the Accelerator Session Pack layer, which allows them to share a single OpenTok session:

![architecture](./accpackarch.png)

On the Android and iOS mobile platforms, when you try to set a listener (Android) or delegate (iOS), it is not normally possible to set multiple listeners or delegates for the same event. For example, on these mobile platforms you can only set one OpenTok signal listener. The Common Accelerator Session Pack, however, allows you to set up several listeners for the same event.

### Obtaining OpenTok Credentials

To use OpenTok's framework you need a Session ID, a Token, and an API Key. You can get these values at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/) . For production deployment, you must generate the Session ID and Token values using one of the [OpenTok Server SDKs](https://tokbox.com/developer/sdks/server/).


## Development and Contributing

Interested in contributing? We :heart: pull requests! See the [Contribution](CONTRIBUTING.md) guidelines.

## Getting Help

We love to hear from you so if you have questions, comments or find a bug in the project, let us know! You can either:

- Open an issue on this repository
- See <https://support.tokbox.com/> for support options
- Tweet at us! We're [@VonageDev](https://twitter.com/VonageDev) on Twitter
- Or [join the Vonage Developer Community Slack](https://developer.nexmo.com/community/slack)

## Further Reading

- Check out the Developer Documentation at <https://tokbox.com/developer/>
  

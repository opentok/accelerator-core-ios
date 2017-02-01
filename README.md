![logo](./tokbox-logo.png)

[![Build Status](https://travis-ci.com/opentok/accelerator-core-ios.svg?token=Bgz48rVAyAihVsymz2iz&branch=master)](https://travis-ci.com/opentok/accelerator-core-ios)

# Accelerator Core iOS <br/>

The Accelerator Core is an easy manner to integrate audio/video communication to any iOS applications via OpenTok platform. Things you can easily do:

- one to one audio/video call
- multiparty audio/video call
- one to one screen sharing
- multiparty screen sharing
- UI components for handling audio/video enable&disable

# Configure, build and run the sample app <br/>

1. Get values for **API Key**, **Session ID**, and **Token**. See [Obtaining OpenTok Credentials](#obtaining-opentok-credentials) for important information.

1. Replace the following empty strings with the corresponding API Key, Session ID, and Token values:

    ```objc
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Override point for customization after application launch.
        sharedSession = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:@"apikey" sessionId:@"sessionid" token:@"token"];
        return YES;
    }
    ```

1. Use Xcode to build and run the app on an iOS simulator or device.

1. By using Xcode, you can run a simulator and a device at the same time for 1-1 communication. For multiparty call, you might want to run on other platforms like your browsers:

[Accelerator Core Javascript](https://github.com/opentok/accelerator-core-js) <br />
[Accelerator Core Android](https://github.com/opentok/accelerator-core-android)

####Obtaining OpenTok Credentials

To use OpenTok's framework you need a Session ID, Token, and API Key you can get these values at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/) . For production deployment, you must generate the Session ID and Token values using one of the [OpenTok Server SDKs](https://tokbox.com/developer/sdks/server/).

# Accelerator Core as a dependency <br/>
The Accelerator Core is required whenever you use any of the OpenTok accelerators. The Accelerator Core is a common layer that includes the audio-video communication logic contained in all [OpenTok One-to-One Communication Sample Apps](https://github.com/opentok/one-to-one-sample-apps), and permits all accelerators and samples to share the same OpenTok session. The accelerator packs and sample app access the OpenTok session through the Common Accelerator Session Pack layer, which allows them to share a single OpenTok session:

![architecture](./accpackarch.png)

On the Android and iOS mobile platforms, when you try to set a listener (Android) or delegate (iOS), it is not normally possible to set multiple listeners or delegates for the same event. For example, on these mobile platforms you can only set one OpenTok signal listener. The Common Accelerator Session Pack, however, allows you to set up several listeners for the same event. 

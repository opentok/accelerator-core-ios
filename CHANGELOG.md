# CHANGELOG

The changelog for `Accelerator-Core` iOS.

--------------------------------------

1.1.8
-----

### Fixes

- Fix a crash on un-subscribing

1.1.7
-----

Cocoapods release

1.1.6
-----

### Enhancements

- Point OpenTok iOS SDK to at least 2.13.0
- Fix problem with subscriber cleanup

1.1.5
-----

### Enhancements

- Point OpenTok iOS SDK to at least 2.12.0
- Fix SVProgress on the sample app


1.1.4
-----

### Enhancements

- Ensure session is bind to dataSource to avoid invalidity.

1.1.3
-----

### Fixes

- Fix a crash during releasing subscribers on `audioLevelDelegate`

1.1.2
-----

### Enhancements

- Point OpenTok iOS SDK to at least 2.11.0
- Enhance on documentation

1.1.1
-----

### Fixes

- Fix an issue that `OTOneToOneCommunicationController` won't disconnect automatically

1.1.0
-----

### Enhancements

- Add a Ready-in-Use for one-to-one communication: `OTOneToOneCommunicationController` 
- Add two callback methods `didTapAudioButtonOnVideoControlView:` and `didTapVideoButtonOnVideoControlView:` on OTAudioVideoControlView
- Seperate OTAudioVideoControlView from OTVideoView to be an independent class
- Add a basic UI testing

1.0.5
-----

### Enhancements

- Enable preferred resolution so OpenTok cloud will send desired resolution
- Enhancements on the sample app
- Enhancements on the docs about pre-defined UI

1.0.4
-----

### Enhancements

- Introduce a new property to access connection count
- Introduce a new property to indicate whether it's the first connection

1.0.3
-----

### Breaking Changes

- The minimum OpenTok iOS SDK now is eqaul or above 2.10.0 which requires iOS SDK 9.0 or above

### Enhancements

- Add one more log entry to make sure that sessionId, connectionId and partnerId are logged

### Fixes

- Fix a crash that publisher is not cleaned up in OTVideoView upon deallocation
- Fix a convenient initializer potential bug
- Fix a minor publishOnly bug
- Fix OpenTok iOS SDK deprecated warnings

1.0.2
-----

### Enhancements

- Update Audio/Video control upon ininitialization of `OTVideoView`
- Add installation guide and sample codes to README.md

1.0.1
-----

### Enhancements

- Add tags on README.md
- Fix a CocoaPods issue

1.0.0
-----

Official release

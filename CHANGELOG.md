# CHANGELOG

The changelog for `Accelerator-Core` iOS.

--------------------------------------

1.1.0
-----

### Enhancements

- Add two callback methods `didTapAudioButtonOnVideoControlView:` and `didTapVideoButtonOnVideoControlView:` on OTAudioVideoControlView
- Seperate OTAudioVideoControlView from OTVideoView to be an independent class

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

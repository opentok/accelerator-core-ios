![logo](./tokbox-logo.png)

# Accelerator Core iOS <br/>

The Accelerator Core is an easy manner to integrate audio/video communication to any iOS applications via OpenTok platform. Things you can easily do:

- one to one audio/video call
- multiparty audio/video call
- one to one screen sharing
- multiparty screen sharing
- UI components for handling audio/video enable&disable

# Accelerator Core Examples <br/>


# Accelerator Core as a dependency <br/>
The Accelerator Core is required whenever you use any of the OpenTok accelerators. The Accelerator Core is a common layer that includes the audio-video communication logic contained in all [OpenTok One-to-One Communication Sample Apps](https://github.com/opentok/one-to-one-sample-apps), and permits all accelerators and samples to share the same OpenTok session. The accelerator packs and sample app access the OpenTok session through the Common Accelerator Session Pack layer, which allows them to share a single OpenTok session:

![architecture](./accpackarch.png)

On the Android and iOS mobile platforms, when you try to set a listener (Android) or delegate (iOS), it is not normally possible to set multiple listeners or delegates for the same event. For example, on these mobile platforms you can only set one OpenTok signal listener. The Common Accelerator Session Pack, however, allows you to set up several listeners for the same event. 

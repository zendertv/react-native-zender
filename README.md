# Description

This repository provides a react-native wrapper around the Zender Player. 
The react-native packages has several native dependencies. As these dependencies are not publicly available, they need to be manually added/installed.

Current react native version is `2.0.2` 
- ios dependencies: `Zender 2.0.0`, `ZenderPhenix 2.0.0`
- android dependencies: `Zender 2.0.5`, `ZenderPhenix 2.0.5`

# Find your configuration in the Zender Admin
- Logging to the admin <https://admin.zender.tv>
- Select a specific stream
- Get the information (the I icon)
- Read the targetId and channelId

 ![Zender TargetId and ChannelId](docs/images/targetId-channelId.png?raw=true "Find your Zender TargetId and ChannelId")

# Usage
```javascript
import React, { Component } from 'react';
import { ZenderPlayerView } from 'react-native-zender';

// The settings will be communicated to you after signing the contract
const zenderTargetId  = "ttttt-ttttt-ttttt-tttt-ttttt"
const zenderChannelId = "ccccc-ccccc-ccccc-cccc-ccccc"

// Example Device Login provider
// See authentication documentation for other providers such as Facebook,Google,JsonToken
const zenderAuthentication = {
  provider: "device" ,
  payload: {
    "token": "something-unique-like-the-uuid-of-the-phone",
    "name": "patrick",
    "avatar": "https://example.com/myavatar.png"
  }
}

const zenderConfig = {
  debugEnabled: false,
  // iOS: you need to listen for the deviceToken and pass it here
  // Android:
  deviceToken: "<deviceToken used for push notification without spaces>"
}

type Props = {};
export default class App extends Component<Props> {

  constructor(props) {
    super(props);
    this.onZenderPlayerClose = this.onZenderPlayerClose.bind(this);
    this.onZenderPlayerQuizShareCode = this.onZenderPlayerQuizShareCode.bind(this);
  }
  
  // Use this callback to handle when the users wants to close the view
  onZenderPlayerClose(event) {
    console.log('Zender Player Close Event');
  }

  // This callback provides you with the information to make a shareobject with a deeplink
  onZenderPlayerQuizShareCode(event) {
    console.log('Zender Player Share code Event');
    console.log('Share text: '+event.shareText);
    console.log('Share code: '+event.shareCode);
  }

  render() {

    return <ZenderPlayerView
      targetId={ zenderTargetId }
      channelId={ zenderChannelId }
      authentication = { zenderAuthentication }
      config = { zenderConfig }
      onZenderPlayerClose={ this.onZenderPlayerClose }
      onZenderPlayerQuizShareCode={ this.onZenderPlayerQuizShareCode }
      style={{ 
		flex: 1 , 
		backgroundColor: '#9FA8DA' // By default the view is transparent if no background has been set , set your own default color
	  }} 
	/>; // be sure to add flex:1 so the view appears full size
  }
}
```




# Installation
## Add NPM Package
`$ npm install https://repo.zender.tv/rn/react-native-zender-2.0.2.tgz --save`

Note:
- we add the package through a remote url instead of the public npm registry as some of the libraries are proprietry and can not be public.
- npm linking from a local directory will not work as react-native does not support symbolic links for packages.
- the npm tgz file is large (150mb+) so it might take some time to install, when you use a recent npm version this will be cached locally for speedups

## Link the native package inside your own project
Now that you've installed the package, you can link it. This will setup the relation between your project and the react-native zender module.

`$ react-native link react-native-zender`

## iOS native setup
This modules depends on additional frameworks. These frameworks are included inside the react-native-zender npm module.
To make your iOS project find these frameworks you need to do two additional steps:

### Configure Framework search Path
The first step it add the module Frameworks directory to the Framework search path:
- Select your Application Target (on the left)
- Select the build settings
- Find the section "Framework Search Paths"
- Add `$(PROJECT_DIR)/../node_modules/react-native-zender/ios/Frameworks` and mark it as recursive

![Add Framework Search Path](docs/images/ios/framework-searchpath.png?raw=true "Add Framework Search Path")

### Add to Embedded Frameworks to the project
The second step is to add the frameworks as embedded frameworks:
- Select your Application Target (on the left)
- Select the General tab
- Select Add the framework via the `Embedded Binaries` (+ button)
- Select Other to add the framework 
- Browse to your `node_modules/react-native-zender/ios/Frameworks`
- Add frameworks `Zender`, `ZenderPhenix` and `PhenixSdk`
- When a screen pops up to 'Choose options for adding these files' `(Deselect Copy if needed, Select Create folder references)`

![Add to Embedded Frameworks](docs/images/ios/framework-embed.png?raw=true "Add to Embedded Frameworks")

### Strip frameworks
The Zender frameworks provides `armv7, arm64, x86_64` architecture builds.
To publish an app to the appstore, you need to strip the simulator part.

- Select your Application Target (on the left)
- Select the Build Phases tab
- Add a `Run Script` (plus sign top left) below the `Enmbedded Frameworks` section
- Enter `bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Zender.framework/strip-framework.sh"`

![Strip Frameworks](docs/images/ios/strip-frameworks.png?raw=true "Strip Framework")

### Disable bitcode
Zender depends on frameworks that are currrently not BITCODE enabled.  Therefore you need to disable it:
- Select your Application Target (on the left)
- Select the `Build Settings` tab
- Find `Enable Bitcode` and select NO

![Disable bitcode](docs/images/ios/disable-bitcode.png?raw=true "Disable bitcode")

### Orientation Portrait
The Zender player autorotates, if you don't want this behaviour you need to fix the app rotation or the controller

- Select your Application Target (on the left)
- Select the `General` tab
- Select/Deselect the required `Device Orientation` options

![Fix portrait](docs/images/ios/portrait-only.png?raw=true "Fix Portrait Modus")

### Background audio
To be able to play audio in background, add this to the background mode:

- Select your Application Target (on the left)
- Select the `Capabilities` tab
- Select `Audio, Airplay, and Picture in Picture`

![Background Audio](docs/images/ios/background-audio.png?raw=true "Background Audio")

### Target version
the iOS target version is `9.0` and above

### Settings verification
Depending on the react native version you need to check the following settings in your ios project:
- Verify that the following property is set: Runpath Search Paths should be @executable_path/Frameworks (under Build Settings -> Linking)
- Objective-C only: Set Enable Modules (C and Objective-C) to Yes (under Build Settings -> Apple Clang - Language - Modules)

## Android native setup
### Base setup
For android , all necessary files are included in the react-native library ; 

- RNZenderPlayer depends on both `zender_core, zender_logger, zender_phenix` and the phenix-sdk .aar files
- The buildToolsVersion is currently `28.0.3` , this can be changed in the android/build.gradle file of the module if necessary

The `minSDKVersion` is 19 (Android 4.4) ; Update your `android/build.gradle` file:

```
buildscript {
    ext {
        buildToolsVersion = "28.0.3"
        minSdkVersion = 19                 <===== Edit here
        compileSdkVersion = 28
        targetSdkVersion = 28
        supportLibVersion = "28.0.0"
    }
```


### Dependencies
For reference Zender also depends on:
```
     implementation 'com.google.code.gson:gson:2.8.2'
     implementation 'com.squareup.picasso:picasso:2.5.2'
```

### Allow backup flag
Depending on your React native version used, you may have to add the flag android:allowBackup to your app `AndroidManifest.xml`

```
 <manifest xmlns:android="http://schemas.android.com/apk/res/android"
+    xmlns:tools="http://schemas.android.com/tools"
     package="com.zenderrnsample">

     <uses-permission android:name="android.permission.INTERNET" />
     <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>

     <application
+        tools:replace="android:allowBackup"

```


### Soft-input pan
Android has different ways of dealing with the focus when typing on the keyboard.
React-Native by default uses `android:windowSoftInputMode="adjustResize">`. This setting resizes the view to allow for the keyboard.

When using the keyboard in zender , we want a different behavior: scroll up the view instead of resizing . This is the equivalent of the `adjustPan` modus.
To have the expected behavior Zender forces the softInputModus `adjustPan`

## Changelog
- 2.0.2: fixes to android logging structure, removed allowbackup requirement for Android
- 2.0.1: added zender libs ios 2.0.5 , phenix sdk 2019.2.1 , remove legacy http library dependency Android,
- 2.0.0: rename module to reactive-native-zender , installation via remote url , local framework linking instead of cocoapods
- 1.0.0: fixes background/foreground, connectionfeedback flex layout rendering, image fullwidth, allow auto-orientation
- 0.0.3: react-native android version
- 0.0.2: react-native ios version

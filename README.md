# Description

This repository provides a react-native wrapper around the Zender Player. Current version is 2.0.0
The react-native packages has several native dependencies. As these dependencies are not publicly available, they need to be manually added/installed.

# Installation
## Add NPM Package
`$ npm install react-native-zender --save`
`$ npm install http://localhost:8000/react-native-zender-2.0.0.tgz --save`

## Link the native package inside your own project

`$ react-native link react-native-zender`

# Usage
```javascript
import { ZenderPlayerView } from 'react-native-zender';

const zenderTargetId  = "ttttt-ttttt-ttttt-tttt-ttttt"
const zenderChannelId = "ccccc-ccccc-ccccc-cccc-ccccc"

// Example Device Login provider
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
  deviceToken: "<deviceToken used for push notification>"
}

type Props = {};
export default class App extends Component<Props> {

  onZenderPlayerClose(event) {
    console.log('Zender Player Close Event');
  }

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
      style={{ flex: 1 }} />; // be sure to add flex:1 so the view appears full size
  }
}
```


# iOS native setup
## Configure Framework search Path

![Add Framework Search Path](docs/images/ios/framework-searchpath.png?raw=true "Add Framework Search Path")

## Add to Embedded Frameworks to the project

![Add to Embedded Frameworks](docs/images/ios/framework-embed.png?raw=true "Add to Embedded Frameworks")

# Android native setup
## Base setup
For android , all necessary files are included in the react-native library ; 

- RNZenderPlayer depends on both `zender_core, zender_logger, zender_phenix` and the phenix-sdk .aar files
- The buildToolsVersion is currently `28.0.3` , this can be changed in the android/build.gradle file of the module if necessary

For reference Zender also depends on:
```
     implementation 'com.google.code.gson:gson:2.7'
     implementation 'com.squareup.picasso:picasso:2.5.2'
```

Depending on your react-native version the config of your React Native project may require some tweaking.

## Allow backup flag
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

## Android 9+ - Apache HTTP client deprecation
Starting from Android 9 , android does not include the legacy org.http package anymore. This is currently required for the Zender Logger solution.
To make it work you need to add the following to your React Native Android Manifest. More info at <https://developer.android.com/about/versions/pie/android-9.0-changes-28>


`<uses-library android:name="org.apache.http.legacy" android:required="false"/>`

## Soft-input pan
Android has different ways of dealing with the focus when typing on the keyboard.
React-Native by default uses `android:windowSoftInputMode="adjustResize">`. This setting resizes the view to allow for the keyboard.

When using the keyboard in zender , we want a different behavior: scroll up the view instead of resizing . This is the equivalent of the `adjustPan` modus.
To have the expected behavior Zender forces the softInputModus `adjustPan`

## Orientation
The Zender player autorotates, if you don't want this behaviour you need to fix the app rotation

## Changelog
- 1.0.0: fixes background/foreground, connectionfeedback flex layout rendering, image fullwidth, allow auto-orientation
- 0.0.3: react-native android version
- 0.0.2: react-native ios version

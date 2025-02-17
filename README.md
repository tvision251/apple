# Kiwix for iOS & macOS

This is the home for Kiwix apps on iOS and macOS.

[![CodeFactor](https://www.codefactor.io/repository/github/kiwix/apple/badge)](https://www.codefactor.io/repository/github/kiwix/apple)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<img src="https://img.shields.io/badge/Swift-5.2-orange.svg" alt="Drawing="/>

### Mobile app for iPads & iPhones ###
- Download the iOS mobile app on the [App Store](https://ios.kiwix.org)

### Kiwix Desktop for macOS ###
- Download Kiwix Desktop on the [Mac App Store](https://macos.kiwix.org)
- Download Kiwix Desktop [DMG file](https://download.kiwix.org/release/kiwix-desktop-macos/kiwix-desktop-macos.dmg)

## Developers

### Dependencies

* An [Apple Developer account](https://developer.apple.com) (doesn't require membership)
* Latest Apple Developers Tools ([Xcode](https://developer.apple.com/xcode/))
* Its command-line utilities (`xcode-select --install`)
* `CoreKiwix.xcframework` ([libkiwix](https://github.com/kiwix/libkiwix))

### Creating `CoreKiwix.xcframework`

Instructions to build libkiwix at [on the kiwix-build repo](https://github.com/kiwix/kiwix-build).

The xcframework is a bundle of a library for multiple architectures and/or platforms. The `CoreKiwix.xcframework` will contain libkiwix library for macOS archs and for iOS. You don't have to follow steps for other platform/arch if you don't need them.

Following steps are done from kiwix-build root and assume your apple repository is at `../apple`.

#### Build libkiwix

Make sure to preinstall kiwix-build prerequisites (ninja and meson).

If you use homebrew, run the following

```sh
brew install ninja meson
```

Make sure xcode command tools are installed. Make sure to download an iOS SDK if you want to build for iOS.

```sh
xcode-select --install
```

Then you can build `libkiwix` 

```sh
git clone https://github.com/kiwix/kiwix-build.git
cd kiwix-build
# [iOS] build libkiwix
kiwix-build --target-platform iOS_arm64 libkiwix
kiwix-build --target-platform iOS_x86_64 libkiwix  # iOS simulator in Xcode
# [macOS] build libkiwix
kiwix-build --target-platform macOS_x86_64 libkiwix
kiwix-build --target-platform macOS_arm64_static libkiwix
```

#### Create fat archive with all dependencies

This creates a single `.a` archive named `merged.a` (for each platform) which contains libkiwix and all it's dependencies.
Skip those you don't want to support.

```sh
libtool -static -o BUILD_macOS_x86_64/INSTALL/lib/merged.a BUILD_macOS_x86_64/INSTALL/lib/*.a
libtool -static -o BUILD_macOS_arm64_static/INSTALL/lib/merged.a BUILD_macOS_arm64_static/INSTALL/lib/*.a
libtool -static -o BUILD_iOS_x86_64/INSTALL/lib/merged.a BUILD_iOS_x86_64/INSTALL/lib/*.a
libtool -static -o BUILD_iOS_arm64/INSTALL/lib/merged.a BUILD_iOS_arm64/INSTALL/lib/*.a
```

If you built macOS support for both archs (that's what you want unless you know what you're doing), you need to merge both files into a single one

```sh
mkdir -p macOS_fat
lipo -create -output macOS_fat/merged.a \
	-arch x86_64 BUILD_macOS_x86_64/INSTALL/lib/merged.a \
	-arch arm64 BUILD_macOS_arm64_static/INSTALL/lib/merged.a
```

#### Add fat archive to xcframework

```sh
xcodebuild -create-xcframework \
	-library macOS_fat/merged.a -headers BUILD_macOS_x86_64/INSTALL/include \
	-library BUILD_iOS_x86_64/INSTALL/lib/merged.a -headers BUILD_iOS_x86_64/INSTALL/include \
	-library BUILD_iOS_arm64/INSTALL/lib/merged.a -headers BUILD_iOS_arm64/INSTALL/include \
	-output ../apple/CoreKiwix.xcframework
```

You can now launch the build from Xcode and use the iOS simulator or your macOS target. At this point the xcframework is not signed.


### Building Kiwix iOS or Kiwix macOS

* Open project with Xcode `open Kiwix.xcodeproj/project.xcworkspace/`
* Change the Bundle Identifier (in *Signing & Capabilities*)
* Select appropriate Signing Certificate/Profile.

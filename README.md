


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/wafflestudio/snutt-ios">
    <img src="https://user-images.githubusercontent.com/33917774/199519767-60590904-b15a-4464-ab21-e3a424649d5c.svg" alt="Logo" width="70" height="70">
  </a>

  <h3 align="center">SNUTT iOS</h3>

  <p align="center">
    The best timetable application for SNU students, developed and maintained by SNU students.
    <div style=" padding-bottom: 1rem;">
    <img src="https://img.shields.io/badge/iOS-1A1A1A?style=for-the-badge&logo=apple&logoColor=white"/>
    <img src="https://img.shields.io/badge/SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white"/>
    <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=uikit&logoColor=white"/>
    <img src="https://img.shields.io/badge/Fastlane-68BD49?style=for-the-badge&logo=fastlane&logoColor=white"/>
    </div>
    <a href="https://apps.apple.com/kr/app/snutt-%EC%84%9C%EC%9A%B8%EB%8C%80%ED%95%99%EA%B5%90-%EC%8B%9C%EA%B0%84%ED%91%9C-%EC%95%B1/id1215668309">App Store</a>
    ·
    <a href="https://github.com/wafflestudio/snutt-ios/issues">Request Feature</a>
    ·
    <a href="https://github.com/wafflestudio/snutt-ios/issues">Report Bug</a>
    ·
    <a href="https://wafflestudio.com/">Wafflestudio</a>
  </p>
</div>


<!-- ABOUT THE PROJECT -->
## About The Project

This repository contains two iOS projects in the root directory: `./SNUTT` and `./SNUTT-2022`.

| | SNUTT | SNUTT-2022
|---|:---:|:---:|
|First Release| 2017.03.22 | 2022.11.12 |
|Directory| `./SNUTT` | `./SNUTT-2022` |
|Version| `<=2.1.3` | `>=3.0.0` |
|Framework| UIKit | SwiftUI |
|Status| ![deprecated](https://img.shields.io/badge/deprecated-red) | ![maintained](https://img.shields.io/badge/maintained-success) |


## Features

- ♻️ Clean Architecture + MVVM
- 🌓 Dark Mode Support
- 🖼️ Widgets Support
- 💫 Hand-crafted UI components

<!-- GETTING STARTED -->
## Getting Started


### Prerequisites

To get the project up and running, ensure that you have the following files in appropriate path:

- `SNUTT-2022/SNUTT/DebugConfig.xcconfig`
- `SNUTT-2022/SNUTT/ReleaseConfig.xcconfig`
- `SNUTT-2022/SNUTT/GoogleServiceDebugInfo.plist`
- `SNUTT-2022/SNUTT/GoogleServiceReleaseInfo.plist`

You'll need to have *fastlane* installed on your local development machine. See [fastlane installation guide](https://docs.fastlane.tools/) for more information. One of the possible methods could be using *homebrew*:

```sh
brew install fastlane
```

### Installation

1. Clone the repository.
   
   ```sh
   git clone https://github.com/wafflestudio/snutt-ios.git
   ```
2. Navigate to the project folder.
   
   ```sh
   cd SNUTT-2022
   ```

3. Configure necessary certificate and provisioning profile. You can switch between multiple environments, including environment variables and code signing settings, all at once via following commands. ***Note that you must provide a valid passphrase when prompted.***
   
   ```sh
   fastlane certificates_development --env dev
   # or
   fastlane certificates_development --env prod
   # or
   fastlane certificates_distribution --env dev
   # or
   fastlane certificates_distribution --env prod
   ```

4. Now you should be able to run the app on your real iOS devices!

### Deployment

> :warning: Admin privileges for this repository are required in order to push this app to the App Store or TestFlight.

This project is deployed by the tag-based deployment method. Simply create and push tags according to the rules below, and fastlane will take care of the rest.

```
^(testflight|appstore)\/v(\d+)\.(\d+)\.(\d+)-(release|debug)\.(\d+)$
```

For instance, a tag named `testflight/v3.0.0-debug.1` will trigger an action that creates a `debug` build of the app, sets the version and build number as `3.0.0` and `1` respectively, and uploads it to TestFlight.

Alternatively, an action scheduled under the tag named `appstore/v3.0.0-release.1` will create a release build and submit it to App Store for review. Note that after the review process is complete, you should manually choose to release the app on [App Store Connect](https://appstoreconnect.apple.com/).

#### Caveats

- You cannot upload debug builds to App Store. In other words, tag names such as `appstore/v3.0.0-debug.1` will be ignored.
- The build numbers for any specific version should be monotonically increasing **for each build configuration**. For example, `appstore/v3.0.0-release.5` can't precede `testflight/v3.0.0-release.3`.
- To submit a build to App Store, you must [create a new release](https://github.com/wafflestudio/snutt-ios/releases). The release description should be carefully written, because it will go directly into the App Store changelog.

## Roadmap

- [ ] iOS 16 support (Lock Screen Widgets, Live Activities, etc.)
- [ ] Multi-language support
- [ ] Apple Watch support

See the [open issues](https://github.com/wafflestudio/snutt-ios/issues) for a full list of proposed features (and known issues).


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

### Maintainers

* [@shp7724](https://github.com/shp7724)
* [@peng-u-0807](https://github.com/peng-u-0807)
* [@JSKeum](https://github.com/JSKeum)

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

The app architecture is highly inspired by the following source codes and articles.

- [Clean Architecture for SwiftUI + Combine](https://github.com/nalexn/clean-architecture-swiftui)
- [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/?utm_source=nalexn_github)

Big credit to [@Rajin9601](https://github.com/Rajin9601), who is the original author of this project. 

[SwiftUI]: https://img.shields.io/badge/SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white

<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <!-- <img src="images/logo.png" alt="Logo" width="80" height="80"> -->
    <svg width="70" height="70" viewBox="0 0 27 27" id="logo"><g fill="none" fill-rule="evenodd"><path fill="#E54459" d="M0 0h12.226v17.066H0z"></path><path fill="#1BD0C8" d="M14.774 9.934H27V27H14.774z"></path><path fill="#FAC42D" d="M14.774 0H27v7.387H14.774z"></path><path fill="#A6D930" d="M0 19.613h12.226V27H0z"></path></g></svg>
  </a>

  <h3 align="center">SNUTT iOS</h3>

  <p align="center">
    The best timetable application for SNU students, developed and maintained by SNU students.
    <div style=" padding-bottom: 1rem;">
    <img src="https://img.shields.io/badge/SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white"/>
    <img src="https://img.shields.io/badge/Fastlane-68BD49?style=for-the-badge&logo=xcode&logoColor=white"/>
    <img src="https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white"/>
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

TBD

<!-- GETTING STARTED -->
## Getting Started


### Prerequisites

To get the project up and running, ensure that you have the following files in appropriate path:

- `SNUTT-2022/SNUTT/DebugConfig.xcconfig`
- `SNUTT-2022/SNUTT/ReleaseConfig.xcconfig`

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

4. Now you should be able to run the app using your iOS devices!

<!-- ROADMAP -->
## Roadmap

- [x] Dark mode support
- [x] iOS widget support
- [ ] iOS 16 support (Lock Screen Widgets, Live Activities, etc.)
- [ ] Multi-language Support

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

TBD

[SwiftUI]: https://img.shields.io/badge/SwiftUI-F05138?style=for-the-badge&logo=swift&logoColor=white

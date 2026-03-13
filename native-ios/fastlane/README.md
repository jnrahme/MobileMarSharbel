fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios release_build

```sh
[bundle exec] fastlane ios release_build
```

Create a signed local release archive/IPA

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload the current release to TestFlight

### ios create_app

```sh
[bundle exec] fastlane ios create_app
```

Create the App Store Connect app record

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload localized metadata and screenshots

### ios submit_review

```sh
[bundle exec] fastlane ios submit_review
```

Submit the selected version for App Review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

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

### ios verify

```sh
[bundle exec] fastlane ios verify
```

Run the same iOS verification path used by root automation

### ios setup

```sh
[bundle exec] fastlane ios setup
```

Create or repair App Store certificates and provisioning profiles

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build a signed archive for TestFlight/App Store delivery

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload the latest build to TestFlight after the archive succeeds

### ios create_app

```sh
[bundle exec] fastlane ios create_app
```

Create the app in App Store Connect if it does not exist yet

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload App Store metadata and screenshots without binary upload

### ios submit_review

```sh
[bundle exec] fastlane ios submit_review
```

Submit the latest processed build for App Review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

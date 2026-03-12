# Maestro Smoke Flows

These flows mirror the lightweight smoke-check pattern from `Random-Timer`.

- `ios-smoke.yaml`
  Launches the iOS simulator build and checks the primary home-screen labels.
- `android-smoke.yaml`
  Launches the Android debug build and checks the primary home-screen labels.

Run them from the repo root:

```bash
make maestro-ios
make maestro-android
```

`maestro` must be installed locally before these commands will run.

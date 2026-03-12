# Root Playwright Checks

This package currently provides local, deterministic checks for the root automation shell.

It does not yet include authenticated browser automation for App Store Connect or Google Play. That layer should be
added only after:

- the root repo exists on GitHub
- secrets are configured
- a stable store release workflow exists

## Install

```bash
cd tests/playwright
npm ci
```

## Run

```bash
npm run verify
npm run verify:strict
```

## Current scope

- required root files exist
- workflow scaffolding exists
- docs site files exist
- playbook contains the major roadmap sections

Strict mode additionally checks the release-readiness quick wins:

- store-access checker plumbing
- main-promotion workflow enforcement
- strict CI wiring for local contract checks

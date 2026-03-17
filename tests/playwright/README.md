# Root Playwright Checks

This package currently provides local, deterministic checks for the root automation shell.

It does not yet include authenticated browser automation for App Store Connect or Google Play. That layer should be
added only after:

- the root repo exists on GitHub
- secrets are configured
- a stable store release workflow exists

## Install

```bash
nvm use
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

## Browser agents (optional)

This package now includes optional browser-agent tooling for store-console workflows.

### Install agent tooling

```bash
cd tests/playwright
npm ci
npx agent-browser install
```

### Open store consoles with `agent-browser`

```bash
npm run agent:open:asc
npm run agent:open:play
```

### Capture reusable auth state

Use this after logging in through your normal Chrome profile:

```bash
npm run agent:state:save
```

This writes `tests/playwright/.auth/store-auth.json` (already gitignored).

### Anchor smoke test

```bash
export ANCHOR_API_KEY=your_key
npm run anchor:smoke
```

Optional task override:

```bash
ANCHOR_SMOKE_TASK="Open https://play.google.com/console and list the visible navigation items." npm run anchor:smoke
```

# Mobile Automation Roadmap

Date: 2026-03-12

## Objective

Turn this workspace into a push-ready root repo that behaves like a disciplined mobile delivery repo as soon as it lands on GitHub.

## Current reality

- The workspace is split into `native-ios/` and `native-android/`.
- Each native app already has its own local health check and simple GitHub workflows.
- There is no root GitHub automation layer yet.
- The workspace still contains nested `.git` directories, which means the final repo strategy is not decided.

## What this pass can complete

- Root docs site and automation playbook
- Root `Makefile`
- Root repo contract checks and bootstrap scripts
- Root CI workflow
- Root security workflow
- Root remote dependency workflow
- Root artifact-oriented release workflow
- Root docs publishing workflow scaffold
- Root Playwright local contract checks
- Root GitHub issue and PR templates
- Explicit TODO list for user-only interventions

## What remains blocked on user intervention

- Confirm the long-term branch policy if it should differ from `main` + `develop`
- Add GitHub secrets for Apple, Google Play, Android signing, and any analytics/crash services
- Enable or confirm GitHub Pages if docs publishing should go live
- Configure branch protection and environment reviewer rules
- Provide store access if browser-level console verification is desired

## Recommended rollout order

1. Push the root shell into the real GitHub repo.
2. Let CI, security, and docs workflows prove the repo structure.
3. Resolve the nested `.git` strategy.
4. Add secrets and signing assets.
5. Enable release publishing and store verification layers.
6. Add Maestro and store-console browser checks after the base stays green.

## Design direction

The docs site should feel like an executive operations briefing, not a plain generated report. That means:

- clear hierarchy
- visible status split
- low-noise typography
- calm but high-contrast color
- roadmap and blockers made explicit

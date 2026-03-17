.DEFAULT_GOAL := help

.PHONY: help
.PHONY: verify verify-full verify-repo verify-ios verify-ios-full verify-android verify-android-full verify-playwright
.PHONY: preflight-release preflight-release-ios preflight-release-android hygiene-check cli-smoke store-access-check
.PHONY: run-ios-sim run-android-emulator run-android-device maestro-ios maestro-android
.PHONY: remote-health remote-health-ios remote-health-android
.PHONY: playwright-install playwright-verify-local playwright-verify-strict install-hooks gitleaks-install security-gitleaks print-blockers docs-site
.PHONY: ios-store-assets ios-metadata-sync ios-testflight ios-release-build ios-asc-ready ios-submit-review ios-submit-review-dry ios-asc-poll
.PHONY: agent-browser-install agent-browser-open-asc agent-browser-open-play agent-browser-snapshot agent-browser-state-save anchor-smoke

IOS_DIR := native-ios
ANDROID_DIR := native-android
PLAYWRIGHT_DIR := tests/playwright
TOOLS_BIN := $(CURDIR)/.tools/bin

help:
	@printf '%s\n' \
		'Available commands:' \
		'  make verify                 Run repo + iOS + Android verification' \
		'  make verify-full            Run verification, CLI smoke checks, and Playwright local checks' \
		'  make preflight-release      Run Random-Timer-style release readiness checks (layer 1)' \
		'  make store-access-check     Validate configured App Store / Play API credentials' \
		'  make hygiene-check          Run repo hygiene checks' \
		'  make cli-smoke              Validate the root command surface' \
		'  make run-ios-sim            Build, install, and launch the iOS app on a simulator' \
		'  make run-android-emulator   Build, install, and launch Android on an emulator' \
		'  make run-android-device     Build, install, and launch Android on a connected device' \
		'  make maestro-ios            Run the iOS Maestro smoke flow' \
		'  make maestro-android        Run the Android Maestro smoke flow' \
		'  make ios-store-assets       Export App Store screenshot assets into native-ios/fastlane/screenshots' \
		'  make ios-metadata-sync      Upload iOS App Store metadata and screenshots via fastlane' \
		'  make ios-release-build      Create a signed local iOS release archive/IPA via fastlane' \
		'  make ios-testflight         Build and upload the iOS app to TestFlight via fastlane' \
		'  make ios-asc-ready          Verify App Store Connect submission readiness via API' \
		'  make ios-asc-poll           Poll App Store Connect version state (set IOS_WAIT=1 to wait)' \
		'  make ios-submit-review-dry  Sync assets, upload metadata, and run ASC readiness without submitting' \
		'  make ios-submit-review      Run the full iOS submit-for-review CLI flow' \
		'  make playwright-verify-strict Run the strict local Playwright release-readiness checks' \
		'  make remote-health          Run full remote dependency checks on both native apps' \
		'  make security-gitleaks      Install gitleaks if needed and run a repo secret scan' \
		'  make agent-browser-install  Install agent-browser and Anchor dependencies for store-console automation' \
		'  make agent-browser-open-asc Open App Store Connect with agent-browser' \
		'  make agent-browser-open-play Open Google Play Console with agent-browser' \
		'  make agent-browser-snapshot Capture a browser snapshot via agent-browser' \
		'  make agent-browser-state-save Save browser auth state to tests/playwright/.auth/store-auth.json' \
		'  make anchor-smoke           Run a basic Anchor Browser API smoke task (requires ANCHOR_API_KEY)' \
		'  make print-blockers         Print the manual follow-up checklist'

verify: verify-repo verify-ios verify-android

verify-full: verify cli-smoke playwright-verify-strict

verify-repo:
	@bash scripts/check-repo-contract.sh

hygiene-check:
	@bash scripts/hygiene-check.sh

verify-ios:
	@SKIP_REMOTE_CHECKS=1 bash scripts/verify-ios.sh

verify-ios-full:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-ios.sh

verify-android:
	@SKIP_REMOTE_CHECKS=1 bash scripts/verify-android.sh

verify-android-full:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-android.sh

preflight-release:
	@bash scripts/preflight-release.sh --platform both --layer 1

preflight-release-ios:
	@bash scripts/preflight-release.sh --platform ios --layer 1

preflight-release-android:
	@bash scripts/preflight-release.sh --platform android --layer 1

store-access-check:
	@bash scripts/store-python.sh scripts/check_store_access.py --platform both

cli-smoke:
	@bash scripts/cli-smoke-test.sh

run-ios-sim:
	@bash scripts/run-ios-sim.sh

run-android-emulator:
	@bash scripts/run-android-target.sh emulator

run-android-device:
	@bash scripts/run-android-target.sh device

maestro-ios:
	@bash scripts/maestro-smoke.sh ios

maestro-android:
	@bash scripts/maestro-smoke.sh android

ios-store-assets:
	@bash scripts/sync_ios_store_assets.sh --locale "$${IOS_LOCALE:-en-US}"

ios-metadata-sync: ios-store-assets
	@if [ -n "$${IOS_VERSION:-}" ]; then \
		bash scripts/ios-fastlane.sh ios metadata version:"$${IOS_VERSION}"; \
	else \
		bash scripts/ios-fastlane.sh ios metadata; \
	fi

ios-release-build:
	@bash scripts/ios-fastlane.sh ios build_release

ios-testflight:
	@bash scripts/ios-fastlane.sh ios beta

ios-asc-ready:
	@version="$${IOS_VERSION:-$$(sed -n "s/.*MARKETING_VERSION = \\([^;]*\\);/\\1/p" native-ios/SaintCharbelApp.xcodeproj/project.pbxproj | head -1)}"; \
	bash scripts/store-python.sh scripts/asc_verify_ready.py \
		--version "$$version" \
		--locale "$${IOS_LOCALE:-en-US}" \
		--min-iphone "$${IOS_MIN_IPHONE:-1}" \
		--min-ipad "$${IOS_MIN_IPAD:-1}"

ios-submit-review-dry:
	@if [ -n "$${IOS_VERSION:-}" ]; then \
		bash scripts/ios-submit-review.sh \
			--version "$${IOS_VERSION}" \
			--locale "$${IOS_LOCALE:-en-US}" \
			--min-iphone "$${IOS_MIN_IPHONE:-1}" \
			--min-ipad "$${IOS_MIN_IPAD:-1}" \
			--dry-run; \
	else \
		bash scripts/ios-submit-review.sh \
			--locale "$${IOS_LOCALE:-en-US}" \
			--min-iphone "$${IOS_MIN_IPHONE:-1}" \
			--min-ipad "$${IOS_MIN_IPAD:-1}" \
			--dry-run; \
	fi

ios-submit-review:
	@if [ -n "$${IOS_VERSION:-}" ]; then \
		bash scripts/ios-submit-review.sh \
			--version "$${IOS_VERSION}" \
			--locale "$${IOS_LOCALE:-en-US}" \
			--min-iphone "$${IOS_MIN_IPHONE:-1}" \
			--min-ipad "$${IOS_MIN_IPAD:-1}"; \
	else \
		bash scripts/ios-submit-review.sh \
			--locale "$${IOS_LOCALE:-en-US}" \
			--min-iphone "$${IOS_MIN_IPHONE:-1}" \
			--min-ipad "$${IOS_MIN_IPAD:-1}"; \
	fi

ios-asc-poll:
	@version="$${IOS_VERSION:-$$(sed -n "s/.*MARKETING_VERSION = \\([^;]*\\);/\\1/p" native-ios/SaintCharbelApp.xcodeproj/project.pbxproj | head -1)}"; \
	bash scripts/store-python.sh scripts/asc_poll_version_state.py \
		--version "$$version" \
		$${IOS_WAIT:+--wait}

remote-health: remote-health-ios remote-health-android

remote-health-ios:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-ios.sh

remote-health-android:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-android.sh

playwright-install:
	@cd $(PLAYWRIGHT_DIR) && npm ci

verify-playwright:
	@cd $(PLAYWRIGHT_DIR) && npm ci && npm run verify

playwright-verify-strict:
	@cd $(PLAYWRIGHT_DIR) && npm ci && npm run verify:strict

playwright-verify-local: verify-playwright

agent-browser-install:
	@cd $(PLAYWRIGHT_DIR) && npm install
	@cd $(PLAYWRIGHT_DIR) && npx agent-browser install

agent-browser-open-asc:
	@cd $(PLAYWRIGHT_DIR) && npm run agent:open:asc

agent-browser-open-play:
	@cd $(PLAYWRIGHT_DIR) && npm run agent:open:play

agent-browser-snapshot:
	@cd $(PLAYWRIGHT_DIR) && npm run agent:snapshot

agent-browser-state-save:
	@cd $(PLAYWRIGHT_DIR) && npm run agent:state:save

anchor-smoke:
	@cd $(PLAYWRIGHT_DIR) && npm run anchor:smoke

install-hooks:
	@bash scripts/install-hooks.sh

gitleaks-install:
	@bash scripts/ensure-gitleaks.sh

security-gitleaks:
	@bash scripts/ensure-gitleaks.sh >/dev/null
	@PATH="$(TOOLS_BIN):$$PATH" gitleaks git --no-banner --redact

print-blockers:
	@sed -n '1,260p' docs/user-intervention-todo.md

docs-site:
	@echo "Open docs/index.html or docs/random-timer-automation-playbook.html in a browser."

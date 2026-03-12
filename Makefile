.PHONY: verify verify-full verify-repo verify-ios verify-ios-full verify-android verify-android-full verify-playwright
.PHONY: remote-health remote-health-ios remote-health-android
.PHONY: playwright-install playwright-verify-local install-hooks security-gitleaks print-blockers docs-site

IOS_DIR := native-ios
ANDROID_DIR := native-android
PLAYWRIGHT_DIR := tests/playwright

verify: verify-repo verify-ios verify-android

verify-full: verify verify-playwright

verify-repo:
	@bash scripts/check-repo-contract.sh

verify-ios:
	@SKIP_REMOTE_CHECKS=1 bash scripts/verify-ios.sh

verify-ios-full:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-ios.sh

verify-android:
	@SKIP_REMOTE_CHECKS=1 bash scripts/verify-android.sh

verify-android-full:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-android.sh

remote-health: remote-health-ios remote-health-android

remote-health-ios:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-ios.sh

remote-health-android:
	@SKIP_REMOTE_CHECKS=0 bash scripts/verify-android.sh

playwright-install:
	@cd $(PLAYWRIGHT_DIR) && npm ci

verify-playwright:
	@cd $(PLAYWRIGHT_DIR) && npm ci && npm run verify

playwright-verify-local: verify-playwright

install-hooks:
	@bash scripts/install-hooks.sh

security-gitleaks:
	@if command -v gitleaks >/dev/null 2>&1; then \
		gitleaks git --no-banner --redact; \
	else \
		echo "gitleaks is not installed. Install it first."; \
		exit 1; \
	fi

print-blockers:
	@sed -n '1,260p' docs/user-intervention-todo.md

docs-site:
	@echo "Open docs/index.html or docs/random-timer-automation-playbook.html in a browser."

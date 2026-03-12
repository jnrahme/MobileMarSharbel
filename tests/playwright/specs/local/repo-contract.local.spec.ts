import { expect, test } from "@playwright/test";
import fs from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const currentDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(currentDir, "../../../..");

function read(relPath: string): string {
  return fs.readFileSync(path.join(repoRoot, relPath), "utf8");
}

test("root contract files exist", () => {
  const required = [
    "README.md",
    "Makefile",
    ".gitleaks.toml",
    ".trunk/trunk.yaml",
    ".maestro/ios-smoke.yaml",
    ".maestro/android-smoke.yaml",
    "docs/index.html",
    "docs/release-automation.md",
    "docs/random-timer-automation-playbook.html",
    "docs/user-intervention-todo.md",
    ".github/workflows/ci.yml",
    ".github/workflows/security.yml",
    ".github/workflows/native-release.yml",
    ".github/workflows/remote-health.yml",
    ".github/workflows/docs-site.yml",
    ".github/workflows/enforce-develop-to-main.yml"
  ];

  for (const relPath of required) {
    expect(fs.existsSync(path.join(repoRoot, relPath)), `${relPath} should exist`).toBeTruthy();
  }
});

test("playbook contains roadmap and adoption sections", () => {
  const html = read("docs/random-timer-automation-playbook.html");

  expect(html).toContain('id="roadmap"');
  expect(html).toContain('id="atlas"');
  expect(html).toContain('id="drift"');
  expect(html).toContain('id="adoption"');
  expect(html).toContain("What I can wire now vs what still needs you");
});

test("ci workflow covers repo, ios, android, and playwright lanes", () => {
  const workflow = read(".github/workflows/ci.yml");

  expect(workflow).toContain("Repo Contract");
  expect(workflow).toContain("CLI Surface");
  expect(workflow).toContain("Playwright Local Checks");
  expect(workflow).toContain("verify:strict");
  expect(workflow).toContain("iOS Health Check");
  expect(workflow).toContain("Android Health Check");
});

test("makefile exposes the adopted root automation commands", () => {
  const makefile = read("Makefile");

  expect(makefile).toContain("preflight-release");
  expect(makefile).toContain("cli-smoke");
  expect(makefile).toContain("run-ios-sim");
  expect(makefile).toContain("run-android-emulator");
  expect(makefile).toContain("maestro-ios");
  expect(makefile).toContain("security-gitleaks");
});

test("user intervention todo lists secrets and repo settings follow-up", () => {
  const todo = read("docs/user-intervention-todo.md");

  expect(todo).toContain("Branch protection");
  expect(todo).toContain("GitHub Pages");
  expect(todo).toContain("APPSTORE_PRIVATE_KEY");
  expect(todo).toContain("GOOGLE_PLAY_JSON_KEY");
});

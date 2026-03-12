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
    "docs/index.html",
    "docs/random-timer-automation-playbook.html",
    "docs/user-intervention-todo.md",
    ".github/workflows/ci.yml",
    ".github/workflows/security.yml",
    ".github/workflows/native-release.yml",
    ".github/workflows/remote-health.yml",
    ".github/workflows/docs-site.yml"
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
  expect(workflow).toContain("Playwright Local Checks");
  expect(workflow).toContain("iOS Health Check");
  expect(workflow).toContain("Android Health Check");
});

test("user intervention todo lists secrets and nested git decision", () => {
  const todo = read("docs/user-intervention-todo.md");

  expect(todo).toContain("nested `.git` directories");
  expect(todo).toContain("APPSTORE_PRIVATE_KEY");
  expect(todo).toContain("GOOGLE_PLAY_JSON_KEY");
});

import { expect, test } from "@playwright/test";
import fs from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const currentDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(currentDir, "../../../..");
const strictMode = process.env.STRICT_STORE_READINESS === "1";

function read(relPath: string): string {
  return fs.readFileSync(path.join(repoRoot, relPath), "utf8");
}

test("strict store-readiness files exist", () => {
  test.skip(!strictMode, "strict mode only");

  const required = [
    "scripts/check_store_access.py",
    "scripts/validate_release_branch.py",
    ".github/workflows/enforce-develop-to-main.yml",
    "docs/release-automation.md"
  ];

  for (const relPath of required) {
    expect(fs.existsSync(path.join(repoRoot, relPath)), `${relPath} should exist`).toBeTruthy();
  }
});

test("strict workflow and docs mention the quick-win release controls", () => {
  test.skip(!strictMode, "strict mode only");

  const workflow = read(".github/workflows/enforce-develop-to-main.yml");
  const ci = read(".github/workflows/ci.yml");
  const docs = read("docs/release-automation.md");

  expect(workflow).toContain("validate_release_branch.py");
  expect(ci).toContain("verify:strict");
  expect(docs).toContain("store-access checker");
  expect(docs).toContain("main-promotion policy");
});

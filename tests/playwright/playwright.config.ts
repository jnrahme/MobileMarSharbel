import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./specs",
  fullyParallel: false,
  reporter: [
    ["list"],
    ["html", { open: "never", outputFolder: "playwright-report" }]
  ],
  timeout: 30_000,
  projects: [
    {
      name: "local-checks",
      testDir: "./specs/local"
    }
  ]
});


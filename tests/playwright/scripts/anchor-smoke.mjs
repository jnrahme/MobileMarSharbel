#!/usr/bin/env node

import AnchorBrowser from "anchorbrowser";

const apiKey = process.env.ANCHOR_API_KEY || process.env.ANCHORBROWSER_API_KEY;
if (!apiKey) {
  console.error("Missing ANCHOR_API_KEY (or ANCHORBROWSER_API_KEY).");
  process.exit(1);
}

const task =
  process.env.ANCHOR_SMOKE_TASK ||
  "Open https://example.com and report the page title.";

async function run() {
  const anchor = new AnchorBrowser({
    apiKey
  });

  const result = await anchor.agent().task(task);
  console.log(JSON.stringify(result, null, 2));
}

run().catch((error) => {
  console.error(error?.message || error);
  process.exit(1);
});

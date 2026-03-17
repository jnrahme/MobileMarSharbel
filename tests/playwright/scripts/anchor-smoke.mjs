#!/usr/bin/env node

import AnchorBrowser from "anchorbrowser";

const apiKey = process.env.ANCHOR_API_KEY || process.env.ANCHORBROWSER_API_KEY;
if (!apiKey) {
  console.error("Missing ANCHOR_API_KEY (or ANCHORBROWSER_API_KEY).");
  process.exit(1);
}

async function run() {
  const client = new AnchorBrowser({
    apiKey
  });

  // Minimal API smoke check: create and delete a browser session.
  const created = await client.sessions.create({ session: { recording: { active: false } } });
  const sessionId = created?.data?.id;

  if (!sessionId) {
    throw new Error("Anchor smoke failed: session id missing from create response.");
  }

  await client.sessions.delete(sessionId);

  console.log(
    JSON.stringify(
      {
        ok: true,
        sessionId,
        message: "Anchor API key is valid and session lifecycle works."
      },
      null,
      2
    )
  );
}

run().catch((error) => {
  console.error(error?.message || error);
  process.exit(1);
});

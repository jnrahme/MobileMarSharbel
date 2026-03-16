import Anchorbrowser from "anchorbrowser";

const apiKey = process.env.ANCHORBROWSER_API_KEY;

if (!apiKey) {
  console.error("Missing ANCHORBROWSER_API_KEY");
  process.exit(1);
}

const client = new Anchorbrowser({ apiKey });

const session = await client.sessions.create({
  session: { recording: { active: false } }
});

console.log(JSON.stringify(session, null, 2));

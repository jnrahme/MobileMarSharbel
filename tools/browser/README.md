# Browser automation tools

## Agent Browser (local browser control)

Install:

```bash
npm install -g agent-browser
agent-browser install
```

Quick check:

```bash
agent-browser open https://example.com
agent-browser snapshot -i
```

## Anchor Browser (API sessions)

Set your API key:

```bash
export ANCHORBROWSER_API_KEY="your_key_here"
```

Run a session-create smoke test:

```bash
cd tools/browser
npm run anchor:session
```

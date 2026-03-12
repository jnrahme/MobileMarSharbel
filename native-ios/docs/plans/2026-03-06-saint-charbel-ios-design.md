# Saint Charbel iOS App Design

## Scope

Build a native SwiftUI iPhone-first app that complements `marsharbel.com` and focuses on two content pillars:

1. A child-friendly Saint Charbel storybook experience.
2. A Rosary companion with mystery navigation, prayer texts, and guided audio access.

The first implementation is English-first but keeps the data layer static and structured so Arabic and French can be added later without changing the view architecture.

## Architecture

- Native `SwiftUI` app instead of React Native because the repository already contains an Xcode project and the request is specifically for iOS.
- Feature-based structure:
  - `Home`
  - `Story`
  - `Rosary`
  - shared `Core` for theme, content, and audio
- Static content is embedded in Swift models sourced from the website copy.
- Story content uses a reusable manifest structure:
  - `SaintStoryBook`
  - `StoryBookPage`
  - remote page-image URLs
  - remote narration-track URLs
  - lightweight per-page metadata for prompts and page state
- The first Saint Charbel book should mirror the website's live `storybook.js` illustration set rather than the scanned `book-pages/` archive.
- The story reader is deliberately data-driven so more saints can be added by introducing new manifests instead of rewriting view logic.
- Rosary audio streams from the existing website media URLs rather than bundling hundreds of MP3 files into the app binary.

## UX Direction

- Preserve the website's contemplative visual language with dark panels, warm gold accents, serif headlines, and quiet spacing.
- Use `TabView` for fast access to the three primary areas.
- Make the story feel like a real children's book:
  - one story shelf card per saint
  - page-swipe reading with large image pages
  - each page vertically scrollable for longer copy
  - illustration framing that preserves the website art ratio instead of stretching into fixed empty boxes
  - one primary "Read to Me" control
  - automatic forward narration from the current page
  - minimal chrome so the page art stays primary
- Keep the rosary section practical:
  - mystery-set overview
  - mystery detail
  - ten meditation prompts
  - standard prayer texts
  - stage-based audio buttons

## Quality Constraints

- iOS target, not macOS.
- Shared audio manager so only one stream plays at a time.
- Avoid oversized bundles by reusing remote media.
- Prefer `NavigationStack`, `@Observable`, and small reusable SwiftUI components.
- Keep story interactions obvious enough for a child on first use: swipe, tap play, keep going.
- Verify with `xcodebuild` against an iOS simulator target before claiming completion.

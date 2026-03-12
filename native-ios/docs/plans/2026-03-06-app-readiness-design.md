# App Readiness Design

## Scope

Prepare the Saint Charbel iOS app for repeatable verification, professional repository handoff, and App Store packaging readiness.

## Decisions

- Add an in-app service-status section on the home screen to check the remote website, story artwork, story narration, and rosary audio dependencies.
- Add a single repo-level health check script so local development, CI, and release automation all run the same validation path.
- Add a GitHub Actions health check workflow that runs on `main`, pull requests, and manual dispatch.
- Update the release workflow so it depends on the same health check script before producing a release artifact.
- Add a privacy manifest and the non-exempt encryption flag to reduce App Store submission friction.
- Rewrite the README as a delivery-quality engineering document that explains local setup, release automation, health checks, and remaining Apple-side steps.

## Rationale

The app is intentionally lightweight and streams media from `marsharbel.com`, which means runtime health is partly determined by remote availability, not just compilation. A useful readiness baseline therefore needs both:

- build and packaging validation
- dependency availability validation

Combining those checks into one script prevents release drift and makes CI easier to trust.

## Risks

- Remote dependency checks can fail when the website is temporarily unavailable even if the app code is unchanged.
- Privacy manifest coverage is a baseline readiness measure, not a substitute for final App Store Connect privacy questionnaire answers.
- The target GitHub repository `jnrahme/marsharbel` has separate history from this app repository, so pushes should remain non-destructive unless the repositories are intentionally merged later.

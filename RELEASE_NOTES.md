# Release Notes

## v0.1.0 (Initial release)

Features:

- Deep link routing with path and query parameter support
- Async guards with redirect support
- Redirect memory (in-memory) to return users to original deep link after login
- Example app (Home / Login / Product)
- Tests and docs

v0.1.0 updates (added in patch):

- Named-route helpers: `SmartLinkRouter.openNamed`
- Per-route transition support via `LinkRoute.transitionBuilder`
- Navigation history and `SmartLinkRouter.back()` helper
- Optional persistent redirect memory via `SharedPreferences` (call `RedirectMemory.instance.initialize(persistent: true)`)
- GitHub Actions CI

See CHANGELOG.md for full history.

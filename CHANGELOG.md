# Changelog

All notable changes to this repository will be documented here.

## [Unreleased]

## [1.0.0] - 2026-11-11

### New

- Initial four-skill evidence-led Swift pattern workflow.
- Living synchronization from `rgmez/Design-Patterns-in-Swift` through reviewable pull requests.
- Cross-agent package metadata and installation validation.

### Changed

- Declare the MIT license in every skill frontmatter and validate the complete Agent Skills metadata contract.
- Verify remote discovery and full installed-package parity with `skills@1.8.1` for Codex, Claude Code, Cursor, and GitHub Copilot.
- Remove an unused synchronized validator copy from the audit skill package.
- Track only evidence-bearing catalogue commits so unrelated upstream changes do not create synchronization pull requests.
- Pin GitHub Actions by immutable commit and let Dependabot propose grouped updates.
- Add reusable normal and safety-stop evaluations plus branded interface icons.
- Keep teaching commands toolchain-neutral instead of assuming SwiftPM.

[Unreleased]: https://github.com/rgmez/pragmatic-swift-pattern-skills/compare/v1.0.0...master
[1.0.0]: https://github.com/rgmez/pragmatic-swift-pattern-skills/releases/tag/v1.0.0

# halos-halpi2-desktop - Agentic Coding Guide

**LAST MODIFIED**: 2026-05-27

**Document Purpose**: Guide for AI assistants working on halos-halpi2-desktop.

## For Agentic Coding: Use the HaLOS Workspace

When using Claude Code or other AI assistants, work from the halos workspace repository for full context across all HaLOS repositories.

## About This Project

HALPI2 desktop variant metapackage. Single binary `halos-halpi2-desktop` with no content of its own — just a `debian/control` declaring `Depends: halos-halpi2, halos-desktop, halos-halpi-desktop-branding`.

Its job is to mark a HaLOS installation as a HALPI2 desktop variant and pull in the HALPI2-branded wallpaper as the resolved provider of the virtual `halos-desktop-wallpaper`. It also serves as the future hook for any HALPI2-only desktop additions (login screen branding, terminal palette, panel theming) — those get added to its `Depends:` and propagate through this single point.

## How it gets onto devices

**New pi-gen images**: a substage in `halos-pi-gen` ([halos-pi-gen#97](https://github.com/halos-org/halos-pi-gen/issues/97)) installs `halos-halpi2-desktop` at build time on HALPI2 desktop variants. It uses the same `dpkg -l halos-desktop` check pattern that `stage-halos-marine/02-install-combination-metapackage/` already uses to dispatch between the marine combination metapackages.

**Existing field devices**: no automatic migration. Operators wanting HALPI2 branding on a field device run `sudo apt install halos-halpi2-desktop` explicitly.

## Repository Layout

```
.
├── debian/                Debian packaging (control, changelog, rules, source/format, copyright, lintian-overrides)
├── docker/                debtools container for local build
├── .github/               CI workflows (shared-workflows), local actions, lefthook scripts
├── run                    Build/lint commands
├── VERSION                Single source of truth for package version
├── .bumpversion.cfg       bumpversion config
├── lefthook.yml           Pre-commit hooks
├── LICENSE                MIT license
├── README.md              User-facing overview
├── CLAUDE.md              Points at AGENTS.md
├── .gitignore             Standard build/IDE/OS ignores
└── AGENTS.md              This file
```

No `usr/`, no `etc/`, no `sources/` — pure metapackage with no installed payload.

## Cross-org references

This package lives in the `hatlabs` org because HALPI2 source content stays in `hatlabs` per workspace policy. Its `Depends:` references one hatlabs package (`halos-halpi-desktop-branding`) and two halos-org packages (`halos-halpi2`, `halos-desktop`); both apt repos are configured on HaLOS devices so cross-org runtime resolution works.

No halos-org package references this metapackage — the generic-to-specialized direction stays clean.

## Git Workflow Policy

**MANDATORY**: PRs must ALWAYS have all checks passing before merging. No exceptions.

**Branch Workflow**: Never push to main directly — always use feature branches and PRs.

**Changelog Policy**: Never edit `debian/changelog` directly. Always use `./run bumpversion` which wraps `bumpversion` + `dch` + `git commit --amend` into one transactional invocation so the version bump and changelog edit land in the same commit. The very first changelog entry on a new repo bootstraps with `SKIP_CHANGELOG_CHECK=1 git commit ...` since there is no prior version to bump from; document this in the bootstrap commit message.

**VERSION bumps**: Per release cycle, not per PR. See workspace `AGENTS.md` for the policy.

## CI / APT publishing

CI uses `hatlabs/shared-workflows` (note: NOT `halos-org/shared-workflows`). The default APT publish target is `hatlabs/apt.hatlabs.fi`, which is correct for this repo since it lives in the `hatlabs` org.

GitHub topics: `apt-package`, `halos`, `metapackage`.

## Quick Start

```bash
# Build package
./run build-debtools  # First time only — builds the debtools container
./run build-deb

# Check quality
./run lint-deb

# Bump version (transactional: bumps VERSION, runs dch, amends commit)
./run bumpversion patch

# Deploy to test server
./run deploy pi@halosdev.local
./run status pi@halosdev.local

# Clean build artifacts
./run clean
./run clean-debtools

# Install lefthook pre-commit hooks
./run install-hooks
```

Run `./run` with no arguments (or `./run help`) for the full target list with category groupings.

## Verification on a Live Device

```bash
# Install (manual migration path, or after pi-gen installs it on new builds)
sudo apt install halos-halpi2-desktop

# Confirm transitively pulled the HALPI2 branding
dpkg -l halos-halpi-desktop-branding | grep '^ii'

# Confirm HALPI2 branding is the resolved provider for the wallpaper virtual
apt-cache policy halos-desktop-wallpaper

# Confirm the HALPI2 wallpaper file is on disk
dpkg -L halos-halpi-desktop-branding | grep wallpapers

# Reverse the swap
sudo apt install halos-desktop-branding
```

This metapackage is not expected on HALPI2 headless devices (no `halos-desktop`) or on RPi5 devices (no `halos-halpi2`).

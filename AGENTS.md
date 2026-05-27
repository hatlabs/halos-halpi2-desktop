# halos-halpi2-desktop - Agentic Coding Guide

**LAST MODIFIED**: 2026-05-27

**Document Purpose**: Guide for AI assistants working on halos-halpi2-desktop.

## For Agentic Coding: Use the HaLOS Workspace

When using Claude Code or other AI assistants, work from the halos workspace repository for full context across all HaLOS repositories.

## About This Project

HALPI2 desktop variant metapackage. Single binary `halos-halpi2-desktop` with no content of its own — just a `debian/control` declaring `Depends: halos-halpi2, halos-desktop, halos-halpi-desktop-branding`.

Its job is to bias apt's resolution of the virtual `halos-desktop-wallpaper` on HALPI2 desktop devices toward `halos-halpi-desktop-branding` (HALPI2 artwork) rather than the generic `halos-desktop-branding`. The mechanism is straightforward Debian Recommends/Depends:

- `halos-halpi2` (in halos-org/halos-metapackages) declares `Recommends: halos-halpi2-desktop`.
- This metapackage's `Depends:` triple is the gating filter — only HALPI2 desktop systems satisfy it. On HALPI2 headless, `halos-desktop` is missing → apt skips the recommend.
- When the recommend fires, the metapackage's `Depends:` on `halos-halpi-desktop-branding` pulls in the HALPI2 artwork, which then satisfies `halos-desktop`'s `Depends: halos-desktop-wallpaper`.

The metapackage is also the future hook for any HALPI2-only desktop content (login screen branding, terminal palette, panel theming) — those packages get added to its `Depends:` and propagate to HALPI2 desktop devices via the same mechanism without affecting non-HALPI2 desktop installs.

## Repository Layout

```
.
├── debian/                Debian packaging (control, changelog, rules, source/format, copyright, lintian-overrides)
├── docker/                debtools container for local build
├── .github/               CI workflows (shared-workflows), local actions, lefthook scripts
├── run                    Build/lint commands
├── VERSION                Single source of truth for package version
├── .bumpversion.cfg       bumpversion config
└── lefthook.yml           Pre-commit hooks
```

No `usr/`, no `etc/`, no `sources/` — this is a pure metapackage with no installed payload.

## Cross-org references

This package lives in the `hatlabs` org because HALPI2 source content stays in `hatlabs` per workspace policy. Its `Depends:` includes `halos-halpi-desktop-branding` (hatlabs, same org — fine) and the halos-org packages `halos-halpi2` and `halos-desktop` (cross-org runtime dependency, resolved because both apt repos are configured on HaLOS devices).

`halos-halpi2`'s `Recommends:` on this package is the only halos-org → hatlabs reference; it's a soft recommend, not a hard build dep, so halos-org/halos-metapackages CI does not need access to hatlabs's apt repo.

## Git Workflow Policy

**MANDATORY**: PRs must ALWAYS have all checks passing before merging. No exceptions.

**Branch Workflow:** Never push to main directly — always use feature branches and PRs.

**Changelog Policy**: Never edit `debian/changelog` directly. Always use `./run bumpversion` which uses `dch` for proper RFC 2822 date formatting.

**VERSION bumps**: Per release cycle, not per PR. See workspace `AGENTS.md` for the policy.

## CI / APT publishing

CI uses `hatlabs/shared-workflows` (note: NOT `halos-org/shared-workflows`). The default APT publish target is `hatlabs/apt.hatlabs.fi`, which is correct for this repo since it lives in the `hatlabs` org.

## Quick Start

```bash
# Build package
./run build-debtools  # First time only — builds the debtools container
./run build-deb

# Check quality
./run lint-deb

# Clean build artifacts
./run clean
```

## Verification on a Live Device

```bash
# Install (after the apt.hatlabs.fi pipeline has published it)
sudo apt install halos-halpi2-desktop

# Confirm transitively pulled the right branding
dpkg -l halos-halpi-desktop-branding | grep '^ii'

# Confirm halos-desktop is satisfied via the HALPI2 provider
apt-cache policy halos-desktop-wallpaper

# Confirm halos-halpi-desktop-branding is the resolved provider
dpkg -L halos-halpi-desktop-branding | grep wallpapers
```

On a HALPI2 headless device, `halos-halpi2-desktop` should remain not-installed because its `Depends: halos-desktop` is unsatisfiable.

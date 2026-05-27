# halos-halpi2-desktop

HALPI2 desktop variant metapackage for HaLOS. Ships a single Debian binary, `halos-halpi2-desktop`, whose role is to pin HALPI2 branding as the resolved provider of the virtual `halos-desktop-wallpaper` on HALPI2 desktop devices.

Sibling packages:
- [`hatlabs/halos-halpi-desktop-branding`](https://github.com/hatlabs/halos-halpi-desktop-branding) — the actual HALPI2 wallpaper artifact.
- [`halos-org/halos-desktop-branding`](https://github.com/halos-org/halos-desktop-branding) — the generic HaLOS wallpaper artifact.
- [`halos-org/halos-metapackages`](https://github.com/halos-org/halos-metapackages) — `halos-halpi2` (which `Recommends` this package) and `halos-desktop` (which depends on the virtual `halos-desktop-wallpaper`).

## What it does

The metapackage's `Depends:` triple — `halos-halpi2`, `halos-desktop`, `halos-halpi-desktop-branding` — is the gating filter. Only HALPI2 desktop systems satisfy it; on HALPI2 headless systems `halos-desktop` is absent and apt skips the recommend silently.

`halos-halpi2` (in halos-org/halos-metapackages) `Recommends` this package. On `apt upgrade`:

| Device | `halos-halpi2` | `halos-desktop` | Recommend satisfiable? | Result |
|---|---|---|---|---|
| HALPI2 desktop | ✓ | ✓ | yes | metapackage pulled in → HALPI2 branding wins as `halos-desktop-wallpaper` provider |
| HALPI2 headless | ✓ | ✗ | no (`halos-desktop` missing) | skipped silently |
| RPi5 desktop | ✗ | ✓ | n/a (no `halos-halpi2` recommending it) | generic `halos-desktop-branding` wins |
| RPi5 headless | ✗ | ✗ | n/a | nothing changes |

The metapackage is the future home for any HALPI2-only desktop content (login screen branding, terminal palette, panel theming, …) — add such packages to its `Depends:` and they propagate via the same mechanism.

Why a metapackage rather than apt pinning: discoverability. Operators inspecting `dpkg -l` see `halos-halpi2-desktop` and understand the device variant immediately. A `/etc/apt/preferences.d/` pin would do the wallpaper job but is opaque.

## Development

```bash
./run build-debtools  # first time
./run build-deb
./run lint-deb
```

See `AGENTS.md` for the full development guide.

## License

MIT. See `LICENSE` and `debian/copyright`.

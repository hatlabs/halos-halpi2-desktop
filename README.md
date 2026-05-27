# halos-halpi2-desktop

HALPI2 desktop variant metapackage for HaLOS. Ships a single Debian binary, `halos-halpi2-desktop`, that marks a HaLOS installation as a HALPI2 desktop variant and pulls in the HALPI2-branded wallpaper as a hard dependency.

Sibling packages:
- [`hatlabs/halos-halpi-desktop-branding`](https://github.com/hatlabs/halos-halpi-desktop-branding) — the actual HALPI2 wallpaper artifact.
- [`halos-org/halos-desktop-branding`](https://github.com/halos-org/halos-desktop-branding) — the generic HaLOS wallpaper artifact.
- [`halos-org/halos-metapackages`](https://github.com/halos-org/halos-metapackages) — `halos-halpi2` and `halos-desktop`.

## What it does

When installed, this metapackage's `Depends:` triple — `halos-halpi2`, `halos-desktop`, `halos-halpi-desktop-branding` — pulls in the HALPI2 branding provider for the virtual package `halos-desktop-wallpaper` that `halos-desktop` requires. The result on the device: HALPI2-branded wallpaper instead of the generic one.

The package also serves as the future home for any HALPI2-only desktop content (login screen branding, terminal palette, panel theming) — add such packages to `Depends:` here and they propagate to HALPI2 desktop installations through this single hook.

## How it gets installed

**On new pi-gen images**: a substage in `halos-pi-gen` (see [halos-pi-gen#97](https://github.com/halos-org/halos-pi-gen/issues/97)) installs `halos-halpi2-desktop` at build time on HALPI2 desktop variants, using the same `dpkg -l halos-desktop` check pattern that `stage-halos-marine` already uses for the marine combination metapackages. New HALPI2 desktop images come with HALPI2 branding out of the box.

**On existing field devices**: there is no automatic injection. Operators who want HALPI2 branding on an existing HALPI2 desktop installation run:

```bash
sudo apt install halos-halpi2-desktop
```

This explicit install pulls in `halos-halpi-desktop-branding` and swaps it in as the provider for `halos-desktop-wallpaper`. Reversible the same way: `sudo apt install halos-desktop-branding`.

## Development

```bash
./run build-debtools  # first time
./run build-deb
./run lint-deb
```

See `AGENTS.md` for the full development guide.

## License

MIT. See `LICENSE` and `debian/copyright`.

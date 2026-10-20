---
name: nix-flake-package-update
description: Use this skill whenever the user asks to update or create a Nix flake, Home Manager, NixOS, or custom nixpkgs-style package, especially packages using fetchurl, GitHub release binaries, fetchFromGitHub, buildGoModule, version/hash bumps, or fixed-output derivations. It guides the agent to inspect existing package patterns, prefetch real sources to obtain correct Nix hashes instead of guessing, edit minimal package metadata, and verify with Nix parse/eval/build checks. Trigger even when the user simply says a tool has a new version and asks to update their Nix.
disable-model-invocation: true
---

# Nix Flake Package Update

Use this skill to update an existing Nix package or add a new package inside a flake, Home Manager config, NixOS module tree, overlay, or local `packages/` directory. The default scope is binary downloads via `fetchurl` and GitHub source packages via `fetchFromGitHub`; extend cautiously when the repository already uses another source mechanism.

The core habit: fixed-output hashes are evidence, not guesses. Download or prefetch the exact source that the derivation will use, record the resulting Nix hash, then prove the package evaluates and builds.

## First pass

1. Locate package definitions and registration points before editing.
   - Search for the package name, binary name, old version, `fetchurl`, `fetchFromGitHub`, `hash =`, `sha256 =`, `vendorHash`, overlays, and `home.packages` references.
   - Read the package file and one or two nearby packages to copy local style.
   - Identify whether the request is an update, a new package, or both.

2. Classify the source type.
   - `fetchurl` binary archive: direct tarball/zip/dmg/appimage/deb URL, often with per-platform URL and hash tables.
   - GitHub release binary: still usually `fetchurl`; use the exact release asset URL.
   - `fetchFromGitHub`: source archive from owner/repo/rev, often used with language builders.
   - `buildGoModule`: source hash and `vendorHash` may both need updates.

3. Confirm the upstream release and URL shape.
   - Prefer existing URL templates when they still work.
   - Check current release tags/assets when a filename or suffix may have changed.
   - Do not silently switch mirrors, domains, archive formats, or platform coverage unless the current source is broken or the user asked for it. If switching is needed, mention it in the final summary.

## Hash workflow

For `fetchurl` and GitHub release binaries, prefetch the exact final URL:

```bash
nix store prefetch-file --hash-type sha256 --json "https://example.com/tool-1.2.3-linux-x86_64.tar.gz"
```

Use the returned `hash` field directly when the package uses SRI hashes:

```nix
hash = "sha256-...=";
```

If the existing package uses legacy base32 `sha256 = "...";`, either keep the style by using the matching prefetch output/conversion or modernize only if the surrounding code already accepts SRI style. Avoid broad style churn.

For `fetchFromGitHub`, prefetch the source derivation shape when possible:

```bash
nix-prefetch-github owner repo --rev v1.2.3
```

If `nix-prefetch-github` is unavailable, temporarily use a fake hash only to let Nix report the expected hash, then replace it immediately. Do not leave fake hashes in the final diff.

For `buildGoModule`, expect two hashes:

- `src.hash` for the source archive.
- `vendorHash` for vendored Go dependencies. Update `vendorHash` only when the build reports it changed, then rebuild to confirm.

For multi-platform binary packages, compute a hash per enabled platform. Do not invent hashes for commented or unsupported platforms. If only the current host platform is enabled, update only that host's hash.

## Editing rules

Keep the diff minimal and aligned with the repository's existing conventions.

For updates:

- Change `version`, `rev`, URL suffixes, and hashes that are actually tied to the new release.
- Preserve `pname`, `meta`, install phases, wrappers, and module references unless the release requires a structural change.
- Check whether `passthru.updateScript`, `nix-update`, `niv`, or generated sources exist, but do not assume they work. If an update script is referenced but missing or broken, update manually and mention it.

For new packages:

- Copy the closest existing package pattern in the same repo.
- Add the package to the local registry/overlay (`packages.nix`, overlay file, or equivalent) and to `home.packages` or modules only if the user asked for installation.
- Include `meta.homepage`, `meta.description`, `meta.license` when known, `meta.mainProgram` for CLI tools, and `platforms` matching the enabled source assets.

## Verification

Run checks from cheap to expensive. Prefer commands that avoid writing a `result` symlink when possible.

1. Parse changed Nix files:

```bash
nix-instantiate --parse path/to/default.nix
```

2. Evaluate the package or Home Manager package list:

```bash
nix eval --impure --raw --expr 'let flake = builtins.getFlake "path:/abs/repo"; pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; overlays = [ flake.overlays.default ]; }; in pkgs.package-name.version'
```

For Home Manager package membership:

```bash
nix eval --impure --expr 'let flake = builtins.getFlake "path:/abs/repo"; hm = flake.homeConfigurations.${builtins.getEnv "USER"}; in builtins.any (pkg: (pkg.pname or pkg.name or "") == "package-name") hm.config.home.packages'
```

3. Build the package:

```bash
nix build --no-link --impure --expr 'let flake = builtins.getFlake "path:/abs/repo"; pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; overlays = [ flake.overlays.default ]; }; in pkgs.package-name'
```

4. If the package provides a CLI and building is cheap, optionally smoke-test the binary from the build result or derivation output. Do not run GUI apps just to prove they launch unless the user explicitly wants manual QA.

If LSP diagnostics for `.nix` files fail because `nixd` is missing or unavailable, do not treat that as a code error. Fall back to the Nix parse/eval/build checks above.

## Final report

Keep the final summary short:

- Package name and old -> new version, or new package name.
- Files changed.
- Hashes obtained by prefetch, with the source type or URL when useful.
- Verification commands that passed.
- Any notable caveat, such as a source URL domain change, skipped unsupported platforms, missing update script, or pre-existing unrelated worktree changes.

Avoid dumping full build logs unless a failure matters.

## Common pitfalls

- Do not guess hashes or copy hashes from a different asset, platform, archive format, or version.
- Do not use the GitHub source archive hash for a release binary asset.
- Do not forget `vendorHash` for Go packages.
- Do not update commented platform hashes unless you actually fetched those assets and intend to support them.
- Do not use `nix build` in parallel without `--no-link`; parallel builds can fight over the `result` symlink.
- Do not commit, push, or run Home Manager switch unless the user explicitly asks.

# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-gnome` is a small SIMP Puppet module that installs a minimal **GNOME
desktop environment** and applies a hardened default configuration to it. It
installs a curated list of GNOME packages, then (when `gnome::configure` is
true) applies system-wide `dconf` settings — via the `simp/dconf` module — that
lock down media auto-mounting/auto-run, disable the Ctrl-Alt-Del logout binding
and the physical power-button action, enforce a 15-minute idle screen lock, and
enable the screensaver lock; it also installs a set of `polkit` authorization
policies (via `simp/polkit`) allowing any user to shut down or restart the
system (`manifests/init.pp:1`, `manifests/config.pp:1`, `data/common.yaml:12-73`).

The module does not force a state beyond installing packages and writing dconf
/polkit configuration; all of the actual hardening values are data-driven and
live in `data/common.yaml` (overridable through Hiera deep merge).

### Business logic

The module has one public class and one private class; there are no defines.

- **`gnome` (`manifests/init.pp:36-56`)** — Public entry class (consumers
  `include 'gnome'`; it is *not* `assert_private()`'d). It calls
  `simplib::assert_metadata($module_name)` (`init.pp:44`) then installs packages
  and optionally delegates configuration. Parameters (`init.pp:37-41`, all but
  the last are `default`-less and supplied from module data):
  - `$configure` (`Boolean`, **no default**) — master switch for applying the
    dconf/polkit configuration; from `data/common.yaml:12` (`true`).
  - `$dconf_hash` (`Hash[String[1], Dconf::SettingsHash]`, **no default**) — the
    nested dconf settings tree, keyed by profile name; from `data/common.yaml:32`.
  - `$dconf_profile_hierarchy` (`Dconf::DBSettings`, **no default**) — the dconf
    db priority/profile definition; from `data/common.yaml:27`.
  - `$packages` (`Hash[String[1], Optional[Hash]]`, **no default**) — the package
    list to install; setting it **overrides** (deep-merged) the default list;
    from `data/common.yaml:14`. A per-package `ensure` may be supplied in each
    entry's hash (`init.pp:20-30` docstring).
  - `$package_ensure` (`Simplib::PackageEnsure`) — the **only** parameter with a
    default: `simplib::lookup('simp_options::package_ensure', { 'default_value'
    => 'installed' })` (`init.pp:41`). Applied as the `ensure` default for every
    installed package; overridden per-package by `$packages`.

  Control flow and resources:
  - `simplib::install { 'gnome' }` (`init.pp:46-49`) — installs `$packages` with
    `defaults => { 'ensure' => $package_ensure }`.
  - **configure branch** (`init.pp:51-55`): if `$configure`, `include
    'gnome::config'` and order it after the install
    (`Simplib::Install['gnome'] -> Class['gnome::config']`).

- **`gnome::config` (`manifests/config.pp:4-31`)** — Private class
  (`assert_private()` at `config.pp:5`); only reachable via `gnome`. It:
  - `dconf::profile { 'GNOME' }` (`config.pp:7-10`) with `target => 'user'` and
    `entries => $gnome::dconf_profile_hierarchy`.
  - Iterates `$gnome::dconf_hash.each |$profile_name, $settings|` and declares a
    `dconf::settings { "GNOME dconf settings: ${profile_name}" }` per profile
    with `profile => $profile_name, settings_hash => $settings`
    (`config.pp:12-17`).
  - `polkit::authorization::basic_policy { ... }` (`config.pp:19-30`) — a default
    of `ensure => 'present', priority => 10, result => 'yes'`, then two policies:
    "Allow anyone to shutdown system"
    (`org.freedesktop.consolekit.system.stop`) and "Allow anyone to restart
    system" (`org.freedesktop.consolekit.system.restart`).

### Gotchas / non-obvious details

- **The `Dconf::*` parameter types are not defined in this module.**
  `Dconf::SettingsHash` and `Dconf::DBSettings` (`init.pp:38-39`) come from the
  `simp/dconf` dependency — this module has no `types/` directory of its own.
- **Setting `gnome::packages` overrides the default list**, it does not append
  to it (`init.pp:23` docstring). Both `gnome::packages` and `gnome::dconf_hash`
  are declared as **deep-merge** with `knockout_prefix: '--'` in
  `data/common.yaml:2-10`, so Hiera layers merge into (and can remove keys from)
  the defaults rather than replacing them wholesale.
- **The polkit policies weaken security by design**: they allow *any* user to
  shut down or restart the machine (`config.pp:24-29`). This is intentional for
  a desktop but worth flagging.
- **`gnome::config` is a no-op unless `$configure` is true** (`init.pp:51`);
  with `gnome::configure: false` the module only installs packages.
- **The `dconf_hash` profile keys must match `dconf_profile_hierarchy`** — the
  inline comment in `data/common.yaml:33` notes the `simp_gnome` key must match
  what is declared under `dconf_profile_hierarchy`.
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  the manifest consumes the `simp_options::*` seam via `simplib::lookup`
  (provided by `simp/simplib`). `simp_options` appears only as a fixture
  (`.fixtures.yml:8`).
- **`templates/dconf.erb` appears unused by the manifests.** Neither `gnome` nor
  `gnome::config` references it (the dconf writing is delegated to
  `simp/dconf`); it is a leftover/support template.

## The `simp_options` / `simplib::lookup` seam

The module has a **single** `simp_options` seam call, in `manifests/init.pp`:

| Line | Key | `default_value` |
|------|-----|-----------------|
| `init.pp:41` | `simp_options::package_ensure` | `'installed'` |

All other configuration comes through plain module-data Hiera lookups of the
class parameters (`gnome::configure`, `gnome::packages`, `gnome::dconf_hash`,
`gnome::dconf_profile_hierarchy`) resolved against `data/` via `hiera.yaml`, not
through `simp_options`. Keep routing the package-ensure toggle through
`simplib::lookup('simp_options::package_ensure', { 'default_value' => ... })`
with an explicit default rather than assuming `simp_options` is included.

## Dependencies

Module dependencies (from `metadata.json`):

- `simp/dconf` `>= 0.0.1 < 1.0.0` (provides the `dconf::profile` /
  `dconf::settings` defines and the `Dconf::SettingsHash` / `Dconf::DBSettings`
  data types)
- `simp/polkit` `>= 6.1.0 < 7.0.0` (provides
  `polkit::authorization::basic_policy`)
- `simp/simplib` `>= 4.9.0 < 5.0.0` (provides `simplib::lookup`,
  `simplib::install`, `simplib::assert_metadata`, and the
  `Simplib::PackageEnsure` type)
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0`

Optional dependencies: none (`metadata.json` has no `simp.optional_dependencies`).

Fixture-only dependencies (from `.fixtures.yml`, present for test compilation,
not runtime deps): `concat`, `inifile`, `simp_options` (plus the runtime deps
`dconf`, `polkit`, `simplib`, `stdlib` are also checked out as fixtures).

Runtime requirement (from `metadata.json` `requirements`): `puppet
>= 7.0.0 < 9.0.0`. (SIMP is migrating Puppet → OpenVox; when
`metadata.json` switches this to `openvox`, update this line to match.)

Supported OS matrix (from `metadata.json`): CentOS 7/8/9; RedHat 7/8/9;
OracleLinux 7/8/9; Rocky 8/9; AlmaLinux 8/9.

## Repository layout

- `manifests/init.pp` — the public `gnome` class (package install + optional
  configure delegation).
- `manifests/config.pp` — the private `gnome::config` class (dconf profile,
  dconf settings, polkit policies).
- `data/common.yaml` — module defaults: `gnome::configure`, the package list,
  the dconf profile hierarchy, the full dconf hardening hash, and the deep-merge
  `lookup_options`.
- `data/os/*.yaml` — per-OS `gnome::packages` overrides
  (`AlmaLinux-8/9`, `RedHat-7`, `RedHat-7.4`, `RedHat-8/9`, `Rocky-8/9`).
- `hiera.yaml` — module data hierarchy (v5): OS family+major.minor → OS
  family+major → common.
- `templates/dconf.erb` — a small ERB template that does not appear to be
  referenced by the manifests (see Gotchas).
- `metadata.json` — deps, OS matrix, Puppet requirement.
- `spec/classes/gnome_spec.rb` — rspec-puppet unit tests.
- `spec/acceptance/suites/default/00_default_spec.rb` — beaker acceptance suite
  (`include 'gnome'`, checks idempotency and that `gnome-session` is installed);
  nodesets under `spec/acceptance/nodesets/` (`default.yml`, `centos.yml`,
  `oel.yml`).
- `REFERENCE.md` — generated Puppet Strings reference.
- No `types/` or `lib/` — this module defines no custom data types and no Ruby
  types/providers/functions/facts. The `Dconf::*` and `Simplib::*` types it uses
  come from the dependencies above.
- **Acceptance does NOT run in CI:** `.github/workflows/pr_tests.yml` runs only
  `puppet-syntax`, `puppet-style`, `ruby-style`, `file-checks`, `releng-checks`,
  and `spec-tests` (`bundle exec rake spec`, Puppet 7.x and 8.x matrix). There is
  no `acceptance` job invoking `rake beaker:suites`, even though a beaker suite
  and nodesets exist in-tree.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run the single class spec
bundle exec rspec spec/classes/gnome_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite (not run in CI; run locally)
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`. Rubocop is pinned to `~> 1.88.0`. The tested
Puppet range is `>= 7 < 9`.

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on the classes —
  they drive `REFERENCE.md`. Regenerate `REFERENCE.md` after changing docs or
  parameters.
- Keep the package list, dconf settings, and profile hierarchy in module data
  (`data/*.yaml`), not hard-coded in the manifests; respect the deep-merge
  `lookup_options` (`data/common.yaml:2-10`) so consumers can layer overrides.
- Keep `gnome::config` private (`assert_private()`) — it is an implementation
  detail of `gnome`, reached only through the configure branch.
- Continue routing the package-ensure toggle through
  `simplib::lookup('simp_options::package_ensure', { 'default_value' => ... })`
  rather than assuming `simp_options` is included.
- `Gemfile`, `.gitignore`, and `.github/workflows/pr_tests.yml` carry a
  **puppetsync** notice — they are baseline-managed and the next sync overwrites
  local edits. Push changes to those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in `manifests/`.

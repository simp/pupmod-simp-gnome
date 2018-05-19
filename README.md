[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/gnome.svg)](https://forge.puppetlabs.com/simp/gnome)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/gnome.svg)](https://forge.puppetlabs.com/simp/gnome)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-gnome.svg)](https://travis-ci.org/simp/pupmod-simp-gnome)

#### Table of Contents

* [Description](#description)
  * [This is a SIMP module](#this-is-a-simp-module)
* [Setup](#setup)
* [Usage](#usage)
  * [Switching to MATE](#switching-to-mate)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development](#development)

## Description

`gnome` is a Puppet module that installs and manages GNOME and/or MATE, as
well as `dconf` settings on Gnome 3/MATE and `gconf` settings on Gnome 2.

### This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com)
a compliance-management framework built on Puppet.

If you find any issues, they may be submitted to our [bug tracker](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but
it can be used independently:

 * When included within the SIMP ecosystem, security compliance settings will
   be managed from the Puppet server.
 * If used independently, all SIMP-managed security subsystems are disabled by
   default and must be explicitly opted into by administrators.  See
   [simp_options](https://github.com/simp/pupmod-simp-simp_options) for more
   detail.

## Setup

To use the module with default settings, just include the class:

```ruby
include 'gnome'
```

## Usage

You can disable configuration of gnome by setting `gnome::configure` to false.
The module will then only install Gnome.

This module makes heavy use of data. The `dconf` and `gconf` settings are all
data-driven, and the defaults can be seen in the
[common.yaml](data/common.yaml).

You can use the knockout prefix of `--` in front of a key to remove it from the
Hash, like this:

```yaml
gnome::dconf_hash:
  --org/gnome/settings-daemon/plugins/media-keys:
  org/gnome/desktop/media-handling:
    --automount-open:
```

Or you can simply set it to the desired value.

`Dconf` settings are locked by default so that users can't change them.

This can be disabled on a per setting basis, like in this entry for wallpaper
in `gnome::dconf_hash`:

```yaml
gnome::dconf_hash:
  org/gnome/desktop/background:
    picture-uri:
      value: file:///usr/local/corp/puppies.jpg
      lock: false
```

### Switching to MATE

In some cases, such as when using `x2go` as supplied for EL7, you may not be
able to use a compositing window manager like GNOME 3 and will need to fall
back to an alternative.

[MATE](https://mate-desktop.org) is a continuation of the GNOME 2 project but
supports the `dconf` subsystem allowing for an easier configuration experience.

While GNOME and MATE do not conflict and can be enabled together, if you wish
to use MATE and not GNOME, you simply need to set the following:

```yaml
gnome::enable_gnome: false
gnome::enable_mate: true
```

NOTE: Disabling GNOME will not remove any packages from your system so it will
remain a valid window manager option if installed. It is recommended that you
keep managing GNOME if you have already started to do so.

## Reference

See the [API documentation](http://www.puppetmodule.info/github/simp/pupmod-simp-gnome/master)
or run `puppet strings` for full details.

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux
and compatible distributions, such as CentOS.

Please see the [`metadata.json` file](./metadata.json) for the most up-to-date
list of supported operating systems, Puppet versions, and module dependencies.

This module is compatible with GDM v2, v3.

## Development

Please read our [Contribution Guide] (http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html)

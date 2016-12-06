[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-gnome.svg)](https://travis-ci.org/simp/pupmod-simp-gnome) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-6.0.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-6.0.*-orange.svg)

#### Table of Contents
1. [Description](#description)
2. [Setup - The basics of getting started with gnome](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

gnome is a Puppet module that installs and manages gnome

### This is a SIMP module
This module is a component of the [System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP), a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but it can be used independently:

 * When included within the SIMP ecosystem, security compliance settings will be managed from the Puppet server.
 * If used independently, all SIMP-managed security subsystems are disabled by default and must be explicitly opted into by administrators.  Please review the `$client_nets`, `$enable_*` and `$use_*` parameters in `manifests/init.pp` for details.

## Setup

To use the module with default settings, just include it in your site yaml.

```yaml
classes:
  - gnome
```

## Usage

You can enable/disable management of the screensaver and related dconf settings,
by toggling:
  * gnome::enable_screensaver

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux and compatible distributions, such as CentOS. Please see the [`metadata.json` file](./metadata.json) for the most up-to-date list of supported operating systems, Puppet versions, and module dependencies.

This module is compatible with GDM v2, v3.

## Development

Please read our [Contribution Guide] (http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html)

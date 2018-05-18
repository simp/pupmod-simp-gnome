# Installs and configures a minimal Gnome environment
#
# @param configure
#   Use the module to configure Gnome
#
#   @see data/common.yaml
#
# @param gconf_hash
#   Settings specific to gconf and Gnome 2
#
#   @see data/common.yaml
#
# @param dconf_hash
#   Settings specific to dconf, Gnome 3, and MATE
#
#   @see data/common.yaml
#   @see https://wiki.gnome.org/Projects/dconf/SystemAdministrators
#
# @param dconf_profile_hierarchy
#   Dconf db priority
#
#   @see https://help.gnome.org/admin/system-admin-guide/stable/dconf.html.en
#   @see https://wiki.gnome.org/Projects/dconf/SystemAdministrators
#
# @param enable_gnome
#   Enables the GNOME window manager
#
#   * Set this to ``false`` and ``$enable_mate`` to ``true`` if you only want
#     to use MATE
#
#   @see data/common.yaml
#
# @param packages
#   A Hash of packages to be installed
#
#   * NOTE: Setting this will *override* the default package list
#   * The ensure value can be set in the hash of each package, like the example
#     below:
#
#   @example Override packages
#     { 'gedit' => { 'ensure' => '3.14.3' } }
#
#   @see data/common.yaml
#
# @param enable_mate
#   Enable configuration of the MATE window manager environment in systems that
#   support it
#
# @param mate_packages
#
#   A Hash of packages to be installed for MATE, if enabled
#
#   * Follows the same format as ``$packages`` above
#
# @param package_ensure
#   The SIMP global catalyst to set the default `ensure` settings for packages
#   managed with this module. Will be overwitten by $packages.
#
class gnome (
  Boolean                         $configure,
  Gnome::GconfSettings            $gconf_hash,
  Gnome::DconfSettings            $dconf_hash,
  Gnome::DconfDBSettings          $dconf_profile_hierarchy,
  Boolean                         $enable_gnome,
  Hash[String[1], Optional[Hash]] $packages,
  Boolean                         $enable_mate,
  Hash[String[1], Optional[Hash]] $mate_packages,
  Simplib::PackageEnsure          $package_ensure           = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  simplib::assert_metadata($module_name)

  unless $enable_gnome or $enable_mate {
    fail('You must set either $enable_gnome or $enable_mate')
  }

  # MATE is the extension of GNOME 2 which is native to EL < 7
  # This logic will need to get more complex if we start supporting non-RHEL
  # derived operating systems
  if $enable_gnome or ( $enable_mate and ($facts['os']['release']['major'] < '7')) {
    gnome::install { 'gnome':
      packages       => $packages,
      package_ensure => $package_ensure
    }

    if $configure {
      Gnome::Install['gnome'] -> Class['gnome::config']
    }
  }

  if $enable_mate and ($facts['os']['release']['major'] > '6') {
    gnome::install { 'mate':
      packages       => $mate_packages,
      package_ensure => $package_ensure
    }

    if $configure {
      Gnome::Install['mate'] -> Class['gnome::config']
    }
  }

  if $configure {
    include 'gnome::config'
  }
}

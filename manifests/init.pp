# Installs and configures a minimal Gnome environment
#
# @param configure
#   Use the module to configure Gnome
#
#   @see data/common.yaml
#
# @param gconf_hash
#   This parameter has be depricated.
#
# @param dconf_hash
#   dconf settings specific to Gnome 3
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
# @param package_ensure
#   The SIMP global catalyst to set the default `ensure` settings for packages
#   managed with this module. Will be overwitten by $packages.
#
class gnome (
  Boolean                              $configure,
  Hash[String[1], Dconf::SettingsHash] $dconf_hash,
  Dconf::DBSettings                    $dconf_profile_hierarchy,
  Hash[String[1], Optional[Hash]]      $packages,
  Optional[Hash]                       $gconf_hash = undef,
  Simplib::PackageEnsure               $package_ensure           = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  simplib::assert_metadata($module_name)

  simplib::install { 'gnome':
    packages => $packages,
    defaults => { 'ensure' => $package_ensure }
  }

  if $configure {
    include 'gnome::config'

    Simplib::Install['gnome'] -> Class['gnome::config']
  }
}

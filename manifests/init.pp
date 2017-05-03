# Installs basic packages for gnome environment.
#
# @param set_banner If true, set the banner seen at the login screen.
# @param banner The banner to set if $set_banner is true.
# @param configure If false, no Gnome settings will be touched.
# @param gconf_hash Settings specific to gconf and Gnome 2.
#   @see data/common.yaml:76
# @param dconf_hash Settings specific to dcofn and Gnome 3.
#   @see data/common.yaml:33
# @param dconf_profile_hierarchy Dconf db priority
#   @see https://help.gnome.org/admin/system-admin-guide/stable/dconf.html.en
# @param packages A hash of packages to be installed on the system. The ensure
#   value can be set in the hash of each package, like the example below:
#
#   ```
#   { 'gedit' => { 'ensure' => '3.14.3' } }
#   ```
#
# @param package_ensure The SIMP global catalyst to set the default `ensure` settings
#   for packages managed wit this module. Will be overwitten by $packages.
#
class gnome (
  Boolean $configure,
  Boolean $set_banner,
  String $banner,
  Gnome::Gconf $gconf_hash,
  Gnome::Dconf $dconf_hash,
  Gnome::Dconfdb $dconf_profile_hierarchy,
  Hash[String,Optional[Hash]] $packages,
  String $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  include 'gnome::install'

  if $configure {
    include 'gnome::config'
    Class['gnome::install'] -> Class['gnome::config']
  }

}

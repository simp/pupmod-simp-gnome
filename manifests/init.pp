# Installs basic packages for gnome environment.
#
# @param enable_screensaver Whether or not to include gnome::screensaver
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class gnome (
  Boolean $enable_screensaver = true,
  String  $package_ensure     = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  if $enable_screensaver {
    include '::gnome::screensaver'
  }

  # This should be a case statement using the gdm_version fact, but it will
  # be left to toggle on major oc version to reduce the number of changes
  # required on the second run of the module.
  if $facts['os']['release']['major'] >= '7' {
    $package_list = [
      'alacarte',
      'at-spi2-atk',
      'control-center',
      'gnome-desktop3',
      'gnome-session',
      'gnome-session-xsession',
      'gnome-settings-daemon',
      'gnome-terminal',
      'gnome-user-docs',
      'im-chooser',
      'libgnome',
      'libgnomeui',
      'nautilus',
      'orca',
      'yelp',
    ]
  } else {
    $package_list = [
      'alacarte',
      'at-spi',
      'gnome-panel',
      'gnome-session',
      'gnome-session-xsession',
      'gnome-settings-daemon',
      'gnome-terminal',
      'gnome-user-docs',
      'im-chooser',
      'libgnome',
      'libgnomeui',
      'nautilus',
      'nautilus-open-terminal',
      'orca',
      'yelp'
    ]
  }

  # Basic useful packages
  $package_list_before = $enable_screensaver ? {
    true    => Class['::gnome::screensaver'],
    default => undef
  }

  package { $package_list :
    ensure => $package_ensure,
    before => $package_list_before
  }

  if !defined(Package['gdm']) {
    package { 'gdm': ensure => $package_ensure }
  }

}

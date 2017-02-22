# Installs basic packages for gnome environment.
#
# @param enable_screensaver Whether or not to include gnome::screensaver
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class gnome(
  Boolean $enable_screensaver = true,
) {

  if $enable_screensaver {
    include '::gnome::screensaver'
  }

  # This should be a case statement using the gdm_version fact, but it will
  # be left to toggle on major oc version to reduce the number of changes
  # required on the second run of the module.
  if $facts['os']['release']['major'] == '6' {
    $package_list = [
      'alacarte',
      'at-spi2-atk',
      'control-center',
      'gnome-backgrounds',
      'gnome-color-manager',
      'gnome-classic-session',
      'gnome-desktop3',
      'gnome-session',
      'gnome-session-xsession',
      'gnome-settings-daemon',
      'gnome-terminal',
      'im-chooser',
      'libgnome',
      'libgnomeui',
      'metacity',
      'nautilus',
      'nautilus-open-terminal',
      'orca',
      'yelp',
    ]
  } else {
    $package_list = [
      'alacarte',
      'gnome-shell',
      'gnome-session-xsession',
      'gnome-terminal',
      'im-chooser',
      'nautilus',
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
    ensure => 'latest',
    before => $package_list_before
  }

  if !defined(Package['gdm']) {
    package { 'gdm': ensure => latest }
  }

}

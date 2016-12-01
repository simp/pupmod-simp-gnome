# == Class: gnome
#
# Installs basic packages for gnome environment.
#
# == Parameters
#
# [*include_sec*]
#   Whether or not to use the built-in sec class
#
# [*include_firefox*]
#   Whether or not to include ::mozilla::firefox
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class gnome(
    $include_sec = true,
    $include_firefox = true
) {
  validate_bool($include_firefox)
  validate_bool($include_sec)

  if $include_firefox {
    include '::mozilla::firefox'
  }

  if $include_sec {
    include '::gnome::sec'
  }

  if ( versioncmp($::operatingsystemmajrelease, '6')  > 0 ) {
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
      'at-spi',
      'control-center',
      'gnome-applets',
      'gnome-mag',
      'gnome-panel',
      'gnome-power-manager',
      'gnome-screensaver',
      'gnome-session',
      'gnome-terminal',
      'gnome-user-docs',
      'gnome-utils',
      'im-chooser',
      'nautilus',
      'nautilus-open-terminal',
      'orca',
      'sabayon-apply',
      'yelp'
    ]
  }

  if !defined(Package['gdm']) {
    package { 'gdm': ensure => latest }
  }

  # Basic useful packages
  $package_list_before = $include_sec ? { true => Class['::gnome::sec'], default => undef}
  package { $package_list :
    ensure => 'latest',
    before => $package_list_before
  }

}

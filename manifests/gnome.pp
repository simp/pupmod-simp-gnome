# == Class: windowmanager::gnome
#
# Installs basic packages for gnome environment.
#
# == Parameters
#
# [*include_sec*]
#   Whether or not to use the built-in sec class
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class windowmanager::gnome(
    $include_sec = true
) inherits windowmanager {

  if $include_sec {
    include 'windowmanager::gnome::sec'
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

  # Basic useful packages
  package { $package_list :
      ensure => 'latest'
  }

  validate_bool($include_sec)
}

# class gnome
#
# Installs basic packages for gnome environment.
#
# == Parameters
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
  $package_list_before = $enable_screensaver ? { true => Class['::gnome::screensaver'], default => undef}
  package { $package_list :
    ensure => 'latest',
    before => $package_list_before
  }

}

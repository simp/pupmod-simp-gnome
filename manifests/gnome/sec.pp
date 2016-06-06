# == Class: windowmanager::gnome::sec
#
# Some default tweaks for securing Gnome.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class windowmanager::gnome::sec {
  compliance_map()

  if ( versioncmp($::operatingsystemmajrelease, '6') > 0 ) {
    # TODO: Screensaver settings here
  } else {
    gconf { 'screensaver_enabled':
      value   => true,
      type    => 'bool',
      schema  => 'mandatory',
      require => Package['gnome-screensaver']
    }

    gconf { 'screensaver_timeout':
      value   => '15',
      type    => 'int',
      require => Package['gnome-screensaver']
    }

    gconf { 'screensaver_lock':
      value   => true,
      type    => 'bool',
      schema  => 'mandatory',
      require => Package['gnome-screensaver']
    }
  }

  # If gdm is greater than 3, then we need to use dconf to secure the desktop	
  if ( versioncmp($::gdm_version, '3') > 0 ) {
    include 'windowmanager::gnome::dconf'
  }
}

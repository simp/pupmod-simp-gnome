# Some default tweaks for securing Gnome.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class gnome::screensaver {

  if $facts['gdm_version'] and ( versioncmp($facts['gdm_version'], '3') < 0 ) {
    # gnome screen saver is not used past GDM version 3.  The screen saver was
    # encorporated into gdm and dconf is used to configure it in later versions.

    package { 'gnome-screensaver':
      ensure => latest,
    }

    gconf { 'screensaver_enabled':
      value  => true,
      type   => 'bool',
      schema => 'mandatory',
    }

    gconf { 'screensaver_timeout':
      value => '15',
      type  => 'int',
    }

    gconf { 'screensaver_lock':
      value  => true,
      type   => 'bool',
      schema => 'mandatory',
    }
  } else {
  # If gdm is greater than 3, then we need to use dconf to secure the desktop
    include '::gnome::dconf'
  }
}

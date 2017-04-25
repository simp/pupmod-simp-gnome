# Some default tweaks for securing Gnome.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class gnome::screensaver (
  String $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  if $facts['gdm_version'] {
    if ( versioncmp($facts['gdm_version'], '3') < 0 ) {
      # gnome screen saver is not used past GDM version 3.  The screen saver was
      # encorporated into gdm and dconf is used to configure it in later versions.

      package { ['gnome-screensaver','GConf2'] :
        ensure => $package_ensure,
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
    }
    else {
      # If gdm is greater than 3, then we need to use dconf to secure the desktop
      package { 'dconf':
        ensure => $package_ensure,
        before => Class['gnome::dconf']
      }
      include 'gnome::dconf'
    }
  }
}

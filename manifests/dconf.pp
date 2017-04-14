# Uses dconf to configure settings in gnome 3 and higher.
#
# @param profile_list A list of profiles used to ensure the directories are
#   created. Should probably add a check to ensure you can't use a profile
#   value that is not first defined here.
#
# @param base The dconf directory.  This really shouldn't change.
#
# @param banner The banner to be displayed at login. You need to escape special characters
#   and add new line characters manually.
#
# @author Ralph Wright <rwright@onyxpoint.com>
#
class gnome::dconf (
  Array[String]        $profile_list = ['simp','gdm'],
  Stdlib::Absolutepath $base         = '/etc/dconf',
  Optional[String]     $banner       = undef
) {
  $_banner = $banner ? {
    String  => $banner,
    default => @(EOF)
      --------------------------------- ATTENTION ----------------------------------

                               THIS IS A RESTRICTED COMPUTER SYSTEM

      This computer system, and all related equipment, networks, and
      network devices are provided for authorised use only.  All
      systems controlled by this organisation will be monitored for
      all lawful purposes.  Monitoring includes the totality of the
      operating system and connected networks.No events on this
      system are excluded from record and there are no exclusions
      from this policy.

      Use of this system constitutes consent to full monitoring of
      your activities for use by the authorised monitoring organisation.
      Unauthorised use of this system, including uninvited connections,
      may subject you to criminal prosecution.

      The data collected from this system may be used for any purpose by
      the collecting organisation.  If you do not agree to this
      monitoring, discontinue use of the system IMMEDIATELY.

                               THIS IS A RESTRICTED COMPUTER SYSTEM

      --------------------------------- ATTENTION ----------------------------------
      |EOF
  }

  # Create an array of directories based on profile names
  $_dir       = $profile_list.map |$profile| { "/etc/dconf/db/${profile}.d" }
  $_locks_dir = $profile_list.map |$profile| { "/etc/dconf/db/${profile}.d/locks" }

  file { $_dir + $_locks_dir :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  # Ensure the SIMP profile is first
  # Should probably move this to a template
  file { '/etc/dconf/profile/user':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "system-db:simp\nuser-db:user\nsystem-db:local\nsystem-db:site\nsystem-db:distro",
  }

  # Everything below this sets the actual values we care about

  # Prevent mount points from being automatically created
  gnome::dconf::add { 'automount':
    profile => 'simp',
    path    => 'org/gnome/desktop/media-handling',
    key     => 'automount',
    value   => false
  }

  # Prevent automounted devices from opening automatically
  gnome::dconf::add { 'automount_open':
    profile => 'simp',
    path    => 'org/gnome/desktop/media-handling',
    key     => 'automount-open',
    value   => false
  }

  # Prevent automounted devices from executing automatically
  gnome::dconf::add { 'autorun':
    profile => 'simp',
    path    => 'org/gnome/desktop/media-handling',
    key     => 'autorun-never',
    value   => false
  }

  # Ensures ctr-alt-del is not used for logout
  gnome::dconf::add { 'ctrl_alt_del':
    profile => 'simp',
    path    => 'org/gnome/settings-daemon/plugins/media-keys',
    key     => 'logout',
    # Setting this to an empty string causes the key sequence to be ignored
    value   => "''"
  }

  # Removes Shutdown From Login Screen
  gnome::dconf::add { 'shutdown_login_screen':
    profile => 'simp',
    path    => 'org/gnome/login-screen',
    key     => 'disable-restart-buttons',
    value   => true
  }

  # Ensure gnome does not react to the physical machine's power buttons
  gnome::dconf::add { 'power_button_action':
    profile => 'simp',
    path    => 'org/gnome/settings-daemon/plugins/power',
    key     => 'active',
    value   => false
  }

  # Activate the idle timer
  gnome::dconf::add { 'screen_saver_idle':
    profile => 'simp',
    path    => 'org/gnome/desktop/screensaver',
    key     => 'idle-activation-enabled',
    value   => true
  }

  # Set the idle time to 15 minutes
  gnome::dconf::add { 'screen_saver_idle_time':
    profile => 'simp',
    path    => 'org/gnome/desktop/session',
    key     => 'idle-delay',
    # This MUST be set to an unsigned integer or the value will be ignored.
    value   => 'uint32 900'
  }

  # Activate the lock
  gnome::dconf::add { 'lock_enabled':
    profile => 'simp',
    path    => 'org/gnome/desktop/screensaver',
    key     => 'lock-enabled',
    value   => true
  }

  # Ensure there is no delay in the screen lock
  gnome::dconf::add { 'lock_delay':
    profile => 'simp',
    path    => 'org/gnome/desktop/screensaver',
    key     => 'lock-delay',
    value   => '0'
  }

  gnome::dconf::add { 'enable_banner':
    profile =>  'gdm',
    path    =>  'org/gnome/login-screen',
    key     =>  'banner-message-enable',
    value   =>  true
  }

  gnome::dconf::add { 'banner_text':
    profile =>  'gdm',
    path    =>  'org/gnome/login-screen',
    key     =>  'banner-message-text',
    value   =>  $_banner
  }

  if $facts['os']['release']['major'] >= '7' {
    $_policy_defaults = {
      ensure   => present,
      priority => 10,
      result   => 'yes'
    }

    polkit::authorization::basic_policy {
      default:
        * => $_policy_defaults;

      'Allow anyone to shutdown system':
        action_id => 'org.freedesktop.consolekit.system.stop';

      'Allow anyone to restart system':
        action_id => 'org.freedesktop.consolekit.system.restart';
    }
  }
}

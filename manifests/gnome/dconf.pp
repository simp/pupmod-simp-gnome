# == Class: windowmanager::gnome::dconf
#
# Uses dconf to configure settings in gnome 3 and higher.
#
# == Parameters
#
# [*profile_list*]
# Type: Array of Strings
# Default: ['simp','gdm']
#   An array of dconf profiles
#
# [*base*]
# Type: String
# Default: '/etc/dconf'
#   The dconf directory.  This really shouldn't change
#
# [*banner*]
# Type: String
#   The banner to be displayed at login. You need to escape special characters
#   and add new line characters manually.
#
# == Authors
#
# * Ralph Wright <rwright@onyxpoint.com>
#

class windowmanager::gnome::dconf
(
  # A list of profiles used to ensure the directories are created
  # Should probably add a check to ensure you can't use a profile value that is not first defined here.
  $profile_list = ['simp','gdm'],
  $base = '/etc/dconf',
  # Fix the source of the content
  $banner = "'--------------------------------- ATTENTION ----------------------------------\\n\\n                         THIS IS A RESTRICTED COMPUTER SYSTEM\\n\\nThis computer system, and all related equipment, networks, and\\nnetwork devices are provided for authorised use only.  All \\nsystems controlled by this organisation will be monitored for\\nall lawful purposes.  Monitoring includes the totality of the\\noperating system and connected networks.No events on this\\nsystem are excluded from record and there are no exclusions\\nfrom this policy.\\n\\nUse of this system constitutes consent to full monitoring of\\nyour activities for use by the authorised monitoring organisation.\\nUnauthorised use of this system, including uninvited connections,\\nmay subject you to criminal prosecution.\\n\\nThe data collected from this system may be used for any purpose by\\nthe collecting organisation.  If you do not agree to this\\nmonitoring, discontinue use of the system IMMEDIATELY.\\n\\n                         THIS IS A RESTRICTED COMPUTER SYSTEM\\n\\n--------------------------------- ATTENTION ----------------------------------'"
){

  # Create an array of directories based on profile names
  $locks_dir = regsubst($profile_list, '^(.*)$', '/etc/dconf/db/\1.d/locks')
  $dir = regsubst($profile_list, '^(.*)$', '/etc/dconf/db/\1.d')

  validate_string($base)
  validate_string($banner)
  validate_array($profile_list)

  compliance_map()

  file { $dir :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }
  file { $locks_dir :
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
    content => "system-db:simp\nuser-db:user\nsystem-db:local\nsystem-db:site\nsystem-db:distro"
  }

  # Everything below this sets the actual values we care about

  # Prevent mount points from being automatically created
  windowmanager::gnome::dconf::add { 'automount':
    profile => 'simp',
    path    => 'org/gnome/desktop/media-handling',
    key     => 'automount',
    value   => 'false'
  }

  # Prevent automounted devices from opening automatically
  windowmanager::gnome::dconf::add { 'automount_open':
    profile => 'simp',
    path    => 'org/gnome/desktop/media-handling',
    key     => 'automount-open',
    value   => 'false'
  }

  # Prevent automounted devices from executing automatically
  windowmanager::gnome::dconf::add { 'autorun':
    profile => 'simp',
    path    => 'org/gnome/desktop/media-handling',
    key     => 'autorun-never',
    value   => 'false'
  }

  # Ensures ctr-alt-del is not used for logout
  windowmanager::gnome::dconf::add { 'ctrl_alt_del':
    profile => 'simp',
    path    => 'org/gnome/settings-daemon/plugins/media-keys',
    key     => 'logout',
    # Setting this to an empty string causes the key sequence to be ignored
    value   => "''"
  }

  # Removes Shutdown From Login Screen
  windowmanager::gnome::dconf::add { 'shutdown_login_screen':
    profile => 'simp',
    path    => 'org/gnome/login-screen',
    key     => 'disable-restart-buttons',
    value   => 'true'
  }

  # Ensure gnome does not react to the physical machine's power buttons
  windowmanager::gnome::dconf::add { 'power_button_action':
    profile => 'simp',
    path    => 'org/gnome/settings-daemon/plugins/power',
    key     => 'active',
    value   => 'false'
  }

  # Disable user administration
  # This doesn't seem to work.
  #windowmanager::gnome::dconf::add { 'user_admin':
  #  profile => 'simp',
  #  path    => 'org/gnome/desktop/lockdown',
  #  key     => 'user-administration-disabled',
  #  value   => 'true'
  #}

  # Activate the idle timer
  windowmanager::gnome::dconf::add { 'screen_saver_idle':
    profile => 'simp',
    path    => 'org/gnome/desktop/screensaver',
    key     => 'idle-activation-enabled',
    value   => 'true'
  }

  # Set the idle time to 15 minutes
  windowmanager::gnome::dconf::add { 'screen_saver_idle_time':
    profile => 'simp',
    path    => 'org/gnome/desktop/session',
    key     => 'idle-delay',
    # This MUST be set to an unsigned integer or the value will be ignored.
    value   => 'uint32 900'
  }

  # Activate the lock
  windowmanager::gnome::dconf::add { 'lock_enabled':
    profile => 'simp',
    path    => 'org/gnome/desktop/screensaver',
    key     => 'lock-enabled',
    value   => 'true'
  }

  # Ensure there is no delay in the screen lock
  windowmanager::gnome::dconf::add { 'lock_delay':
    profile => 'simp',
    path    => 'org/gnome/desktop/screensaver',
    key     => 'lock-delay',
    value   => '0'
  }

  windowmanager::gnome::dconf::add { 'enable_banner':
    profile =>  'gdm',
    path    =>  'org/gnome/login-screen',
    key     =>  'banner-message-enable',
    value   =>  'true'
  }

  windowmanager::gnome::dconf::add { 'banner_text':
    profile =>  'gdm',
    path    =>  'org/gnome/login-screen',
    key     =>  'banner-message-text',
    value   =>  $banner
  }

  # The shutdown button can't be controlled by Dconf.  
  # Use this file type for now to disable it until the policykit module can support the rules.d and javascript methods.
  file { '/etc/polkit-1/rules.d/10-disable-shutdown-button.rules':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/windowmanager/10-disable-shutdown-button.rules'
  }
}

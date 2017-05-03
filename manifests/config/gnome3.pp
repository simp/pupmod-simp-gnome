# Set configuration unique to Gnome 3
#
# @api private
class gnome::config::gnome3 {
  assert_private()

  # Create an array of directories based on profile names
  $_profile_list = $gnome::dconf_hash.keys
  $_dir       = $_profile_list.map |$profile| { "/etc/dconf/db/${profile}.d" }
  $_locks_dir = $_profile_list.map |$profile| { "/etc/dconf/db/${profile}.d/locks" }

  file { $_dir + $_locks_dir :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  file { '/etc/dconf/profile/user':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $gnome::dconf_profile_hierarchy.join("\n")
  }

  # each profile
  $gnome::dconf_hash.each |String $profile_name, Hash $profiles| {
    # each path
    $profiles.each |String $path, Hash $settings| {
      gnome::config::dconf { "${profile_name} ${path}":
        path          => $path,
        profile       => $profile_name,
        settings_hash => $settings
      }
    }
  }

  if $gnome::configure and $gnome::set_banner {
    gnome::config::dconf {'Set banner text':
      profile       => 'gdm',
      path          => 'org/gnome/login-screen',
      settings_hash => { 'banner-message-text' => { 'value' => "'${gnome::banner.regsubst(/\n/,'\n')}'" } };
    }
  }

  polkit::authorization::basic_policy {
    default:
      ensure   => 'present',
      priority => 10,
      result   => 'yes';

    'Allow anyone to shutdown system':
      action_id => 'org.freedesktop.consolekit.system.stop';

    'Allow anyone to restart system':
      action_id => 'org.freedesktop.consolekit.system.restart';
  }
}

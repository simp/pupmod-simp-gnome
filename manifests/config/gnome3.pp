# Set configuration unique to Gnome 3
#
# @api private
class gnome::config::gnome3 {
  assert_private()

  # Create an array of directories based on profile names
  $_profile_list = $gnome::dconf_hash.keys
  $_dir       = $_profile_list.map |$profile| { "/etc/dconf/db/${profile}.d" }
  $_locks_dir = $_profile_list.map |$profile| { "/etc/dconf/db/${profile}.d/locks" }

  ensure_resource('file', $_dir + $_locks_dir, {
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    recurse => true,
    purge   => true
  })

  dconf::profile { 'user':
    entries => $gnome::dconf_profile_hierarchy
  }

  $gnome::dconf_hash.each |String $profile_name, Hash $profiles| {
    # Enable GNOME settings if using GNOME
    if $profile_name == 'simp' {
      if $gnome::enable_gnome {
        $profiles.each |String $path, Hash $settings| {
          dconf::settings { "${profile_name} ${path}":
            profile       => $profile_name,
            settings_hash => $settings
          }
        }
      }
    }

    # Enable MATE settings if using MATE
    elsif $profile_name == 'simp_mate' {
      if $gnome::enable_mate {
        $profiles.each |String $path, Hash $settings| {
          dconf::settings { "${profile_name} ${path}":
            profile       => $profile_name,
            settings_hash => $settings
          }
        }
      }
    }

    # Apply the remainder of the settings
    else {
      $profiles.each |String $path, Hash $settings| {
        dconf::settings { "${profile_name} ${path}":
          profile       => $profile_name,
          settings_hash => $settings
        }
      }
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

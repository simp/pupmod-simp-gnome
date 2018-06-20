# Set configuration unique to Gnome 3
#
# @api private
class gnome::config::gnome3 {
  assert_private()

  dconf::profile { 'GNOME':
    target  => 'user',
    entries => $gnome::dconf_profile_hierarchy
  }

  $gnome::dconf_hash.each |String $profile_name, Hash $settings| {
    dconf::settings { "GNOME dconf settings: ${profile_name}":
      profile       => $profile_name,
      settings_hash => $settings
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

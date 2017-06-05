# WARNING: THIS DEFINE IS DEPRECATED
#   It has been superceded by gnome::config::dconf
#
# Add a dconf rule to the profile of your choice
#
# This adds a configuration file to the /etc/dconf/db/<profile>.d directory.
# The dconf datbase is updated when any rule is added.  You can also elect to
# lock a value so that general users cannot change it.
#
# @param key The dconf key that is being set.
#
# @param value The value of the dconf key
#
# @param profile The dconf profile where you want to place the key/value.
#
# @param path The dconf path to add the rule to.  You can use dconf dump to
#   list the paths and keys that are available.
#
# @param base_dir The database base directory
#
# @param lock Boolean to lock the key from being changed by general users.
#
define gnome::dconf::add (
  String $key,
  Variant[Boolean,String,Integer] $value,
  String $profile,
  String $path,
  Stdlib::Absolutepath $base_dir = '/etc/dconf/db',
  Boolean $lock = true
){
  deprecation('gnome::dconf::add','gnome::dconf::add is a shim for gnome::config::dconf and will be removed in a future version')

  $_settings_hash = {
    $key => {
      'value' => $value,
      'lock'  => $lock
    }
  }

  gnome::config::dconf { $name:
    ensure        => present,
    profile       => $profile,
    settings_hash => $_settings_hash,
    path          => $path,
    base_dir      => $base_dir
  }

}

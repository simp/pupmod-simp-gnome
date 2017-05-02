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
  String                  $key,
  Variant[Boolean,String] $value,
  String                  $profile,
  String                  $path,
  Stdlib::Absolutepath    $base_dir = '/etc/dconf/db',
  Boolean                 $lock = true
){
  include '::gnome::dconf'

  $profile_list    = $::gnome::dconf::profile_list
  $target_file     = "${base_dir}/${profile}.d/${name}"
  $dconf_lock      = "/${path}/${key}"
  $dconf_lock_path = "${base_dir}/${profile}.d/locks"

  file { $target_file :
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('gnome/dconf.erb'),
    notify  => Exec["dconf_update_${name}"]
  }

  if $lock {
    file { "${dconf_lock_path}/${name}" :
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $dconf_lock,
      notify  => Exec["dconf_update_${name}"]
    }
  }
  # Ensure the lock file is removed if lock is set to false
  else { file { "${dconf_lock_path}/${name}" : ensure => absent}}

  # `dconf update` doesn't return an exit code, so we have to make one
  # if the command returns output, it failed
  exec {"dconf_update_${name}":
    command     => '/bin/dconf update |& wc -c | grep ^0$',
    umask       => '0033',
    refreshonly => true
  }
}

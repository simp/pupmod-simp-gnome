# == Define: gnome::dconf::add
#
# Add a dconf rule to the profile of your choice
#
# This adds a configuration file to the /etc/dconf/db/<profile>.d directory.
# The dconf datbase is updated when any rule is added.  You can also elect to
# lock a value so that general users cannot change it.
#
# == Parameters
#
# [*path*]
#   The dconf path to add the rule to.  You can use dconf dump to list the paths
#   and keys that are available.
#
# [*key*]
#   The dconf key that is being set.
#
# [*value*]
#  The value of the dconf key
#
# [*profile*]
#  The dconf profile where you want to place the key/value.
#
# [*lock*]
#  Boolean to lock the key from being changed by general users.

define gnome::dconf::add (
  $key,
  $value,
  $profile,
  $path,
  $base_dir = '/etc/dconf/db',
  $lock = true
){
  validate_string($path)
  validate_string($key)
  if !is_bool($value) {
    validate_string($value)
  }
  validate_string($base_dir)
  validate_string($profile)
  validate_bool($lock)


  include '::gnome::dconf'
  $profile_list = $::gnome::dconf::profile_list
  $target_file = "${base_dir}/${profile}.d/${name}"
  $dconf_lock = "/${path}/${key}"
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

  exec {"dconf_update_${name}":
    command     => '/bin/dconf update',
    umask       => '0033',
    refreshonly => true
  }
}

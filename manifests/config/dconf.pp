# Add a dconf rule to the profile of your choice
#
# This adds a configuration file to the /etc/dconf/db/<profile>.d directory.
# The dconf datbase is updated when any rule is added.  You can also elect to
# lock a value so that general users cannot change it.
#
# @param settings_hash A hash to define the settings to be generated. You can set
#   whether to lock each setting like in the exmaple
#   An example hash would look like:
#   ```
#   { 'automount' => { 'value' => false, 'lock' => false } }
#   ```
#
# @param profile The dconf profile where you want to place the key/value.
# @param path The dconf setting path. Use `dconf dump` to list the paths and keys that are available.
# @param ensure Ensure the setting is present or absent
# @param base_dir The database base directory. This probably shouldn't be changed.
#
define gnome::config::dconf (
  Hash $settings_hash,
  String $profile,
  String $path,
  Enum['present','absent'] $ensure = 'present',
  Stdlib::AbsolutePath $base_dir = '/etc/dconf/db',
) {
  $_name = regsubst($name.downcase, '( |/|!|@|#|\$|%|\^|&|\*|[|])', '_', 'G')
  $settings_hash.values.each |$value| {
    if $value =~ Undef { fail('dconf-hash keys must have a value parameter') }
  }

  $_settings_hash = $settings_hash.reduce({}) |$memo,$value| {
    $memo + { $value[0] => $value[1]['value'] }
  }

  $_ini_defaults = { 'path' => "${base_dir}/${profile}.d/${_name}" }
  $_ini_hash     = { $path  => $_settings_hash }
  create_ini_settings($_ini_hash, $_ini_defaults)

  ### Locks
  $_locks = $settings_hash.reduce({}) |$memo,$value| {
    $memo + { $value[0] => $value[1] - 'value' }
  }

  $_settings_to_lock = $_locks.map |$item,$setting| {
    if $setting['lock'] == false {
      $_ret = undef
    }
    else {
      $_ret = "/${path}/${item}"
    }
    $_ret
  }

  $_lock_content = $_settings_to_lock.delete_undef_values.join("\n")

  if $_lock_content == '' {
    file { "${base_dir}/${profile}.d/locks/${_name}":
      ensure => absent
    }
  }
  else {
    file { "${base_dir}/${profile}.d/locks/${_name}":
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $_lock_content,
      notify  => Exec["dconf update ${name}"]
    }
  }

  # `dconf update` doesn't return an exit code, so we have to make one
  # if the command returns output, it failed
  exec { "dconf update ${name}":
    command     => '/bin/dconf update |& wc -c | grep ^0$',
    umask       => '0033',
    refreshonly => true
  }

}

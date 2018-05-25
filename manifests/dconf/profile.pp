# Updates a ``dconf`` profile entry to ``/etc/dconf/profile/$name``
#
# @see man 7 dconf
#
# @param name
#   The name of the profile file in ``/etc/dconf/profile``
#
# @param entries
#   One or entries in the following Hash format:
#
#   @example Profile Hierarchy Hash
#     'user':          # Name of the database
#       'type': 'user' # DB Type
#       'order': 0     # Priority order (optional, defaults to 15)
#
#   * The suggested default hierarchy used by the module data is as follows:
#     * User DB   => 0
#     * System DB => Between 11 and 39
#
# @param target
#   The target directory within which to create the profile
#
define gnome::dconf::profile (
  Gnome::DconfDBSettings $entries,
  Stdlib::AbsolutePath   $target   = '/etc/dconf/profile'
) {

  ensure_resource('file', $target, {
    'ensure' => 'directory',
    'owner'  => 'root',
    'group'  => 'root',
    'mode'   => '0644'
  })

  ensure_resource('concat', "${target}/${name}", {
    'ensure' => 'present',
    'order'  => 'numeric'
  })

  $_default_order = 15

  $entries.each |String[1] $db_name, Hash $attrs| {
    concat::fragment { "${module_name}::dconf::profile::${name}::${db_name}":
      target  => "${target}/${name}",
      content => "${attrs['type']}-db:${db_name}\n",
      order   => pick($attrs['order'], $_default_order)
    }
  }
}

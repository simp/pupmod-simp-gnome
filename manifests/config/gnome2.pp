# Set configuration unique to Gnome 2
#
# @api private
class gnome::config::gnome2 {
  assert_private()

  $gnome::gconf_hash.each |String $item, Hash $setting| {
    gconf { $item:
      * => $setting
    }
  }

}

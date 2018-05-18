# Configures GNOME
#
# @api private
class gnome::config {
  assert_private()

  # gconf and dconf must be managed differently
  if $facts['os']['release']['major'] < '7' {
    contain 'gnome::config::gnome2'
  }
  else {
    contain 'gnome::config::gnome3'
  }
}

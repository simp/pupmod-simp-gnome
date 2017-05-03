# Configures GNOME
#
# @api private
class gnome::config {
  assert_private()

  # GNOME 2 and GNOME 3 must be managed differently
  if $facts['gdm_version'] {
    if ( versioncmp($facts['gdm_version'], '3') < 0 ) {
      include 'gnome::config::gnome2'
    }
    else {
      include 'gnome::config::gnome3'
    }
  }

}

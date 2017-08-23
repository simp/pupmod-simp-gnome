# Manages packages for GNOME
#
# @api private
class gnome::install {
  assert_private()

  $packages = $gnome::packages

  if $packages['defaults'].is_a(Hash) {
    $defaults     = $packages['defaults']
    $raw_packages = $packages - 'defaults'
  }
  else {
    $defaults     = { 'ensure' => $gnome::package_ensure }
    $raw_packages = $packages
  }

  $raw_packages.each |String $package, Optional[Hash] $opts| {
    if $opts.is_a(Hash) {
      $args = { 'ensure' => $gnome::package_ensure } + $opts
    }
    else {
      $args = { 'ensure' => $gnome::package_ensure }
    }

    package {
      default : * => $defaults;
      $package: * => $args;
    }
  }

}

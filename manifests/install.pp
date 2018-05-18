# Manages packages
#
define gnome::install (
  Hash[String, Optional[Hash]] $packages,
  Simplib::PackageEnsure       $package_ensure,
){
  if $packages['defaults'].is_a(Hash) {
    $defaults     = $packages['defaults']
    $raw_packages = $packages - 'defaults'
  }
  else {
    $defaults     = { 'ensure' => $package_ensure }
    $raw_packages = $packages
  }

  $raw_packages.each |String $package, Optional[Hash] $opts| {
    if $opts.is_a(Hash) {
      $args = { 'ensure' => $package_ensure } + $opts
    }
    else {
      $args = { 'ensure' => $package_ensure }
    }

    ensure_packages($package, merge($defaults, $args))
  }
}

define pe_shared_ca::copy (
  $owner = 'pe-puppet',
  $group = 'pe-puppet',
  $mode  = undef,
) {
  $path = $name
  file { $path:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => file($path),
    notify  => Service['pe-httpd'],
  }
}

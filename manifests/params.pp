class pe_shared_ca::params {
  case $::osfamily {
    'debian': {
      $services     = [
        'pe-puppet-agent',
        'pe-httpd',
        'pe-mcollective',
        'pe-activemq',
      ]
    }
    'redhat': {
      $services     = [
        'pe-puppet',
        'pe-httpd',
        'pe-mcollective',
        'pe-activemq',
      ]
    }
  }
}

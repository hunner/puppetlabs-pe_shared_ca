# Shared Certificates for Puppet Masters
#
# This class is intended to be run in a oneoff scenario to aid in the
# bootstrapping of a shared ca environment.  It is not meant to be
# permanantly installed as part of a maintained Puppet environment.
#
class pe_shared_ca (
  $ca_server,
  $manage_puppet_conf  = true,
) {
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
  validate_bool($ca_server)

  ## Stop services before purging cert files
  #service { $services:
  #  ensure  => 'stopped',
  #  before  => File[$mco_files_to_purge, $ca_files_to_purge],
  #}


  #Function to read all puppet masters, make sure they have certs with dns alt names, provide $fqdn.uuid and add to autosign.conf with comment

  if $purge_certs {
    ## Purge old ssl files
    # Replace with exec refreshonly
    $ca_files_to_purge = [
      "/etc/puppetlabs/puppet/ssl/certs/ca.pem",
      "/etc/puppetlabs/puppet/ssl/certs/${::clientcert}.pem",
      "/etc/puppetlabs/puppet/ssl/private_keys/${::clientcert}.pem",
      "/etc/puppetlabs/puppet/ssl/public_keys/${::clientcert}.pem",
      "/etc/puppetlabs/puppet/ssl/crl.pem",
    ]
    $mco_files_to_purge = [
      "/etc/puppetlabs/mcollective/ssl",
      "/etc/puppetlabs/activemq/broker.ks",
      "/etc/puppetlabs/activemq/broker.p12",
      "/etc/puppetlabs/activemq/broker.pem",
      "/etc/puppetlabs/activemq/broker.ts",
    ]

    #file { $mco_files_to_purge:
    #  ensure  => absent,
    #  recurse => true,
    #  force   => true,
    #  before  => File['/etc/puppetlabs/mcollective/credentials'],
    #}
    #file { $ca_files_to_purge:
    #  ensure  => absent,
    #  recurse => true,
    #  force   => true,
    #  before  => File['/etc/puppetlabs/mcollective/credentials'],
    #}
  }

  File {
    ensure => file,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    notify => Service['pe-httpd'],
  }

  if $ca_server {
    ## Update CA directory and remove all pre-existing files
    pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem': }
    pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem': }
    pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/ca/ca_key.pem': }
    pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/ca/ca_pub.pem': }

    if $manage_puppet_conf {
      ini_setting { 'master ca setting':
        path    => '/etc/puppetlabs/puppet/puppet.conf',
        section => 'master',
        setting => 'ca',
        value   => 'true',
      }
    }
  } else {
    ## Remove CA directory from non-ca-server
    file { "/etc/puppetlabs/puppet/ssl/ca":
      ensure  => absent,
      recurse => true,
      force   => true,
    }
    if $manage_puppet_conf {
      ini_setting { 'master ca setting':
        path    => '/etc/puppetlabs/puppet/puppet.conf',
        section => 'master',
        setting => 'ca',
        value   => 'false',
      }
    }
  }

  ## Update pe-internal certs
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/certs/pe-internal-broker.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/certs/pe-internal-mcollective-servers.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/certs/pe-internal-peadmin-mcollective-client.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/certs/pe-internal-puppet-console-mcollective-client.pem': }

  ## Update pe-internal private_keys
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-broker.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-mcollective-servers.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-peadmin-mcollective-client.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-puppet-console-mcollective-client.pem': }

  ## Update pe-internal public_keys
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-broker.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem': }
  pe_shared_ca::copy { '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem': }

  ## Update MCO credentials file
  pe_shared_ca::copy { '/etc/puppetlabs/mcollective/credentials':
    mode   => '0600',
  }
}

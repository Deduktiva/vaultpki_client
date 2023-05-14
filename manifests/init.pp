class vaultpki_client {
  ensure_packages(['python3', 'curl'])
  file { ['/var/lib/vaultpki-client', '/var/lib/vaultpki-client/certificates']:
    ensure => directory,
    mode   => '0770',
    owner  => 'root',
    group  => 'root',
  }
  file { '/usr/local/sbin/vaultpki-client':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/vaultpki_client/vaultpki-client',
    require => [Package['python3'], Package['curl']],
  }
  file { '/etc/cron.daily/vaultpki-client':
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/vaultpki_client/vaultpki-client.cron',
  }
}

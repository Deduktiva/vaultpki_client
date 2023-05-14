# Integration Example

## Proxmox VE

Manage certificates for Proxmox VE web interface.

This has an additional complication: `/etc/pve` is a FUSE filesystem, and Puppet cannot directly manage files in this filesystem.
Work around this limitation using `cp` and an additional staging directory.

```
  service { 'pveproxy':
  }

  file { '/etc/pve-local':
    ensure => directory,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

  vaultpki_client::certificate { 'pve':
    common_name => $::fqdn,
  }
  vaultpki_client::privkey_pem { '/etc/pve-local/pveproxy-ssl.key':
    certname => 'pve',
  }
  exec { '/bin/cp /etc/pve-local/pveproxy-ssl.key /etc/pve/local/pveproxy-ssl.key':
    refreshonly => true,
    notify      => Service['pveproxy'],
    subscribe   => Vaultpki_client::Privkey_pem['/etc/pve-local/pveproxy-ssl.key'],
  }
  vaultpki_client::fullchain_pem { '/etc/pve-local/pveproxy-ssl.pem':
    certname => 'pve',
  }
  exec { '/bin/cp /etc/pve-local/pveproxy-ssl.pem /etc/pve/local/pveproxy-ssl.pem':
    refreshonly => true,
    notify      => Service['pveproxy'],
    subscribe   => Vaultpki_client::Fullchain_pem['/etc/pve-local/pveproxy-ssl.pem'],
  }
```

## Debian's Exim

```
  $ssldir = "/etc/${exim_name}/ssl"
  $ssl_keyfile = "${ssldir}/exim.key"
  $ssl_certfile = "${ssldir}/exim.crt"
  file { $ssldir:
    ensure => directory,
    mode   => '0700',
    owner  => 'Debian-exim',
    group  => 'Debian-exim',
  }

  vaultpki_client::certificate { 'exim':
    common_name => $::fqdn,
    alt_names   => ["mail.${::domain}"],
  }
  vaultpki_client::privkey_pem { $ssl_keyfile:
    certname => 'exim',
    mode     => '0600',
    owner    => 'Debian-exim',
    group    => 'Debian-exim',
    notify   => Service['exim'],
  }
  vaultpki_client::fullchain_pem { $ssl_certfile:
    certname => 'exim',
    mode     => '0600',
    owner    => 'Debian-exim',
    group    => 'Debian-exim',
    notify   => Service['exim'],
  }
```

If you template `exim4.conf`, you can use:
```
tls_advertise_hosts = *
tls_verify_certificates = /dev/null
tls_certificate = <%= @ssl_certfile %>
tls_privatekey = <%= @ssl_keyfile %>
```

## Unifi Network Application

Note: this seems to fail sometimes for unknown reasons.

```
  vaultpki_client::certificate { 'unifi':
    common_name => $::fqdn,
  }
  vaultpki_client::privkey_pem { '/etc/ssl/private/unifi.key':
    certname => 'unifi',
  }
  vaultpki_client::fullchain_pem { '/etc/ssl/private/unifi.crt':
    certname => 'unifi',
  }
  vaultpki_client::ca_pem { '/etc/ssl/private/unifi-ca.crt':
    certname => 'unifi',
  }
  exec { '/usr/bin/java -jar lib/ace.jar import_key_cert /etc/ssl/private/unifi.key /etc/ssl/private/unifi.crt /etc/ssl/private/unifi-ca.crt':
    refreshonly => true,
    cwd         => '/usr/lib/unifi',
    subscribe   => [Vaultpki_client::Privkey_pem['/etc/ssl/private/unifi.key'], Vaultpki_client::Fullchain_pem['/etc/ssl/private/unifi.crt']],
    notify      => Service['unifi'],
  }
```

# Manage PKI certificates using Puppet + Hashicorp Vault

This module is intended for a "simple" setup, with these goals:

- Vault is already managed somehow
- Vault trusts the Puppet PKI for certificate issuance, at least for specific names / a specific CA
- Hosts managed using Puppet should renew their certificates without any user intervention

## Usage

### vaultpki_client::certificate

This define sets up pulling the certificate and automatic renewal.

To *use* the certificate, you also have to use one of the deployment defines, see below.

```
vaultpki_client::certificate { $certname:
  ensure       => present,
  common_name  => $::fqdn,
  alt_names    => [],
  ip_sans      => [],
  ttl          => 2592000,  # 30 days default
  auth_method  => 'puppet',
  pki_role     => 'auto-vaultpki-client',
}
```

`certname` is the internal name this certificate is referred to. Should be a filename-safe string. The other defines will use this name to find the certificate data.

`common_name` is the certificate Common Name to be requested.

`alt_names` is a list of strings to request as subjectAltName: DNS values.

`ip_sans` is a list of strings to request as subjectAltName: IP address values.

`ttl` is the lifetime (validity) of the certificate to request, in seconds. Defaults to 30 days.

`auth_method` is the authentication method as setup in Vault. Defaults to `puppet`.

`pki_role` is the Vault PKI role to request certificates from. Defaults to `auto-vaultpki-client`.

### vaultpki_client::fullchainandkey_pem

Deploys everything as a single file: certificate, private key and certificate chain.

Useful for Apache 2, nginx, and other common servers.

```
vaultpki_client::fullchainandkey_pem { $filesystem_path:
  ensure    => present,
  certname  => $certname,
  mode      => '0600',
  owner     => 'root',
  group     => 'root'
}
```

`filesystem_path` is the file name to create.

`certname` is the certificate name created by `vaultpki_client::certificate`.

`ensure`, `mode`, `owner`, `group` are passed to puppets `file` resource.

### vaultpki_client::fullchain_pem

Deploys the certificate and the chain file. Private key is not deployed.

```
vaultpki_client::fullchain_pem { $filesystem_path:
  ensure    => present,
  certname  => $certname,
  mode      => '0600',
  owner     => 'root',
  group     => 'root'
}
```

`filesystem_path` is the file name to create.

`certname` is the certificate name created by `vaultpki_client::certificate`.

`ensure`, `mode`, `owner`, `group` are passed to puppets `file` resource.

### vaultpki_client::privkey_pem

Deploys the private key for a certificate.

```
vaultpki_client::privkey_pem { $filesystem_path:
  ensure    => present,
  certname  => $certname,
  mode      => '0600',
  owner     => 'root',
  group     => 'root'
}
```

`filesystem_path` is the file name to create.

`certname` is the certificate name created by `vaultpki_client::certificate`.

`ensure`, `mode`, `owner`, `group` are passed to puppets `file` resource.

### vaultpki_client::chain_pem

Deploys *only* the certificate chain for a certificate, excluding the certificate itself.

```
vaultpki_client::chain_pem { $filesystem_path:
  ensure    => present,
  certname  => $certname,
  mode      => '0600',
  owner     => 'root',
  group     => 'root'
}
```

`filesystem_path` is the file name to create.

`certname` is the certificate name created by `vaultpki_client::certificate`.

`ensure`, `mode`, `owner`, `group` are passed to puppets `file` resource.

### vaultpki_client::ca_pem

Deploys the Issuing Certificate Authority (CA) Certificate into a file.

```
vaultpki_client::ca_pem { $filesystem_path:
  ensure    => present,
  certname  => $certname,
  mode      => '0600',
  owner     => 'root',
  group     => 'root'
}
```

`filesystem_path` is the file name to create.

`certname` is the certificate name created by `vaultpki_client::certificate`.

`ensure`, `mode`, `owner`, `group` are passed to puppets `file` resource.

## Internals

Certificates and metadata are stored on each host in `/var/lib/vaultpki-client`.

A cron job is deployed to automatically refresh the certificates.

## Automatic restart of services

vaultpki_client deploys a cron job to refresh the certificates in time.
However, this cron job does not deploy the certificates or restart any services.
For this to work, it is expected that Puppet runs regularly, and `notify` is used on the relevant deployment defines, like on `vaultpki_client::fullchainandkey_pem`.

## Full Example

```
  vaultpki_client::certificate { 'grafana':
    common_name => 'grafana.example.org',
    alt_names   => ['dashboards.example.org'],
  }
  vaultpki_client::fullchainandkey_pem { '/etc/apache2/ssl/grafana.pem':
    certname => 'grafana',
    notify   => Service['apache2'],
  }
```

This request a certificate for `grafana.example.org` with additional subjectAltNames `DNS:dashboards.example.org`, and a default validity of 30 days.
The certificate, its private key and certificate chain are deployed as the file `/etc/apache2/ssl/grafana.pem`.
When the file changes, for example because of automatic renewal, the `apache2` service will be notified (likely restarted).

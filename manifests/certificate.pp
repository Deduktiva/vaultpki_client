define vaultpki_client::certificate(
  String        $common_name,
  String        $ensure       = 'present',
  String        $auth_method  = 'puppet',
  String        $pki_role     = 'auto-vaultpki-client',
  Integer       $ttl          = 2592000,  # 30 days default
  Array[String] $alt_names    = [],
  Array[String] $ip_sans      = [],
) {
  $basedir = "/var/lib/vaultpki-client/certificates/${name}"
  $metadata = {
    'auth_method'   => $auth_method,
    'pki_role'      => $pki_role,
    'issue' => {
      'ttl'         => $ttl,
      'common_name' => $common_name,
      'alt_names'   => $alt_names.join(','),
      'ip_sans'     => $ip_sans.join(','),
    },
  }

  case $ensure {
    'present': {
      require vaultpki_client

      file { $basedir:
        ensure => directory,
        mode   => '0700',
        owner  => 'root',
        group  => 'root',
      }
      file { "${basedir}/metadata.json":
        ensure  => file,
        mode    => '0640',
        owner   => 'root',
        group   => 'root',
        content => inline_template('<% require "json" %><%= @metadata.to_json %>'),
        notify  => Exec["vaultpki_client_${name}"],
      }
      exec { "vaultpki_client_${name}":
        command => "/usr/local/sbin/vaultpki-client ${name}",
        creates => "${basedir}/cert.pem",
      }
    }
    'absent': {
      file { $basedir:
        ensure => absent,
        force  => true,
        purge  => true,
      }
    }
    default: {
      fail("ensure value '${ensure}' not understood")
    }
  }
}

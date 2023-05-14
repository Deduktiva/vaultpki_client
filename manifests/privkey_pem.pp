# Deploy a file with the private key (in PEM format).
define vaultpki_client::privkey_pem(
  String        $certname,
  String        $ensure     = 'present',
  String        $mode       = '0600',
  String        $owner      = 'root',
  String        $group      = 'root',
) {
  vaultpki_client::internal::copy { $name:
    ensure     => $ensure,
    sourcefile => 'privkey.pem',
    certname   => $certname,
    mode       => $mode,
    owner      => $owner,
    group      => $group,
  }
}

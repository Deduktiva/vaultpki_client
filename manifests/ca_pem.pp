# Deploy a single file containing the Issuing Certificate Authority (CA) Certificate.
define vaultpki_client::ca_pem(
  String        $certname,
  String        $ensure     = 'present',
  String        $mode       = '0600',
  String        $owner      = 'root',
  String        $group      = 'root',
) {
  vaultpki_client::internal::copy { $name:
    ensure     => $ensure,
    sourcefile => 'ca.pem',
    certname   => $certname,
    mode       => $mode,
    owner      => $owner,
    group      => $group,
  }
}

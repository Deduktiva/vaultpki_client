# Deploy a single file containing Private Key, Certificate and Certificate Chain.
define vaultpki_client::fullchainandkey_pem(
  String        $certname,
  String        $ensure     = 'present',
  String        $mode       = '0600',
  String        $owner      = 'root',
  String        $group      = 'root',
) {
  vaultpki_client::internal::copy { $name:
    ensure     => $ensure,
    sourcefile => 'fullchainandkey.pem',
    certname   => $certname,
    mode       => $mode,
    owner      => $owner,
    group      => $group,
  }
}

# Deploy a single file containing the public Certificate and Certificate Chain.
define vaultpki_client::fullchain_pem(
  String        $certname,
  String        $ensure     = 'present',
  String        $mode       = '0600',
  String        $owner      = 'root',
  String        $group      = 'root',
) {
  vaultpki_client::internal::copy { $name:
    ensure     => $ensure,
    sourcefile => 'fullchain.pem',
    certname   => $certname,
    mode       => $mode,
    owner      => $owner,
    group      => $group,
  }
}

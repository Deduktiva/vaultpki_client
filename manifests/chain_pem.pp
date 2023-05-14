# Deploy a single file containing the Certificate (CA) Chain.
define vaultpki_client::chain_pem(
  String        $certname,
  String        $ensure     = 'present',
  String        $mode       = '0600',
  String        $owner      = 'root',
  String        $group      = 'root',
) {
  vaultpki_client::internal::copy { $name:
    ensure     => $ensure,
    sourcefile => 'chain.pem',
    certname   => $certname,
    mode       => $mode,
    owner      => $owner,
    group      => $group,
  }
}

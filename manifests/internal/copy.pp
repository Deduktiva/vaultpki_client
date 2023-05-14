define vaultpki_client::internal::copy(
  String        $certname,
  String        $sourcefile,
  String        $ensure,
  String        $mode,
  String        $owner,
  String        $group,
) {
  file { $name:
    ensure    => present,
    backup    => false,  # avoid copying secrets to filebucket.
    show_diff => false,  # avoid leaking secrets into reports.
    links     => follow,
    source    => "/var/lib/vaultpki-client/certificates/${certname}/${sourcefile}",
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    subscribe => Vaultpki_client::Certificate[$certname],
  }
}

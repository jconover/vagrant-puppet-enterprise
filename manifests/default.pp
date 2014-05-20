file { '/etc/resolv.conf':
  source => '/vagrant/files/resolv.conf',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
}

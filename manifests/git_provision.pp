# Manifest to set up my Vagrant Puppet Enterprise master to
# use git and dynamic environments. Meant to be used with
# puppet apply after the master is provisioned.

package { 'git':
  ensure => present,
}

exec { '/bin/rm -rf /vagrant/git/linux-puppet.git/':
  require => Package['git'],
}

exec { '/usr/bin/git init --bare /vagrant/git/linux-puppet.git':
  require => Exec['/bin/rm -rf /vagrant/git/linux-puppet.git/'],
}

file { 'post-receive':
  path    => '/vagrant/git/linux-puppet.git/hooks/post-receive',
  source  => 'file:///vagrant/files/post-receive',
  mode    => '0755',
  require => Exec['/usr/bin/git init --bare /vagrant/git/linux-puppet.git'],
}

file { 'puppetlabs-dynamic.environments.rb':
  path    => '/vagrant/git/linux-puppet.git/hooks/puppetlabs-dynamic.environments.rb',
  source  => 'file:///vagrant/files/puppetlabs-dynamic.environments.rb',
  mode    => '0755',
  require => File['post-receive'],
}

file { '/etc/puppetlabs/puppet/environments':
  ensure  => directory,
  owner   => 'pe-puppet',
  group   => 'pe-puppet',
  mode    => '0755',
  require => File['puppetlabs-dynamic.environments.rb'],
}

file { '/etc/puppetlabs/puppet/puppet.conf':
  ensure  => present,
  source  => 'file:///vagrant/files/puppet.conf',
  owner   => 'pe-puppet',
  group   => 'pe-puppet',
  require => File['/etc/puppetlabs/puppet/environments'],
}

exec { '/sbin/service pe-httpd restart':
  require => File['/etc/puppetlabs/puppet/puppet.conf'],
}

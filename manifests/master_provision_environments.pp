# Manifest to set up my Vagrant Puppet Enterprise master to
# use git and dynamic environments. Meant to be used with
# puppet apply after the master is provisioned.

package { 'git':
  ensure => present,
}

file { ['/site', '/site/git']:
  ensure => directory,
  owner  => 'vagrant',
  group  => 'vagrant',
}

exec { '/usr/bin/git init --bare /site/git/linux-puppet.git':
  user    => 'vagrant',
  group   => 'vagrant',
  require => File['/site/git'],
}

file { 'post-receive':
  path    => '/site/git/linux-puppet.git/hooks/post-receive',
  source  => 'file:///vagrant/files/post-receive',
  mode    => '0755',
  require => Exec['/usr/bin/git init --bare /site/git/linux-puppet.git'],
}

file { 'puppetlabs-dynamic.environments.rb':
  path    => '/site/git/linux-puppet.git/hooks/puppetlabs-dynamic.environments.rb',
  source  => 'file:///vagrant/files/puppetlabs-dynamic.environments.rb',
  mode    => '0755',
  require => File['post-receive'],
}

$basedir = '/etc/puppetlabs/puppet'

file { [ "${basedir}/environments", "${basedir}/environments/production",
          "${basedir}/environments/production/manifests",
          "${basedir}/environments/production/modules" ]:
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

file { '/etc/puppetlabs/puppet/environments/production/manifests/site.pp':
  ensure  => present,
  source  => 'file:///vagrant/manifests/site.pp',
  owner   => 'pe-puppet',
  group   => 'pe-puppet',
  require => File['/etc/puppetlabs/puppet/environments'],
}

exec { '/sbin/service pe-httpd restart':
  require => File['/etc/puppetlabs/puppet/environments/production/manifests/site.pp'],
}

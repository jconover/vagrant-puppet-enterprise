# packages -- Base packages shared by all systems
# RedHat/CentOS only at this point

class packages {
  package { 'vim-enhanced':
    ensure => latest,
  }
  package { 'git':
    ensure => latest,
  }
  package { 'telnet':
    ensure => latest,
  }
  package { 'gcc':
    ensure => latest,
  }
  package { 'man':
    ensure => latest,
  }
}

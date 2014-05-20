exec { '/usr/bin/ssh -oStrictHostKeyChecking=no vagrant@puppet "sudo rm -rf /etc/puppetlabs/puppet/environments/production"':
  user => 'vagrant',
      }

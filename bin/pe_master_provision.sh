#!/bin/bash

### Script for installing Puppet Enterprise as a master on a Vagrant node
### RHEL/CentOS specific at this point
### Requires the PE installer tarball
### Rich Burroughs

PE_VERSION=3.2.3
SOURCE_DIR=/vagrant
INSTALL_DIR=/home/vagrant
ANSWERS_FILE=/vagrant/files/answers.${HOSTNAME}
ANSWERS_TEMPLATE=/vagrant/files/answers.master.TEMPLATE
AUTOSIGN_CONF=/vagrant/files/autosign.conf

echo "Provisioning Puppet master"
if [ -f /usr/local/bin/puppet ]
  then
    echo "Puppet already installed, skipping..."
  else
    ### Set hostname in answers file
    sudo bash -c "sed s/MASTER/$HOSTNAME/ ${ANSWERS_TEMPLATE} > ${ANSWERS_FILE}"
    ### PE Master Install
    cp /vagrant/files/puppet-enterprise-${PE_VERSION}-el-6-x86_64.tar.gz ${INSTALL_DIR}
    cd ${INSTALL_DIR}
    tar xfz puppet-enterprise-${PE_VERSION}-el-6-x86_64.tar.gz 
    cd puppet-enterprise-${PE_VERSION}-el-6-x86_64
    sudo ./puppet-enterprise-installer -a ${ANSWERS_FILE}
    echo "Puppet installed"
    ### Enable autosigning
    sudo cp ${AUTOSIGN_CONF} /etc/puppetlabs/puppet
    sudo chown -R pe-puppet:pe-puppet /etc/puppetlabs/puppet/autosign.conf
    ### Cleanup 
    sudo rm -rf ${INSTALL_DIR}/puppet-enterprise-${PE_VERSION}-el-6-x86_64*
    sudo rm ${ANSWERS_FILE}
    ### Copy modules and site.pp
    sudo cp -a /vagrant/modules/ /etc/puppetlabs/puppet
    sudo chown -R root:pe-puppet /etc/puppetlabs/puppet/modules/
    sudo cp -a /vagrant/manifests/site.pp /etc/puppetlabs/puppet/manifests
fi

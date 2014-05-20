#!/bin/bash

### Script for installing Puppet Enterprise as an agent on a Vagrant node
### RHEL/CentOS specific at this point
### Requires the PE installer tarball
### Rich Burroughs

PE_VERSION=3.2.3
SOURCE_DIR=/vagrant
INSTALL_DIR=/home/vagrant
ANSWERS_TEMPLATE=/vagrant/files/answers.agent.TEMPLATE
ANSWERS_FILE=/vagrant/files/answers.${HOSTNAME}

echo "Provisioning Puppet agent"
if [ -f /usr/local/bin/puppet ]
  then
    echo "Puppet already installed, skipping..."
  else
    ### Run 'puppet cert clean' on the master for this host
    su vagrant -c 'ssh -oStrictHostKeyChecking=no vagrant@puppet "sudo puppet cert clean ${HOSTNAME}.localdomain"'
    ### Set hostname in answers file
    sudo bash -c "sed s/AGENT/$HOSTNAME/ ${ANSWERS_TEMPLATE} > ${ANSWERS_FILE}"
    ### PE Agent Install
    cp /vagrant/files/puppet-enterprise-${PE_VERSION}-el-6-x86_64.tar.gz ${INSTALL_DIR}
    cd ${INSTALL_DIR}
    tar xfz puppet-enterprise-${PE_VERSION}-el-6-x86_64.tar.gz 
    cd puppet-enterprise-${PE_VERSION}-el-6-x86_64
    sudo ./puppet-enterprise-installer -a ${ANSWERS_FILE}
    echo "Puppet installed"
    ### Cleanup
    sudo rm -rf ${INSTALL_DIR}/puppet-enterprise-${PE_VERSION}-el-6-x86_64*
    sudo rm ${ANSWERS_FILE}
fi

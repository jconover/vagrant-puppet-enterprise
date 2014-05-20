#!/bin/bash

# reset VMs using the vagrant-vbox-snapshot plugin

MASTERSNAP=agent1-cert-signed
AGENTSNAP=post-provision

vagrant snapshot go master ${MASTERSNAP}
vagrant snapshot go agent1 ${AGENTSNAP}

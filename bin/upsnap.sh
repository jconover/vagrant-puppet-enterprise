#!/bin/bash

vagrant up master
vagrant snapshot take master post-provision
vagrant up agent1
vagrant snapshot take agent1 post-provision
vagrant snapshot take master agent1-cert-signed

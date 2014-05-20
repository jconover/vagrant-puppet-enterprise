#!/bin/bash

sudo bash -c "cat /vagrant/files/hosts >> /etc/hosts"
sudo service iptables stop
sudo chkconfig iptables off
sudo yum update -y


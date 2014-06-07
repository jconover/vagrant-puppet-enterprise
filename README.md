# vagrant-puppet-enterprise #

Multihost Vagrant setup for Puppet Enterprise testing

## What this is ##

First, this is not a Vagrant plugin. It's a Vagrant file and provisioning
scripts that I use for testing Puppet Enterprise on a Vagrant VirtualBox
CentOS VM. I put this together to suit my own needs -- if you are not
me you may be better off checking out Beaker from Puppet Labs or Finch's
project called Oscar. That said, if you are using Vagrant and VirtualBox
and want to give PE a spin, this may work for you.

## What it does ##

The included Vagrantfile spins up a master node and an agent, and installs
Puppet Enterprise on them both. After typing "vagrant up" and waiting a bit
(about 15 minutes on my iMac, so enjoy some coffee and a nice walk around
the block), you should end up with a running Puppet master and an agent
with a signed cert, all ready to go. There's also an option to configure
the master to contain a git repo and use dynamic environments, so you
can push your Puppet git repo there and test your actual code.

## Requirements ##

Vagrant. If you want to use my CentOS box, the Vagrantfile points to the
location for that using Vagrant Cloud. You need Vagrant 1.5 or newer to use
Vagrant Cloud. If your Vagrant is older, the URL to download the box from
Dropbox is commented out in the Vagrantfile.

If you want to use your own CentOS box, you should install the private SSH
key from the default Vagrant keypair for the Vagrant user. Some of the 
provisioning scripts depend on the ability to ssh between nodes with no 
password. See: https://github.com/mitchellh/vagrant/tree/master/keys

The PE installer tarball is required, download it from Puppet Labs and put
it in the files directory in this checkout. You also need to set the version
number from the tarball in the Puppet provisioning scripts in the bin
directory, pe\_master\_provision.sh and pe\_agent\_provision.sh. (Refactoring
this so there's only one location to update is on my to do list.)

If you want to have VirtualBox take snapshots of the VMs automagically, you
need these Vagrant plugins:

vagrant-vbox-snapshot
vagrant-host-shell

I'll discuss snapshots more below.

## Event flow ##

Here's the basic order of events, after you type "vagrant up" and the box is
installed:

*On Both Nodes (shared behavior)*

* A file with the IPs and hostnames of the nodes is copied to /etc/hosts
* The iptables service is stopped
* The iptables service is disabled for future reboots

*On the master node*

* An answers file for automated PE installs is built from the template
files/answers.master.TEMPLATE using the master's hostname from the Vagrantfile
* The Puppet Enterprise tarball in files/ is extracted on the master and the
PE installer runs, using the answers file
* The autosign.conf file is copied into place on the master, so it will sign
the agent's cert without intervention
* The Puppet code in manifests/default.pp is run by the Vagrant Puppet
provisioner
* If provision\_environments is set to true in the Vagrantfile, the Vagrant
Puppet provisioner runs mainfests/master\_provision\_environments.pp which
sets up the git repo and configures the master to use dynamic environments. The
Ruby script for the git post-receive hook is from Puppet Labs, see:
http://puppetlabs.com/blog/git-workflow-and-puppet-environments
* If take\_snapshots is set to true in the Vagrantfile (and the plugins
mentioned above are installed), a VirtualBox snapshot of the master called
"post-provision" is created.

*On the agent node*

* The agent node runs "puppet cert clean" on the master via SSH for it's own
hostname, so you can re-use hostnames for the agents without manual
intervention
* An answers file for automated PE installs is built from the template
files/answers.agent.TEMPLATE using the agent node's hostname from the
Vagrantfile
* The Puppet Enterprise tarball in files/ is extracted on the agent node and
the PE installer runs, using the answers file
* The Puppet code in manifests/default.pp is run by the Vagrant Puppet
provisioner
* If provision\_environments is set to true in the Vagrantfile, the Vagrant
Puppet provisioner runs mainfests/agent\_provision\_environments.pp which
does an rm -rf of the pre-populated production environment on the master
via ssh. (I may change how this is handled, but the production environment
has to be there for the agent's first run, so it can get a signed cert. It's
not a git repo though, so pushing to production fails unless it's deleted
first.)
* If take\_snapshots is set to true in the Vagrantfile (and the plugins
mentioned above are installed), a VirtualBox snapshot of the agent node
called "post-provision" is created.
* If take\_snapshots is set to true in the Vagrantfile (and the plugins
mentioned above are installed), a VirtualBox snapshot of the master called
"agent1-cert-signed" is created.

## Snapshots ##

The big pain with Vagrant is the time it takes to rebuild the nodes from 
scratch, during the first "vagrant up" or after a "vagrant destroy." The
master node is especially slow because of the amount of things happening
during the PE master install.

During testing I like to be able to roll back to a clean state, and that
was difficult with the time involved to rebuild. I'd typically do that 
with snapshots, but I didn't know of a way to automate that with Vagrant.
Then I found the vagrant-vbox-snapshot, plugin, but the problem was that
the commands to interact with it need to be run in the shell, not from one
of the Vagrant provisioners on the VirtualBox guest. 

The vagrant-host-shell plugin ended up being the best way I could find to 
bridge that gap. With that plugin installed, I can execute the shell
commands on the VirtualBox host to create the snapshots during the 
provisioning process automatically.

There's a small shell script included called bin/reset-vms.sh that will
reset both the master and the agent back to the snapshots created after
the agent is provisioned. Rolling back to those snapshots is much faster
than even doing a "vagrant up" with the VMs both halted. It's really helped
me in my testing, to be able to quickly get back to that state. Also
the vagrant-vbox-snapshot plugin luanches the VMs automatically after 
restoring the snapshot, so you end up with both VMs running again quickly.

Apparently the Puppet Labs team is incorporating support for Docker into
their Beaker tool, and I have heard that it's turning out to be much
faster than using Vagrant. Yet another reason to be using Beaker instead
of my code :)

## Contributing ##

I am open to pull requests if you have idea that can improve how this 
process currently works. Since I build this for myself to use, I won't want
to pull in anything that will break how I use the tool. I will probably
be moving to Beaker myself in the near future, if I find it works for 
my PE testing needs.



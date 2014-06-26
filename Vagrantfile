# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # Make attempt to fix stdin: is not a tty
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Download Phusion base box
    config.vm.box = "phusion/ubuntu-14.04-amd64"

    # Install puppet dependencies
    config.vm.provision "shell", path: 'provisioning/shell'

    config.vm.provision "puppet" do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file  = "init.pp"
    end

    config.vm.provider "vmware_fusion" do |vm|
        vm.vmx["cpuid.coresPerSocket"]  = 100
        vm.vmx["memsize"]               = 1024
        vm.vmx["numvcpus"]              = 1
    end
end

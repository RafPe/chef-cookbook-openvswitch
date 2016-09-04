#
# Cookbook Name:: openvswitch
# Recipe:: default
#
# Copyright (C) 2016 RafPe
#
#
#

# Packages for openvswitch
%w(wget openssl-devel desktop-file-utils gcc make python-devel openssl-devel kernel-devel graphviz kernel-debug-devel autoconf automake rpm-build redhat-rpm-config libtool python-twisted-core python-zope-interface PyQt4
libcap-ng-devel groff checkpolicy selinux-policy-devel).each do |pkg|
  package pkg do
    action :install
  end
end

# Create ovs user
user 'ovs' do
  comment 'OpenVswitch user'
  home '/home/ovs'
  shell '/bin/bash'
  password '$1$JJsvHslasdfjVEroftprNn4JHtDi'
end

%w[ /home/ovs/rpmbuild /home/ovs/rpmbuild/SOURCES ].each do |path|
  directory path do
    owner 'ovs'
    group 'ovs'
    mode '0755'
    recursive true
    action :create
  end
end

remote_file '/home/ovs/rpmbuild/SOURCES/openvswitch-2.5.0.tar.gz' do
  source 'http://openvswitch.org/releases/openvswitch-2.5.0.tar.gz'
  owner 'ovs'
  group 'ovs'
  mode '0755'
  action :create
  not_if do ::File.exists?('/home/ovs/rpmbuild/SOURCES/openvswitch-2.5.0.tar.gz') end
end

execute 'Extract OVS sources' do
  command 'tar xzvf openvswitch-2.5.0.tar.gz'
  cwd '/home/ovs/rpmbuild/SOURCES/'
end

execute 'Build packages' do
    user 'root'
    action :run
    command "sudo su - ovs -l -c 'cd /home/ovs/rpmbuild/SOURCES/openvswitch-2.5.0/ && rpmbuild -bb --nocheck /home/ovs/rpmbuild/SOURCES/openvswitch-2.5.0/rhel/openvswitch-fedora.spec'"
    not_if do ::File.exists?('/home/ovs/rpmbuild/RPMS/x86_64/openvswitch-2.5.0-1.el7.centos.x86_64.rpm') end
end

rpm_package '/home/ovs/rpmbuild/RPMS/x86_64/openvswitch-2.5.0-1.el7.centos.x86_64.rpm' do
  action :install
end

# Ensure the service is properly started
service 'openvswitch.service' do
  action [ :enable, :start ]
end

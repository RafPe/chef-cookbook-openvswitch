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

# Create ovs user for source build - can be replaced with iteration ?!
user "#{node['openvswitch']['user']['name']}" do
  manage_home true
  comment  "#{node['openvswitch']['user']['comment']}"
  home     "#{node['openvswitch']['user']['home']}"
  shell    "#{node['openvswitch']['user']['shell']}"
  password "#{node['openvswitch']['user']['password']}"
end


# Create source user directories
node['openvswitch']['sourcefolders'].each do |path|
  directory "#{node['openvswitch']['user']['home']}/#{path}" do
    owner   "#{node['openvswitch']['user']['name']}"
    group   "#{node['openvswitch']['user']['name']}"
    mode '0755'
    recursive true
    action :create
  end
end

#
# Setup download location - tricky as using indexed array :/
#
node.default['openvswitch']['download2'] = "#{node['openvswitch']['user']['home']}/#{node['openvswitch']['sourcefolders'][1]}"
node.default['openvswitch']['filename'] = "openvswitch-#{node['openvswitch']['version']}.tar.gz"

# Download remote file ( unless we already have it)
# Might require more rework as we only check whatever file presence
remote_file "#{node['openvswitch']['download2']}/#{node['openvswitch']['filename']}" do
  source "http://openvswitch.org/releases/#{node['openvswitch']['filename']}"
  owner "#{node['openvswitch']['user']['name']}"
  group "#{node['openvswitch']['user']['name']}"
  mode '0755'
  action :create
  not_if do ::File.exists?("#{node['openvswitch']['download2']}/#{node['openvswitch']['filename']}") end
end

#
# execute 'Extract OVS sources' do
#   command 'tar xzvf openvswitch-2.5.0.tar.gz'
#   cwd '/home/ovs/rpmbuild/SOURCES/'
# end
#
# execute 'Build packages' do
#     user 'root'
#     action :run
#     command "sudo su - ovs -l -c 'cd /home/ovs/rpmbuild/SOURCES/openvswitch-2.5.0/ && rpmbuild -bb --nocheck /home/ovs/rpmbuild/SOURCES/openvswitch-2.5.0/rhel/openvswitch-fedora.spec'"
#     not_if do ::File.exists?('/home/ovs/rpmbuild/RPMS/x86_64/openvswitch-2.5.0-1.el7.centos.x86_64.rpm') end
# end
#
# rpm_package '/home/ovs/rpmbuild/RPMS/x86_64/openvswitch-2.5.0-1.el7.centos.x86_64.rpm' do
#   action :install
# end
#
# # Ensure the service is properly started
# service 'openvswitch.service' do
#   action [ :enable, :start ]
# end

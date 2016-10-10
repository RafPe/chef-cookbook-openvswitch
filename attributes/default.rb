default['openvswitch']['version'] = '2.6.0'

# Create openvswitch user
default['openvswitch']['user']= {
  'name' => 'ovs',
  'comment' => 'OpenVswitch user',
  'home' => '/home/ovs',
  'shell' => '/bin/bash',
  'password' => '$1$JJsvHslasdfjVEroftprNn4JHtDi'
}

# Folders for sources
default['openvswitch']['sourcefolders'] = [ "rpmbuild", "rpmbuild/SOURCES" ]

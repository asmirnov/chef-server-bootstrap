#
# Cookbook Name:: chef-server-bootstrap
# Recipe:: default
#
# Copyright 2013, Alexander Smirnov
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set some attributes for wrapped cookbooks.
node.default[:chef_server_populator][:servername_override] = node[:chef_server_bootstrap][:hostname]
node.default[:chef_server_populator][:clients][:'chef-admin'] = 'client_key_pub.pem'
node.default[:chef_server_populator][:clients][:'chef-validator'] = 'validation_pub.pem'
node.default[:'chef-server'][:configuration][:chef_server_webui][:enable] = false

# Create directory and put public keys there.
# Forcing creation in compilation phase because chef-server-populator relies on
# presence of these files at compile time.
directory node[:chef_server_populator][:base_path] do
  owner "root"
  group "root"
  mode  "0644"
  action :nothing
end.run_action(:create)

file File.join(node[:chef_server_populator][:base_path], node[:chef_server_populator][:clients][:'chef-validator']) do
  owner "root"
  group "root"
  mode "0755"
  content node[:chef_server_bootstrap][:validation_pub]
  action :nothing
end.run_action(:create)

file File.join(node[:chef_server_populator][:base_path], node[:chef_server_populator][:clients][:'chef-admin']) do
  owner "root"
  group "root"
  mode "0755"
  content node[:chef_server_bootstrap][:client_pub]
  action :nothing
end.run_action(:create)

# Create the entry in /etc/hosts
hostsfile_entry node['ipaddress'] do
  hostname node[:chef_server_bootstrap][:hostname]
end

# Install chef-rewind to alter chef-server-populator cookbook
chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "chef-server-populator"

# Disable resource from chef-server-populator cookbook because it makes chef run fail without extra configuration and we don't need it
rewind :execute => 'install chef-server-populator cookbook' do
  action :nothing
end
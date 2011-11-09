#
# Cookbook Name:: pennyworth
# Recipe:: update_version
#
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2011, AJ Christensen <aj@junglist.gen.nz>
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
include_recipe "jenkins"

cookbook_file "/usr/local/bin/update_version.rb" do
  mode 0755
  owner node.jenkins.server.user
  group node.jenkins.server.group
end

directory "/etc/chef" do
  mode "755"
end

file "/etc/chef/client.pem" do
  mode "644"
end

directory "#{node.jenkins.server.home}/.chef/plugins/knife" do
  owner node.jenkins.server.user
  group node.jenkins.server.group
  recursive true
end

# SSH keypair?
# TODO: Darrin??
# cookbook_file "#{node.jenkins.server.home}/.chef/#{node.chef_environment}.pem" do
#   source "#{node.chef_environment}.pem"
#   owner node.jenkins.server.user
#   group node.jenkins.server.group
# end

# Knife Deployment plugin
cookbook_file "#{node.jenkins.server.home}/.chef/plugins/knife/deploy.rb" do
  source "deploy.rb"
  owner node.jenkins.server.user
  group node.jenkins.server.group
end


#
# Cookbook Name:: pennyworth
# Recipe:: ssh_key
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

include_recipe "pennyworth::remount_ephemeral" if node.has_key? :ec2

# This recipe *has* to run before Jenkins is installed

user node.jenkins.server.user do
  home node.jenkins.server.home
  shell "/bin/bash"
end

directory node.jenkins.server.home do
  recursive true
  owner node.jenkins.server.user
  group node.jenkins.server.group
end

directory File.join(node.jenkins.server.home, ".ssh") do
  mode 0700
  owner node.jenkins.server.user
  group node.jenkins.server.group
end

{
  "known_hosts"    => "known_hosts",
  "ssh_config"     => "config",
}.each do |source, dest|
  cookbook_file File.join(node.jenkins.server.home, ".ssh", dest) do
    source source
    owner node.jenkins.server.user
    group node.jenkins.server.group
    mode "600"
  end
end

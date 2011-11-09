#
# Cookbook Name:: reprepro
# Recipe:: default
#
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: AJ Christensen <aj@junglist.gen.nz>
# Copyright 2010, Opscode
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

include_recipe "build-essential"
include_recipe "apache2"
include_recipe "apt"
include_recipe "gpg"

apt_repo = node.reprepro.to_hash

ruby_block "save node data" do
  block do
    node.save
  end
  action :create
end unless Chef::Config[:solo]


%w{apt-utils dpkg-dev reprepro debian-keyring devscripts dput}.each do |pkg|
  package pkg
end

[ apt_repo["repo_dir"], apt_repo["incoming"] ].each do |dir|
  directory dir do
    owner "nobody"
    group "nogroup"
    mode "0755"
  end
end

%w{ conf db dists pool tarballs }.each do |dir|
  directory "#{apt_repo["repo_dir"]}/#{dir}" do
    owner "nobody"
    group "nogroup"
    mode "0755"
  end
end

%w{ distributions incoming pulls }.each do |conf|
  template "#{apt_repo["repo_dir"]}/conf/#{conf}" do
    source "#{conf}.erb"
    mode "0644"
    owner "nobody"
    group "nogroup"
    variables(
              :codenames => apt_repo["codenames"],
              :architectures => apt_repo["architectures"],
              :incoming => apt_repo["incoming"],
              :pulls => apt_repo["pulls"]
              )
  end
end

directory "/root/.gnupg" do
  mode 0700
end



# %w[pubring.gpg secring.gpg trustdb.gpg].map do |gpg_cookbook_file|
#   cookbook_file File.join("/root/.gnupg/", gpg_cookbook_file) do
#     mode 0600
#   end
# end

# execute "import packaging key" do
#   command "/bin/echo -e '#{apt_repo["pgp"]["private"]}' | gpg --import -"
#   user "root"
#   cwd "/root"
#   not_if "gpg --list-secret-keys --fingerprint #{node[:reprepro][:pgp][:email]} | egrep -qx '.*Key fingerprint = #{node[:reprepro][:pgp][:fingerprint]}'"
# end

# template "#{apt_repo["repo_dir"]}/#{node[:reprepro][:pgp][:email]}.gpg.key" do
#   source "pgp_key.erb"
#   mode "0644"
#   owner "nobody"
#   group "nogroup"
#   variables(
#             :pgp_public => apt_repo["pgp"]["public"]
#             )
# end

template "#{node[:apache][:dir]}/sites-available/apt_repo.conf" do
  source "apt_repo.conf.erb"
  mode 0644
  owner "root"
  group "root"
  variables(
            :repo_dir => apt_repo["repo_dir"]
            )
end

apache_site "apt_repo.conf"

apache_site "000-default" do
  enable false
end

pgp_key = "#{apt_repo["repo_dir"]}/#{node.gpg.name.email}.gpg.key"
execute "gpg --armor --export #{node.gpg.name.real} > #{pgp_key}" do
  creates pgp_key
end

file pgp_key do
  mode "0644"
  owner "nobody"
  group "nogroup"
end

execute "reprepro -Vb #{apt_repo['repo_dir']} export" do
  action :nothing
  subscribes :run, resources(:file => pgp_key), :immediately
  user "root"
  group "root"
  environment "GNUPGHOME" => "/root/.gnupg"
end

execute "apt-key add #{pgp_key}" do
  action :nothing
  subscribes :run, resources(:file => pgp_key), :immediately
end

apt_repository "reprepro" do
  uri "file://#{apt_repo['repo_dir']}"
  distribution node.lsb.codename
  components ["main"]
  key pgp_key
  action :nothing
  subscribes :add, resources(:file => pgp_key), :delayed
end

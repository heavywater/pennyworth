#
# Cookbook Name:: minitest
# Recipe:: default
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
gem_package "minitest" do
  version "2.3.1"
#  version "~> 2.3.1"
end.run_action(:install)

node.minitest.gem_dependencies.each do |gem|
  gem_package(gem) { action :nothing }.run_action(:install)
end

include_recipe "chef_handler"
cookbook_file(File.join(node.chef_handler.handler_path, "chefminitest.rb")).run_action(:create)
chef_handler "ChefMiniTest::Handler" do
  source File.join(node.chef_handler.handler_path, "chefminitest.rb")
  action :nothing
end.run_action(:enable)


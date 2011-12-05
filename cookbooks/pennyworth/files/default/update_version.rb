#!/usr/bin/env ruby

require "rubygems"
require "json"
require "chef/data_bag_item"
require "chef/knife"
require "chef/config"

class UploadVersion < Chef::Knife
  def run
    Chef::Config.from_file "/etc/chef/client.rb"
    item = Chef::DataBagItem.new
    item.data_bag "package"
    item.raw_data =  { "id" => ARGV[0], "version" => ARGV[1] }
    item.save
  end
end

UploadVersion.new.run

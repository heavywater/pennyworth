#
# Cookbook Name:: pennyworth
# Recipe:: remount_ephemeral
#
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2011, AJ Christensen <aj@Junglist.gen.nz>
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

return unless node.has_key? :ec2

%w[xfsprogs lvm2].each do |p|
  package p
end

mount "/mnt" do
  device node.pennyworth.ephemeral_device
  action [:umount, :disable]
end

execute "LVM: Initialize physical node.pennyworth.ephemeral_device '#{node.pennyworth.ephemeral_device}'" do
  command "pvcreate #{node.pennyworth.ephemeral_device}"
  not_if "pvdisplay #{node.pennyworth.ephemeral_device}"
end

execute "LVM: Create volume group #{node.pennyworth.ephemeral_volume_group}" do
  command "vgcreate #{node.pennyworth.ephemeral_volume_group} #{node.pennyworth.ephemeral_device}"
  not_if "vgdisplay #{node.pennyworth.ephemeral_volume_group}"
end

execute "LVM: Extend volume group #{node.pennyworth.ephemeral_volume_group} with #{node.pennyworth.ephemeral_device}" do
  command "vgextend #{node.pennyworth.ephemeral_volume_group} #{node.pennyworth.ephemeral_device}"
  not_if "pvs --noheadings -o vg_name #{node.pennyworth.ephemeral_device} | grep #{node.pennyworth.ephemeral_volume_group}"
end

execute "LVM: Create LV #{node.pennyworth.ephemeral_logical_volume}" do
  command "lvcreate -n #{node.pennyworth.ephemeral_logical_volume} -l 100%FREE #{node.pennyworth.ephemeral_volume_group}"
  not_if "lvdisplay #{node.pennyworth.lv_path}"
end

execute "XFS: Format #{node.pennyworth.lv_path}" do
  command "mkfs.xfs #{node.pennyworth.lv_path}"
  action :nothing
  subscribes :run, resources(:execute => "LVM: Create LV #{node.pennyworth.ephemeral_logical_volume}"), :immediately
end

execute "blockdev --setra 65536 #{node.pennyworth.lv_path}" do
  not_if "blockdev --getra #{node.pennyworth.lv_path} | grep 65536"
end

mount node.pennyworth.ephemeral_mount_point do
  device node.pennyworth.lv_path
  options "defaults,noatime,inode64"
  fstype "xfs"
  action [:mount, :enable]
end

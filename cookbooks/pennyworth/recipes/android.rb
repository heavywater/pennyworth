include_recipe "ant"

node.default[:pennyworth][:android_sdk_tarfile] = File.join(Chef::Config[:file_cache_path],
                                                            URI.parse(node[:pennyworth][:android_sdk_url]).path.split("/").last)
remote_file node[:pennyworth][:android_sdk_tarfile] do
  source node[:pennyworth][:android_sdk_url]
  action :create_if_missing
end

execute "android: directory permission" do
  command "chown -R root:root #{node[:pennyworth][:android_path]}; " +
    "chmod -R a+r #{node[:pennyworth][:android_path]}; " +
    "find #{node[:pennyworth][:android_path]} -type d | xargs chmod 755"
  action :nothing
end

execute "android: untar" do
  command "tar zxf #{node[:pennyworth][:android_sdk_tarfile]}"
  cwd File.expand_path(File.join(node[:pennyworth][:android_path], ".."))
  creates node[:pennyworth][:android_path]
end

file "/etc/profile.d/android.sh" do
  mode "0755"
  content "export PATH=#{node[:pennyworth][:android_path]}/bin:#{node[:pennyworth][:android_path]}/tools:$PATH\n"
end

android_binary = File.join(node[:pennyworth][:android_path], "tools", "android")
execute "android: update sdk" do
  command "#{android_binary} update sdk -u -t platform,system-image,tool,platform-tool,source"
  path [ File.join(node[:pennyworth][:android_path], "tools") ]
  creates "/opt/android-sdk-linux/platform-tools"
  notifies :run, "execute[android: directory permission]"
end

execute "android: create android virtual device (avd)" do
  command "echo 'no' | #{android_binary} create avd " +
    "--name #{node[:pennyworth][:android][:avd]} --target #{node[:pennyworth][:android][:target]} --path /opt/avd --force"
  creates "/opt/avd"
end

template "/etc/init/emulator.conf" do
  source "emulator.conf.erb"
  variables( :android_path => node[:pennyworth][:android_path],
             :avd => node[:pennyworth][:android][:avd] )
  mode "644"
  notifies :restart, "service[android: emulator]"
end

service "android: emulator" do
  service_name "emulator"
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

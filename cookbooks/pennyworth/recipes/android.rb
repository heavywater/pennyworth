node.default[:pennyworth][:android_sdk_tarfile] = File.join(Chef::Config[:file_cache_path],
                                                            URI.parse(node[:pennyworth][:android_sdk_url]).path.split("/").last)
remote_file node[:pennyworth][:android_sdk_tarfile] do
  source node[:pennyworth][:android_sdk_url]
  action :create_if_missing
end

execute "android: untar" do
  command "tar zxvf #{node[:pennyworth][:android_sdk_tarfile]}"
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
end
